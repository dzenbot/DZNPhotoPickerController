//
//  FKNetworkOperation.m
//  FlickrKit
//
//  Created by David Casserly on 06/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKFlickrNetworkOperation.h"
#import "FKDUBlocks.h"
#import "FlickrKit.h"
#import "FKURLBuilder.h"
#import "FKUtilities.h"
#import "FKDUNetworkController.h"

@interface FKFlickrNetworkOperation ()
@property (nonatomic, strong) NSString *apiMethod;
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, copy) FKAPIRequestCompletion completion;
@property (nonatomic, strong) id<FKDUDiskCache> diskCache;
@property (nonatomic, assign) NSInteger maxAgeMinutes;
@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, retain) id<FKFlickrAPIMethod> method;

@end

@implementation FKFlickrNetworkOperation

#pragma mark - Init

- (id) initWithAPIMethod:(NSString *)api arguments:(NSDictionary *)args maxAgeMinutes:(FKDUMaxAge)maxAge diskCache:(id<FKDUDiskCache>)diskCache completion:(FKAPIRequestCompletion)completion {
	self = [super init];
    if (self) {
		self.maxAgeMinutes = maxAge;
		self.diskCache = diskCache;
        self.apiMethod = api;
		self.args = args;
		self.completion = completion;
		self.cacheKey = [self generateCacheKey];
		NSAssert(completion, @"We must have a completion block");
    }
    return self;
}

- (id) initWithAPIMethod:(id<FKFlickrAPIMethod>)method maxAgeMinutes:(FKDUMaxAge)maxAge diskCache:(id<FKDUDiskCache>)diskCache completion:(FKAPIRequestCompletion)completion {
    NSString *api = [method name];
    NSDictionary *args = [method args];
    return [self initWithAPIMethod:api arguments:args maxAgeMinutes:maxAge diskCache:diskCache completion:completion];
}

#pragma mark - DUOperation Methods

- (void) cancel {
	self.completion = nil;
	[super cancel];
}

- (void) finish {
	self.completion = nil;
	[super finish];
}

- (BOOL) startRequest:(NSError **)error {
    
    if (self.method) {
        BOOL validArgs = [self.method isValid:error];
        if (!validArgs) {                                    
            return NO;
        }
    }
    
	NSData *cachedData = nil;
	if (0 == self.maxAgeMinutes) {
		[self.diskCache removeDataForKey:self.cacheKey];
	} else {
		cachedData = [self.diskCache dataForKey:self.cacheKey maxAgeMinutes:self.maxAgeMinutes];
	}
	
	if (cachedData) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self processResponseData:cachedData];
		});
        return YES;
	} else {
        NSURLRequest *request = [self createRequest:error];
        if (request) {
            [super connectWithRequest:request];
            return YES;
        } else {
            return NO;
        }
	}
}

#pragma mark - Cache

- (NSString *) generateCacheKey {
    NSMutableString *cacheString = [[NSMutableString alloc] initWithString:self.apiMethod];
    for (NSString *key in [self.args allKeys]) {
        NSString *value = [self.args valueForKey:key];
        [cacheString appendString:key];
        [cacheString appendString:value];
    }
    return [NSString stringWithString:cacheString];
}

#pragma mark - NSURLConnection Delegate methods

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.completion) {
		self.completion(nil, error);
    }
    [self finish];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        NSData *data = self.receivedData;
        
		static NSInteger prefixBytes = -1;
		static NSInteger suffixBytes = 1;
		if (-1 == prefixBytes) {
			NSString *responsePrefix = @"jsonFlickrApi(";
			prefixBytes = [responsePrefix length];
		}
		
		NSData *subData = nil;
        if (data.length > prefixBytes) {
            subData =[data subdataWithRange:NSMakeRange(prefixBytes, data.length - prefixBytes - suffixBytes)];
        }
		
		//Cache the response
		if (data && data.length > 0) {
			if (0 != self.maxAgeMinutes) {
				[self.diskCache storeData:subData forKey:self.cacheKey];
			}
            [self processResponseData:subData];
		} else {
            NSString *errorString = @"No data was returned from Flickr to process";
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorString};
			NSError *error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorEmptyResponse userInfo:userInfo];
			if (self.completion) {
				self.completion(nil, error);
			}
        }
		
	});
}

#pragma mark - Request

- (NSMutableURLRequest *) createRequest:(NSError **)error {
	
	NSMutableDictionary *newArgs = self.args ? [NSMutableDictionary dictionaryWithDictionary:self.args] : [NSMutableDictionary dictionary];
	newArgs[@"method"] = self.apiMethod;
	newArgs[@"format"] = @"json";
	
	FKURLBuilder *urlBuilder = [[FKURLBuilder alloc] init];
	
	NSURL *url = nil;
	if ([FlickrKit sharedFlickrKit].isAuthorized) {
		url = [urlBuilder oauthURLFromBaseURL:[NSURL URLWithString:FKFlickrRESTAPI] method:FKHttpMethodGET params:newArgs];
	} else {
		NSString *query = [urlBuilder signedQueryStringFromParameters:newArgs];
		NSString *URLString = [NSString stringWithFormat:@"%@?%@", FKFlickrRESTAPI, query];		
		url = [NSURL URLWithString:URLString];
	}
	
    //Create Request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
	request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    //HTTP Method
	request.HTTPMethod = @"GET";
    
    return request;
}

#pragma mark - Response

- (void) processResponseData:(NSData *)data {
	
	NSAssert(data, @"Must have data");
	
#ifdef DEBUG
	//NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#endif
	
	NSError *error = nil;
	id jsonData = [NSJSONSerialization JSONObjectWithData:data
												  options:NSJSONReadingAllowFragments
													error:&error];
	if (!jsonData) {
		if (self.completion) {
			self.completion(nil, error);
		}		
	} else {
		
		NSString *status = [jsonData valueForKey:@"stat"];
		if ([status isEqualToString:@"fail"]) {
			if (self.completion) {
				NSInteger errorCode = [[jsonData valueForKey:@"code"] integerValue];
				NSString *errorDescription = [jsonData valueForKey:@"message"];				
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
				NSError *error = [NSError errorWithDomain:FKFlickrAPIErrorDomain code:errorCode userInfo:userInfo];
				self.completion(nil, error);
			}			
		} else {
			if (self.completion) {
				self.completion(jsonData, nil);
			}			
		}		
	}
	[self finish];
}

@end

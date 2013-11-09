//
//  FKDUNetworkOperation.m
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDUNetworkOperation.h"
#import "FKDUBlocks.h"
#import "FKDUNetworkController.h"

@interface FKDUNetworkOperation ()
@property (nonatomic, strong) NSURLConnection *httpConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, copy) FKDUNetworkCompletion completion;
@end

@implementation FKDUNetworkOperation

- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

#pragma mark - Operation Methods

- (void) cancel {
	[self.httpConnection cancel];
	self.completion = nil;
	[super cancel];
}

- (void) finish {
	self.httpConnection = nil;
    self.receivedData = nil;
	self.completion = nil;
	[super finish];
}

- (void) start {
	if ([self isCancelled]) {
		// Must move the operation to the finished state if it is canceled.
		[self finish];
		return;
	}
	[super start];
	
	NSAssert(![NSThread isMainThread], @"Dont want to do this on main thread");
	
	//Need to start this on the networking thread because we create a NSURLConnection, and we would lose
    //the delegate callbacks because the thread would die. Alternatively, we could create a network thread.
    FKexecuteBlockOnThread([FKDUNetworkController networkRequestThread], ^{
        NSError *error = nil;
		BOOL started = [self startRequest:&error];
        if (!started) {
            if (self.completion) {
                self.completion(nil, nil, error);
            }
            [self finish];
        }
    });
}

- (BOOL) startRequest:(NSError **)error {
    NSMutableURLRequest *request = [self createRequest:error];
    if (request) {
        [self connectWithRequest:request];
        return YES;
    } else {
        return NO;
    }	
}

#pragma mark - Request

- (NSMutableURLRequest *) createRequest:(NSError **)error {
    //Create Request
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    //HTTP Method
	request.HTTPMethod = @"GET";
    
    return request;
}

#pragma mark - Connect

- (void) sendAsyncRequestOnCompletion:(FKDUNetworkCompletion)completion {
	self.completion = completion;	
	[[FKDUNetworkController sharedController] execute:self];
}

- (void) connectWithRequest:(NSMutableURLRequest *)request {
	self.request = request;
	self.receivedData = [NSMutableData data];
	self.httpConnection = [[NSURLConnection alloc] initWithRequest:self.request
														  delegate:self
												  startImmediately:YES];
}

#pragma mark - NSURLConnection Delegate methods

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.completion) {
		self.completion(nil, nil, error);
    }
    [self finish];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (NSURLRequest *) connection:(NSURLConnection *)connection
              willSendRequest:(NSURLRequest *)request
             redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[cachedResponse response];
    // Look up the cache policy used in our request
    if([connection currentRequest].cachePolicy == NSURLRequestUseProtocolCachePolicy) {
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSString *cacheControl = [headers valueForKey:@"Cache-Control"];
        NSString *expires = [headers valueForKey:@"Expires"];
        if((cacheControl == nil) && (expires == nil)) {
            NSLog(@"server does not provide expiration information and we are using NSURLRequestUseProtocolCachePolicy");
            return nil; // don't cache this
        }
    }
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
    self.response = (NSHTTPURLResponse *) response;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (self.completion) {
			self.completion(self.response, self.receivedData, nil);
		}
	});
}

@end

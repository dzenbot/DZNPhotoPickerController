//
//  DZNPhotoServiceClient.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoServiceClient.h"

#import "DZNPhotoServiceConstants.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

#import "AFNetworkActivityIndicatorManager.h"

@interface DZNPhotoServiceClient ()
@property (nonatomic, copy) DZNHTTPRequestCompletion completion;
@end

@implementation DZNPhotoServiceClient
@synthesize service = _service;
@synthesize subscription = _subscription;
@synthesize loading = _loading;

- (instancetype)initWithService:(DZNPhotoPickerControllerServices)service subscription:(DZNPhotoPickerControllerSubscription)subscription
{
    self = [super initWithBaseURL:baseURLForService(service)];
    if (self) {

        _service = service;
        _subscription = subscription;
        
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        NSString *consumerKey = [self consumerKey];
        NSString *accessToken = [self accessToken];
        
        NSLog(@"consumerKey : %@", consumerKey);
        NSLog(@"accessToken : %@", accessToken);

        // Add basic auth to Bing service
        if (_service == DZNPhotoPickerControllerServiceBingImages && consumerKey) {
            
            //Bing requires basic auth with password and user name as the consumer key.
            [self.requestSerializer setAuthorizationHeaderFieldWithUsername:consumerKey password:consumerKey];
        }
        else if (_service == DZNPhotoPickerControllerServiceGettyImages && consumerKey) {
            
            
            [self.requestSerializer setValue:consumerKey forHTTPHeaderField:@"Api-Key"];
            
            
            // Getty Images requires a Client Credentials Client Credentials grant, meant for client applications that will not have individual users.
//            [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
        }
    }
    
    NSLog(@"HTTPRequestHeaders : %@", self.requestSerializer.HTTPRequestHeaders);
    
    return self;
}


#pragma mark - Getter methods

- (NSString *)consumerKey
{
    return [self cachedValueForKey:DZNPhotoServiceClientConsumerKey];
}

- (NSString *)consumerSecret
{
    return [self cachedValueForKey:DZNPhotoServiceClientConsumerSecret];
}

- (NSString *)accessToken
{
    return @"yQyhe8rpE/MIKOOYdL6c9mlWQBh3IEMnxh3vjAPUXnYJNV5vLEu2OnIxhdYeEVqjtNXbE3ImY6sQhmpsgMACevPnLlDwVafWPXsC0L6/sMevY1znwsd5JWt35se/YfjxwEVyFA8YufAGw9FngyzoAe2QF9PQF9ABtaRBJ2kmzWs=|77u/dWZSYUF1WVl6ekJ5UnVJckJuY3YKMTIzMTQKODU1ODc1MAo0Z3Y5Qmc9PQo2aEw5Qmc9PQoxCmNmNXc0bWd5ZGs1ZHdhdDJmd2c4eHRoNQoxMjcuMC4wLjEKMAoxMjMxNAo0Z3Y5Qmc9PQoxMjMxNAowCgo=|3";
    
    return [self cachedValueForKey:DZNPhotoServiceClientAccessToken];
}

- (NSString *)cachedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsUniqueKey(_service, key)];
}

- (NSDictionary *)tagsParamsWithKeyword:(NSString *)keyword
{
    NSAssert(keyword, @"'keyword' cannot be nil for %@", NSStringFromService(_service));
    NSAssert([self consumerKey], @"'consumerKey' cannot be nil for %@", NSStringFromService(_service));
    NSAssert([self consumerSecret], @"'consumerSecret' cannot be nil for %@", NSStringFromService(_service));
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self consumerKey] forKey:keyForAPIConsumerKey(_service)];
    [params setObject:keyword forKey:keyForSearchTag(_service)];
    
    if (_service == DZNPhotoPickerControllerServiceFlickr) {
        [params setObject:tagSearchUrlPathForService(_service) forKey:@"method"];
        [params setObject:@"json" forKey:@"format"];
    }
    
    return params;
}

- (NSDictionary *)photosParamsWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage
{
    NSAssert(keyword, @"'keyword' cannot be nil for %@", NSStringFromService(_service));
    NSAssert((resultPerPage > 0), @"'result per page' must be higher than 0 for %@", NSStringFromService(_service));
    NSAssert([self consumerKey], @"'consumerKey' cannot be nil for %@", NSStringFromService(_service));
    if (isConsumerSecretRequiredForService(_service)) {
        NSAssert([self consumerSecret], @"'consumerSecret' cannot be nil for %@", NSStringFromService(_service));
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (isConsumerKeyInParametersRequiredForService(_service)) {
        [params setObject:[self consumerKey] forKey:keyForAPIConsumerKey(_service)];
    }
    
    //Bing requires parameters to be wrapped in '' values.
    if (_service == DZNPhotoPickerControllerServiceBingImages) {
        [params setObject:[NSString stringWithFormat:@"'%@'", keyword] forKey:keyForSearchTerm(_service)];
    } else {
        [params setObject:keyword forKey:keyForSearchTerm(_service)];
    }
    
    if (keyForSearchResultPerPage(_service)) {
        [params setObject:@(resultPerPage) forKey:keyForSearchResultPerPage(_service)];
    }
    if (_service == DZNPhotoPickerControllerService500px || _service == DZNPhotoPickerControllerServiceFlickr || _service == DZNPhotoPickerControllerServiceGettyImages) {
        [params setObject:@(page) forKey:@"page"];
    }
    
    if (_service == DZNPhotoPickerControllerService500px)
    {
        [params setObject:@[@(2),@(4)] forKey:@"image_size"];
        [params setObject:@"Nude" forKey:@"exclude"];
    }
    else if (_service == DZNPhotoPickerControllerServiceFlickr)
    {
        [params setObject:photoSearchUrlPathForService(_service) forKey:@"method"];
        [params setObject:@"json" forKey:@"format"];
        [params setObject:@"photos" forKey:@"media"];
        [params setObject:@(YES) forKey:@"in_gallery"];
        [params setObject:@(1) forKey:@"safe_search"];
        [params setObject:@(1) forKey:@"content_type"];
    }
    else if (_service == DZNPhotoPickerControllerServiceGoogleImages)
    {
        [params setObject:[self consumerSecret] forKey:keyForAPIConsumerSecret(_service)];
        [params setObject:@"image" forKey:@"searchType"];
        [params setObject:@"medium" forKey:@"safe"];
        if (page > 1) [params setObject:@((page - 1) * resultPerPage + 1) forKey:@"start"];
    }
    else if (_service == DZNPhotoPickerControllerServiceBingImages)
    {
        [params setObject:@"'Moderate'" forKey:@"Adult"];
        
        //Default to size medium. Size Large causes some buggy behavior with download times.
        [params setObject:@"'Size:Medium'" forKey:@"ImageFilters"];
    }
    else if (_service == DZNPhotoPickerControllerServiceGettyImages)
    {
        [params setObject:@[@"high_res_comp", @"largest_downloads"] forKey:@"fields"];
        [params setObject:@"photography" forKey:@"graphical_styles"];
        [params setObject:@YES forKey:@"exclude_nudity"];
    }
    
    NSLog(@"params : %@", params);
    
    return params;
}

- (NSData *)processData:(NSData *)data
{
    if (_service == DZNPhotoPickerControllerServiceFlickr) {
        
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *responsePrefix = @"jsonFlickrApi(";
        
        if ([string rangeOfString:responsePrefix].location != NSNotFound) {
            string = [[string stringByReplacingOccurrencesOfString:responsePrefix withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
            return [string dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return data;
}

- (NSArray *)parseObjects:(Class)class withJSON:(NSDictionary *)json
{
    NSString *keyPath = keyPathForObjectName(_service, [class name]);
    NSMutableArray *objects = [NSMutableArray arrayWithArray:[json valueForKeyPath:keyPath]];
    
    if ([[class name] isEqualToString:[DZNPhotoTag name]]) {
        
        if (_service == DZNPhotoPickerControllerServiceFlickr) {
            NSString *keyword = [json valueForKeyPath:@"tags.source"];
            if (keyword) [objects insertObject:@{keyForSearchTagContent(_service):keyword} atIndex:0];
        }
        
        return [DZNPhotoTag photoTagListFromService:_service withResponse:objects];
    }
    else if ([[class name] isEqualToString:[DZNPhotoMetadata name]]) {
        return [DZNPhotoMetadata metadataListWithResponse:objects service:_service];
    }
    
    return nil;
}


#pragma mark - DZNPhotoServiceClient methods

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion
{
    NSString *path = tagSearchUrlPathForService(_service);
    
    NSDictionary *params = [self tagsParamsWithKeyword:keyword];
    [self getObject:[DZNPhotoTag class] path:path params:params completion:completion];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion
{
    NSString *path = photoSearchUrlPathForService(_service);

    NSDictionary *params = [self photosParamsWithKeyword:keyword page:page resultPerPage:resultPerPage];
    [self getObject:[DZNPhotoMetadata class] path:path params:params completion:completion];
}

- (void)getObject:(Class)class path:(NSString *)path params:(NSDictionary *)params completion:(DZNHTTPRequestCompletion)completion
{
    _loading = YES;
    
    if (_service == DZNPhotoPickerControllerServiceInstagram) {
        NSString *keyword = [params objectForKey:keyForSearchTerm(_service)];
        NSString *encodedKeyword = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
        path = [path stringByReplacingOccurrencesOfString:@"%@" withString:encodedKeyword];
    }
    else if (_service == DZNPhotoPickerControllerServiceFlickr) {
        path = @"";
    }
        
    [self GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSData *data = [self processData:response];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
        
        _loading = NO;
        if (completion) completion([self parseObjects:class withJSON:json], nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        _loading = NO;
        if (completion) completion(nil, error);
    }];
}

- (void)cancelRequest
{
    [self.operationQueue cancelAllOperations];
}

@end

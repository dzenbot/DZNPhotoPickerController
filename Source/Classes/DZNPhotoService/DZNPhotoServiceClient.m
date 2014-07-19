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

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

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
        
        // Add basic auth to Bing service
        if (_service == DZNPhotoPickerControllerServiceBingImages) {
            
            NSString *key = [self consumerKey];
            
            //Bing requires basic auth with password and user name as the consumer key.
            [self.requestSerializer setAuthorizationHeaderFieldWithUsername:key password:key];
        }
    }
    return self;
}


#pragma mark - Getter methods

- (NSString *)consumerKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsUniqueKey(_service, DZNPhotoServiceClientConsumerKey)];
}

- (NSString *)consumerSecret
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsUniqueKey(_service, DZNPhotoServiceClientConsumerSecret)];
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
    
    //Bing requires parameters to be wrapped in '' values. If I'm missing something like just choosing a different URLEncoding, or a different way to set parameters please help me understand. @dirtbikerdude.91 Thanks.
    if (_service == DZNPhotoPickerControllerServiceBingImages) {
        [params setObject:[NSString stringWithFormat:@"'%@'", keyword] forKey:keyForSearchTerm(_service)];
    } else {
        [params setObject:keyword forKey:keyForSearchTerm(_service)];
    }

    
    if (_service != DZNPhotoPickerControllerServiceInstagram && _service != DZNPhotoPickerControllerServiceBingImages) {
        [params setObject:@(resultPerPage) forKey:keyForSearchResultPerPage(_service)];
    }
    if (_service == DZNPhotoPickerControllerService500px || _service == DZNPhotoPickerControllerServiceFlickr) {
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

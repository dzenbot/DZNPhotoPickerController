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

@interface DZNPhotoServiceClient ()
@property (nonatomic, copy) DZNHTTPRequestCompletion completion;
@property (nonatomic, copy) NSString *loadingPath;
@end

@implementation DZNPhotoServiceClient
@synthesize service = _service;
@synthesize subscription = _subscription;
@synthesize loading = _loading;

- (instancetype)initWithService:(DZNPhotoPickerControllerService)service subscription:(DZNPhotoPickerControllerSubscription)subscription
{
    self = [super initWithBaseURL:baseURLForService(service)];
    if (self) {
        self.parameterEncoding = AFJSONParameterEncoding;
        _service = service;
        _subscription = subscription;
    }
    return self;
}


#pragma mark - Getter methods

- (BOOL)loading
{
    return (_loadingPath) ? YES : NO;
}

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
    NSAssert(keyword, @"\"keyword\" cannot be nil for %@", NSStringFromService(_service));
    NSAssert([self consumerKey], @"\"consumerKey\" cannot be nil for %@", NSStringFromService(_service));
    NSAssert([self consumerSecret], @"\"consumerSecret\" cannot be nil for %@", NSStringFromService(_service));
    
    
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
    NSAssert(keyword, @"\"keyword\" cannot be nil for %@", NSStringFromService(_service));
    NSAssert((resultPerPage > 0), @"\"result per page\" must be higher than 0 for %@", NSStringFromService(_service));
    NSAssert([self consumerKey], @"\"consumerKey\" cannot be nil for %@", NSStringFromService(_service));
    NSAssert([self consumerSecret], @"\"consumerSecret\" cannot be nil for %@", NSStringFromService(_service));

    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self consumerKey] forKey:keyForAPIConsumerKey(_service)];
    [params setObject:keyword forKey:keyForSearchTerm(_service)];

    if (_service != DZNPhotoPickerControllerServiceInstagram) {
        [params setObject:@(resultPerPage) forKey:keyForSearchResultPerPage(_service)];
    }
    if (_service == DZNPhotoPickerControllerService500px || _service == DZNPhotoPickerControllerServiceFlickr) {
        [params setObject:@(page) forKey:@"page"];
    }
    if (_service == DZNPhotoPickerControllerServiceGoogleImages || _service == DZNPhotoPickerControllerServiceYahooImages) {
        [params setObject:@(resultPerPage*page) forKey:@"start"];
    }
    
    if (_service == DZNPhotoPickerControllerService500px)
    {
        [params setObject:@[@(2),@(4)] forKey:@"image_size"];
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
    }
    else if (_service == DZNPhotoPickerControllerServiceYahooImages)
    {
        NSString *hmac = HMACSHA1(keyForAPIConsumerSecret(_service), [self consumerSecret]);
        NSLog(@"hmac : %@",hmac);
        
        [params setObject:@"1.0" forKey:@"oauth_version"];
        [params setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
        [params setObject:hmac forKey:@"oauth_signature"];
        [params setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"oauth_nonce"];
        [params setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"oauth_timestamp"];
        [params setObject:@"json" forKey:@"format"];
        [params setObject:@"-porn" forKey:@"filter"];
        
        
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

- (NSArray *)objectListForObject:(NSString *)objectName withJSON:(NSDictionary *)json
{
    NSString *keyPath = keyPathForObjectName(_service, objectName);
    NSMutableArray *objects = [NSMutableArray arrayWithArray:[json valueForKeyPath:keyPath]];
    
    if ([objectName isEqualToString:[DZNPhotoTag name]]) {
        
        if (_service == DZNPhotoPickerControllerServiceFlickr) {
            NSString *keyword = [json valueForKeyPath:@"tags.source"];
            if (keyword) [objects insertObject:@{keyForSearchTagContent(_service):keyword} atIndex:0];
        }
        
        return [DZNPhotoTag photoTagListFromService:_service withResponse:objects];
    }
    else if ([objectName isEqualToString:[DZNPhotoMetadata name]]) {
        return [DZNPhotoMetadata photoMetadataListFromService:_service withResponse:objects];
    }
    
    return nil;
}


#pragma mark - DZNPhotoServiceClient methods

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = tagSearchUrlPathForService(_service);

    NSDictionary *params = [self tagsParamsWithKeyword:keyword];
    [self getObject:[DZNPhotoTag name] path:_loadingPath params:params completion:completion];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = photoSearchUrlPathForService(_service);

    NSDictionary *params = [self photosParamsWithKeyword:keyword page:page resultPerPage:resultPerPage];
    [self getObject:[DZNPhotoMetadata name] path:_loadingPath params:params completion:completion];
}

- (void)getObject:(NSString *)objectName path:(NSString *)path params:(NSDictionary *)params completion:(DZNHTTPRequestCompletion)completion
{
//    NSLog(@"%s\nobjectName : %@ \npath : %@\nparams: %@\n\n",__FUNCTION__, objectName, path, params);
    
    if (_service == DZNPhotoPickerControllerServiceFlickr) {
        path = @"";
    }
    if (_service == DZNPhotoPickerControllerServiceInstagram)
    {
        NSString *keyword = [params objectForKey:keyForSearchTerm(_service)];
        path = [path stringByReplacingOccurrencesOfString:@"%@" withString:keyword];
    }

    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSData *data = [self processData:response];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
        
        if (completion) completion([self objectListForObject:objectName withJSON:json], nil);
        _loadingPath = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completion) completion(nil, error);
        _loadingPath = nil;
    }];
}

- (void)cancelRequest
{
    if (_loadingPath) {
        
        if (_service == DZNPhotoPickerControllerServiceFlickr) _loadingPath = @"";
        [self cancelAllHTTPOperationsWithMethod:@"GET" path:_loadingPath];
        
        _loadingPath = nil;
    }
}

@end

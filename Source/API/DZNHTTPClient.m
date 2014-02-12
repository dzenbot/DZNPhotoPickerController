//
//  DZNHTTPClient.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNHTTPClient.h"

@interface DZNHTTPClient ()
@property (nonatomic, copy) DZNHTTPRequestCompletion completion;
@property (nonatomic, copy) NSString *loadingPath;
@end

@implementation DZNHTTPClient

- (instancetype)initWithService:(DZNPhotoPickerControllerService)service
{
    self = [super initWithBaseURL:[self baseURLForService:service]];
    if (self) {
        self.service = service;
        self.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}


#pragma mark - Getter methods

- (NSURL *)baseURLForService:(DZNPhotoPickerControllerService)service
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return [NSURL URLWithString:@"https://api.500px.com/v1"];
        case DZNPhotoPickerControllerServiceFlickr:     return [NSURL URLWithString:@"http://api.flickr.com/services/rest/"];
        default:                                        return nil;
    }
}

- (NSString *)searchPhotosPathForService:(DZNPhotoPickerControllerService)service
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"photos/search";
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.photos.search";
        default:                                        return nil;
    }
}

- (NSString *)searchTagsPathForService:(DZNPhotoPickerControllerService)service
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.tags.getRelated";
        default:                                        return nil;
    }
}

- (BOOL)loading
{
    return (_loadingPath != nil) ? YES : NO;
}

- (NSString *)consumerKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringHashFromServiceType(self.service, DZNHTTPClientConsumerKey)];
}

- (NSString *)consumerSecret
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringHashFromServiceType(self.service, DZNHTTPClientConsumerSecret)];
}

- (NSDictionary *)paramsWithKeyword:(NSString *)keyword
{
    return [self paramsWithKeyword:keyword page:0 resultPerPage:0];
}

- (NSDictionary *)paramsWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage
{
    NSAssert(keyword, @"\"keyword\" cannot be nil.");
    NSAssert([self consumerKey], @"\"consumerKey\" cannot be nil.");
    NSAssert([self consumerSecret], @"\"consumerSecret\" cannot be nil.");
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self consumerKey] forKey:@"consumer_key"];
    [params setObject:keyword forKey:@"term"];
    if (page > 0) [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (resultPerPage > 0) [params setObject:[NSNumber numberWithInteger:resultPerPage] forKey:@"rpp"];
    
    if (self.service == DZNPhotoPickerControllerService500px) {
        [params setObject:@[[NSNumber numberWithInteger:2],[NSNumber numberWithInteger:4]] forKey:@"image_size"];
    }

    return params;
}


#pragma mark - DZNHTTPClient methods

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = [self searchTagsPathForService:self.service];
    NSDictionary *params = [self paramsWithKeyword:keyword];
    
    [self getPath:_loadingPath params:params completion:completion];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = [self searchPhotosPathForService:self.service];
    NSDictionary *params = [self paramsWithKeyword:keyword page:page resultPerPage:resultPerPage];
    
    [self getPath:_loadingPath params:params completion:completion];
}

- (void)getPath:(NSString *)path params:(NSDictionary *)params completion:(DZNHTTPRequestCompletion)completion
{
    NSLog(@"path : %@", path);
    NSLog(@"params : %@", params);
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"isValidJSONObject : %@", json ? @"YES" : @"NO");
        NSLog(@"json.class : %@", NSStringFromClass(json.class));

        if (completion) completion([json objectForKey:@"photos"], nil);
        _loadingPath = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completion) completion(nil, error);
        _loadingPath = nil;
        
    }];
}

- (void)cancelRequest
{
    if (_loadingPath) {
        [self cancelAllHTTPOperationsWithMethod:@"GET" path:_loadingPath];
    }
}

@end

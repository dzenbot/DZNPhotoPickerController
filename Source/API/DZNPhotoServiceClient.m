//
//  DZNPhotoServiceClient.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNPhotoServiceClient.h"

@interface DZNPhotoServiceClient ()
@property (nonatomic, copy) DZNHTTPRequestCompletion completion;
@property (nonatomic, copy) NSString *loadingPath;
@end

@implementation DZNPhotoServiceClient

- (instancetype)initWithService:(DZNPhotoPickerControllerService)service
{
    self = [super initWithBaseURL:baseURLForService(service)];
    if (self) {
        self.service = service;
        self.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}


#pragma mark - Getter methods

static NSURL *baseURLForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return [NSURL URLWithString:@"https://api.500px.com/v1"];
        case DZNPhotoPickerControllerServiceFlickr:     return [NSURL URLWithString:@"http://api.flickr.com/services/rest/"];
        default:                                        return nil;
    }
}

static NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.tags.getRelated";
        default:                                        return nil;
    }
}

static NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"photos/search";
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.photos.search";
        default:                                        return nil;
    }
}

static NSString *keyForAPIConsumer(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"consumer_key";
        case DZNPhotoPickerControllerServiceFlickr:     return @"api_key";
        default:                                        return nil;
    }
}

static NSString *keyForSearchTerm(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"term";
        case DZNPhotoPickerControllerServiceFlickr:     return @"term";
        default:                                        return nil;
    }
}

static NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"rpp";
        case DZNPhotoPickerControllerServiceFlickr:     return @"rpp";
        default:                                        return nil;
    }
}

- (BOOL)loading
{
    return (_loadingPath != nil) ? YES : NO;
}

- (NSString *)consumerKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringHashFromServiceType(self.service, DZNPhotoServiceClientConsumerKey)];
}

- (NSString *)consumerSecret
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringHashFromServiceType(self.service, DZNPhotoServiceClientConsumerSecret)];
}

- (NSDictionary *)tagsParamsWithKeyword:(NSString *)keyword
{
    NSAssert(keyword, @"\"keyword\" cannot be nil.");
    NSAssert([self consumerKey], @"\"consumerKey\" cannot be nil.");
    NSAssert([self consumerSecret], @"\"consumerSecret\" cannot be nil.");
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self consumerKey] forKey:keyForAPIConsumer(DZNPhotoPickerControllerServiceFlickr)];
    [params setObject:keyword forKey:@"tag"];
    
    if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        [params setObject:tagSearchUrlPathForService(self.service) forKey:@"method"];
    }

    return params;
}

- (NSDictionary *)photosParamsWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage
{
    NSAssert(keyword, @"\"keyword\" cannot be nil.");
    NSAssert((resultPerPage > 0), @"\"result per page\" must be higher than 0.");
    NSAssert([self consumerKey], @"\"consumerKey\" cannot be nil.");
    NSAssert([self consumerSecret], @"\"consumerSecret\" cannot be nil.");
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self consumerKey] forKey:photoSearchUrlPathForService(self.service)];
    [params setObject:keyword forKey:keyForSearchTerm(self.service)];
    [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInteger:resultPerPage] forKey:keyForSearchResultPerPage(self.service)];
    
    if (self.service == DZNPhotoPickerControllerService500px) {
        [params setObject:@[[NSNumber numberWithInteger:2],[NSNumber numberWithInteger:4]] forKey:@"image_size"];
    }

    return params;
}


#pragma mark - DZNPhotoServiceClient methods

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion
{
    if (_loadingPath) {
        return;
    }
    
    _loadingPath = tagSearchUrlPathForService(self.service);
    NSDictionary *params = [self tagsParamsWithKeyword:keyword];
    
    [self getPath:_loadingPath params:params completion:completion];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = photoSearchUrlPathForService(self.service);
    NSDictionary *params = [self photosParamsWithKeyword:keyword page:page resultPerPage:resultPerPage];
    
    [self getPath:_loadingPath params:params completion:completion];
}

- (void)getPath:(NSString *)path params:(NSDictionary *)params completion:(DZNHTTPRequestCompletion)completion
{
    NSLog(@"path : %@", path);
    NSLog(@"params : %@", params);
    
    if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        path = @"";
    }
    
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSLog(@"response : %@", response);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:nil];
        NSLog(@"isValidJSONObject : %@", json ? @"YES" : @"NO");
        NSLog(@"json.class : %@", NSStringFromClass(json.class));
        NSLog(@"json : %@", json);

        if (completion) completion([json objectForKey:@"photos"], nil);
        _loadingPath = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error : %@", error);
        
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

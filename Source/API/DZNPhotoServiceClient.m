//
//  DZNPhotoServiceClient.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNPhotoServiceClient.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

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
        case DZNPhotoPickerControllerServiceInstagram:  return [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        default:                                        return nil;
    }
}

static NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"tags.tag";
        case DZNPhotoPickerControllerServiceInstagram:  return @"data";
        default:                                        return nil;
    }
}

static NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"photos";
        case DZNPhotoPickerControllerServiceFlickr:     return @"photos.photo";
        case DZNPhotoPickerControllerServiceInstagram:  return @"data";
        default:                                        return nil;
    }
}

static NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.tags.getRelated";
        case DZNPhotoPickerControllerServiceInstagram:  return @"tags/search";
        default:                                        return nil;
    }
}

static NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"photos/search";
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.photos.search";
        case DZNPhotoPickerControllerServiceInstagram:  return @"tags/%@/media/recent";
        default:                                        return nil;
    }
}

static NSString *keyForAPIConsumer(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"consumer_key";
        case DZNPhotoPickerControllerServiceFlickr:     return @"api_key";
        case DZNPhotoPickerControllerServiceInstagram:  return @"client_id";
        default:                                        return nil;
    }
}

static NSString *keyForSearchTerm(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"term";
        case DZNPhotoPickerControllerServiceFlickr:     return @"text";
        case DZNPhotoPickerControllerServiceInstagram:  return @"q";
        default:                                        return nil;
    }
}

static NSString *keyForSearchTag(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"tag";
        case DZNPhotoPickerControllerServiceInstagram:  return @"q";
        default:                                        return nil;
    }
}

static NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"rpp";
        case DZNPhotoPickerControllerServiceFlickr:     return @"per_page";
        default:                                        return nil;
    }
}

static NSString *keyForSearchTagContent(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"_content";
        case DZNPhotoPickerControllerServiceInstagram:  return @"name";
        default:                                        return nil;
    }
}

static NSString *keyPathForObjectName(DZNPhotoPickerControllerService service, NSString *objectName)
{
    if ([objectName isEqualToString:[DZNPhotoTag name]]) {
        return tagsResourceKeyPathForService(service);
    }
    else if ([objectName isEqualToString:[DZNPhotoMetadata name]]) {
        return photosResourceKeyPathForService(service);
    }
    return nil;
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
    [params setObject:[self consumerKey] forKey:keyForAPIConsumer(self.service)];
    [params setObject:keyword forKey:keyForSearchTag(self.service)];
    
    if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        [params setObject:tagSearchUrlPathForService(self.service) forKey:@"method"];
        [params setObject:@"json" forKey:@"format"];
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
    [params setObject:[self consumerKey] forKey:keyForAPIConsumer(self.service)];
    [params setObject:keyword forKey:keyForSearchTerm(self.service)];

    if (self.service != DZNPhotoPickerControllerServiceInstagram) {
        [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
        [params setObject:[NSNumber numberWithInteger:resultPerPage] forKey:keyForSearchResultPerPage(self.service)];
    }
    
    if (self.service == DZNPhotoPickerControllerService500px) {
        [params setObject:@[[NSNumber numberWithInteger:2],[NSNumber numberWithInteger:4]] forKey:@"image_size"];
    }
    else if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        [params setObject:photoSearchUrlPathForService(self.service) forKey:@"method"];
        [params setObject:@"json" forKey:@"format"];
        [params setObject:@"photos" forKey:@"media"];
        [params setObject:[NSNumber numberWithBool:YES] forKey:@"in_gallery"];
        [params setObject:[NSNumber numberWithInteger:1] forKey:@"safe_search"];
        [params setObject:[NSNumber numberWithInteger:1] forKey:@"content_type"];
    }

    return params;
}

- (NSData *)processData:(NSData *)data
{
    if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        
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
    NSString *keyPath = keyPathForObjectName(self.service, objectName);
    NSMutableArray *objects = [NSMutableArray arrayWithArray:[json valueForKeyPath:keyPath]];
    
    if ([objectName isEqualToString:[DZNPhotoTag name]]) {
        return [DZNPhotoTag photoTagListFromService:self.service withResponse:objects];
    }
    else if ([objectName isEqualToString:[DZNPhotoMetadata name]]) {
        return [DZNPhotoMetadata photoMetadataListFromService:self.service withResponse:objects];
    }
    
    return nil;
}


#pragma mark - DZNPhotoServiceClient methods

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = tagSearchUrlPathForService(self.service);

    NSDictionary *params = [self tagsParamsWithKeyword:keyword];
    NSString *objectName = [DZNPhotoTag name];

    [self getObject:objectName path:_loadingPath params:params completion:completion];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = photoSearchUrlPathForService(self.service);

    NSDictionary *params = [self photosParamsWithKeyword:keyword page:page resultPerPage:resultPerPage];
    NSString *objectName = [DZNPhotoMetadata name];

    [self getObject:objectName path:_loadingPath params:params completion:completion];
}

- (void)getObject:(NSString *)objectName path:(NSString *)path params:(NSDictionary *)params completion:(DZNHTTPRequestCompletion)completion
{
    NSLog(@"%s\nobjectName : %@ \npath : %@\nparams: %@\n\n",__FUNCTION__, objectName, path, params);
    
    if (self.service == DZNPhotoPickerControllerServiceFlickr) path = @"";
    if (self.service == DZNPhotoPickerControllerServiceInstagram) {
        
        NSString *keyword = [params objectForKey:keyForSearchTerm(self.service)];
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
        
        if (self.service == DZNPhotoPickerControllerServiceFlickr) _loadingPath = @"";
        [self cancelAllHTTPOperationsWithMethod:@"GET" path:_loadingPath];
        
        _loadingPath = nil;
    }
}

@end

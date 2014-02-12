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


#pragma mark - DZNHTTPClient methods

- (void)searchPhotosWithKeyword:(NSString *)keyword parameters:(NSDictionary *)parameters completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = [self searchPhotosPathForService:self.service];
    [self getPath:_loadingPath parameters:parameters completion:completion];
}

- (void)searchTagsWithKeyword:(NSString *)keyword parameters:(NSDictionary *)parameters completion:(DZNHTTPRequestCompletion)completion
{
    _loadingPath = [self searchTagsPathForService:self.service];
    [self getPath:_loadingPath parameters:parameters completion:completion];
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(DZNHTTPRequestCompletion)completion
{
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id response) {
        
        if (completion) completion(response, nil);
        _loadingPath = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completion) completion(nil, error);
        _loadingPath = nil;
        
    }];
}

- (void)cancelSearch
{
    if (_loadingPath) {
        [self cancelAllHTTPOperationsWithMethod:@"GET" path:_loadingPath];
    }
}

@end

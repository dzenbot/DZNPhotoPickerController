//
//  DZNHTTPClient.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNHTTPClient.h"

static NSString *const DZNHTTPClientBaseUrl500px = @"https://api.500px.com/v1";
static NSString *const DZNHTTPClientBaseUrlFlickr = @"http://api.flickr.com/services/rest/";

@implementation DZNHTTPClient

- (instancetype)initWithService:(DZNPhotoPickerControllerService)service
{
    self = [super initWithBaseURL:[self baseURLForService:service]];
    if (self) {
        self.service = service;
    }
    return self;
}

- (NSURL *)baseURLForService:(DZNPhotoPickerControllerService)service
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return [NSURL URLWithString:DZNHTTPClientBaseUrl500px];
        case DZNPhotoPickerControllerServiceFlickr:     return [NSURL URLWithString:DZNHTTPClientBaseUrlFlickr];
        default:                                        return nil;
    }
}

@end

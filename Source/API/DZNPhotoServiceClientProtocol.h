//
//  DZNPhotoServiceClientProtocol.h
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const DZNPhotoServiceClientConsumerKey;
UIKIT_EXTERN NSString *const DZNPhotoServiceClientConsumerSecret;

UIKIT_EXTERN NSString *NSStringHashFromServiceType(DZNPhotoPickerControllerService type, NSString *key);

typedef void (^DZNHTTPRequestCompletion)(NSArray *response, NSError *error);

@protocol DZNPhotoServiceClientProtocol <NSObject>

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion;

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion;

- (void)cancelRequest;

@end

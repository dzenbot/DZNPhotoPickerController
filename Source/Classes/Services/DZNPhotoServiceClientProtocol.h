//
//  DZNPhotoServiceClientProtocol.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerControllerConstants.h"

typedef void (^DZNHTTPRequestCompletion)(NSArray *list, NSError *error);

/**
 Base HTTP photo service protocol.
 */
@protocol DZNPhotoServiceClientProtocol <NSObject>

/** The current photo service. */
@property (nonatomic) DZNPhotoPickerControllerServices service;
/** The current photo service subscription. */
@property (nonatomic) DZNPhotoPickerControllerSubscription subscription;
/** YES if the HTTP client is loading. */
@property (nonatomic, readonly) BOOL loading;

/**
 Searches for a list of tags related to a keyword string.
 
 @param keyword The tag to fetch related tags for.
 @param completion The completion block handler.
 */
- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion;

/**
 Searches for a list of photos mathing on a tag or keyword term.
 
 @param keyword The keyword term to fetch related tags for.
 @param page The current page.
 @param resultPerPage The amount of result per page.
 @param completion The completion block handler.
 */
- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion;

/**
 Cancels all HTTP request of the client.
 */
- (void)cancelRequest;

@end

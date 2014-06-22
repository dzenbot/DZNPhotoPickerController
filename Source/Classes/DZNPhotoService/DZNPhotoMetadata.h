//
//  DZNPhotoMetadata.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerControllerConstants.h"

/**
 The data model to encapsulate meta data about a photo, provided by the photo service.
 */
@interface DZNPhotoMetadata : NSObject

/** The id of the photo. */
@property (nonatomic, readonly) id Id;
/** The url of the thumb version of the photo. */
@property (nonatomic, readonly) NSURL *thumbURL;
/** The url of the full size version of the photo. */
@property (nonatomic, readonly) NSURL *sourceURL;
/** The url of the photo's source page. */
@property (nonatomic, readonly) NSURL *detailURL;
/** The author's full name. */
@property (nonatomic, readonly) NSString *authorName;
/** The author's user name. */
@property (nonatomic, readonly) NSString *authorUsername;
/** The url of the author's profile. */
@property (nonatomic, readonly) NSURL *authorProfileURL;
/** The name of the photo service. */
@property (nonatomic, readonly) NSString *serviceName;

/**
 Parses and returns a list of photo metadata from a request response.
 
 @param reponse The response with already parsed JSON.
 @param service The photo service of the response.
 @returns A list of photo metadata.
 */
+ (NSArray *)metadataListWithResponse:(NSArray *)reponse service:(DZNPhotoPickerControllerServices)service;

/**
 Returns the name of the class. It is as good as calling NSStringFromClass().
 
 @return A the name of the class.
 */
+ (NSString *)name;

@end

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
 * The data model to encapsulate meta data about a photo, provided by the photo service.
 */
@interface DZNPhotoMetadata : NSObject

/** The id of the photo. */
@property (nonatomic, copy) id Id;
/** The url of the thumb version of the photo. */
@property (nonatomic, copy) NSURL *thumbURL;
/** The url of the full size version of the photo. */
@property (nonatomic, copy) NSURL *sourceURL;
/** The url of the photo's source page. */
@property (nonatomic, copy) NSURL *detailURL;
/** The author's full name. */
@property (nonatomic, copy) NSString *authorName;
/** The author's user name. */
@property (nonatomic, copy) NSString *authorUsername;
/** The url of the author's profile. */
@property (nonatomic, copy) NSURL *authorProfileURL;
/** The name of the photo service. */
@property (nonatomic, copy) NSString *serviceName;

/**
 * Returns the name of the class. It is as good as calling NSStringFromClass().
 *
 * @return A the name of the class.
 */
+ (NSString *)name;

/**
 * Allocates a new instance of DZNPhotoMetadata, initialized with a supported photo service type.
 *
 * @param service The specific photo search service.
 * @return A new allocated instance DZNPhotoMetadata.
 */
+ (instancetype)photoMetadataFromService:(DZNPhotoPickerControllerServices)service;

/**
 * Parses and returns a list of photo metadata from a request response.
 *
 * @param service The photo service of the response.
 * @param reponse The response with already parsed JSON.
 * @returns A list of photo metadata.
 */
+ (NSArray *)photoMetadataListFromService:(DZNPhotoPickerControllerServices)service withResponse:(NSArray *)reponse;

@end

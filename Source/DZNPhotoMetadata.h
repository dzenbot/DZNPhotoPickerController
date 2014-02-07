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
#import "DZNPhotoPickerConstants.h"

/*
 * The data model to encapsulate meta data about a photo, provided by the photo service.
 */
@interface DZNPhotoMetadata : NSObject

/* The id of the photo. */
@property (nonatomic, copy) NSNumber *id;
/* The title of the photo assigned by the author. */
@property (nonatomic, copy) NSString *title;
/* The url of the thumb version of the photo. */
@property (nonatomic, copy) NSURL *thumbURL;
/* The url of the full size version of the photo. */
@property (nonatomic, copy) NSURL *fullURL;
/* The url of the photo's source page. */
@property (nonatomic, copy) NSURL *detailURL;
/* The author's full name. */
@property (nonatomic, copy) NSString *fullName;
/* The author's user name. */
@property (nonatomic, copy) NSString *userName;
/* The url of the author's profile. */
@property (nonatomic, copy) NSURL *profileURL;
/* The name of the photo service. */
@property (nonatomic, copy) NSString *serviceName;

/*
 Allocates a new instance of DZNPhotoMetadata, initialized with a valid service name.
 */
+ (instancetype)photosMetadataFromService:(DZNPhotoPickerControllerService)service;

/*
 * Parsed and returns a list of photo metadata from a request response.
 *
 * @param service The source service of the response.
 * @param reponse The response with already parsed JSON.
 *
 * @returns A list of new photos metadata.
 */
+ (NSArray *)photosMetadataFromService:(DZNPhotoPickerControllerService)service withResponse:(NSArray *)reponse;


@end

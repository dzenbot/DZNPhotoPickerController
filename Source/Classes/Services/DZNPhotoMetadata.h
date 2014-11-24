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
@interface DZNPhotoMetadata : NSObject <NSCoding>

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
/** The MIME content-type of the image. */
@property (nonatomic, readonly) NSString *contentType;
/** The height of the photo. */
@property (nonatomic, readonly) NSNumber *height;
/** The width of the photo. */
@property (nonatomic, readonly) NSNumber *width;

/**
 Initializes a new photo metadata instance with request response.
 
 @param object A JSON object.
 @param service The photo service of the response.
 @returns A of photo metadata instance.
 */
- (instancetype)initWithObject:(NSDictionary *)object service:(DZNPhotoPickerControllerServices)service;

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

/**
 Proxy class method to be called whenever the user picks a photo, with or without editing the image.
 This is a reserved method to be used internally by DZNPhotoPickerController.
 
 @param originalImage The original image before edition.
 @param editedImage The image result after edition.
 @param cropRect The applied rectangle on the cropping. If no edited, the default value is CGRectZero.
 @param zoomScale The applied zoom scale on the cropping. If no edited, the default value is 1.0
 @param cropMode The crop mode being used.
 @param photoDescription The photo metadata.
 */
- (void)postMetadataUpdate:(NSDictionary *)userInfo;

@end

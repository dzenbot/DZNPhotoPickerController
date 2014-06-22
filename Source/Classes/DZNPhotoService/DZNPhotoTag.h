//
//  DZNPhotoTag.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/13/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerControllerConstants.h"

@interface DZNPhotoTag : NSObject

/** The string term. */
@property (nonatomic, readonly) NSString *term;
/** The string name equivalent to the photo service. */
@property (nonatomic, readonly) NSString *serviceName;

/**
 Allocates a new instance of DZNPhotoTag, initialized with a supported photo service type.
 
 @param term The tag term.
 @param service The specific photo search service.
 @return A new allocated instance DZNPhotoTag.
 */
+ (instancetype)newTagWithTerm:(NSString *)term service:(DZNPhotoPickerControllerServices)service;

/**
 Parses and returns a list of photo tags from a request response.
 
 @param service The photo service of the response.
 @param reponse The response with already parsed JSON.
 @returns A list of photo tags.
 */
+ (NSArray *)photoTagListFromService:(DZNPhotoPickerControllerServices)service withResponse:(NSArray *)reponse;

/**
 Returns the name of the class. It is as good as calling NSStringFromClass().
 
 @return A the name of the class.
 */
+ (NSString *)name;

@end

//
//  DZNPhotoDescription.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

/*
 * The data model to encapsulate meta data about a photo, provided by the photo service.
 */
@interface DZNPhotoDescription : NSObject

/* The title assigned by the author. */
@property (nonatomic, copy) NSString *title;
/* The name of the author. */
@property (nonatomic, copy) NSString *authorName;
/* The url of the thumb version. */
@property (nonatomic, copy) NSURL *thumbURL;
/* The url of the full size version. */
@property (nonatomic, copy) NSURL *fullURL;
/* The name of the photo service. */
@property (nonatomic, copy) NSString *sourceName;

/*
 * Allocates a new instance of the DZNPhotoDescription class, sends it an init message, and returns the initialized object with property values.
 *
 * @param title The title assigned by the author.
 * @param authorName The name of the author.
 * @param thumbURL The url of the thumb version.
 * @param fullURL The url of the full size version.
 * @param sourceName The name of the photo service.
 */
+ (instancetype)photoDescriptionWithTitle:(NSString *)title
                               authorName:(NSString *)authorName
                                 thumbURL:(NSURL *)thumbURL
                                  fullURL:(NSURL *)fullURL
                               sourceName:(NSString *)sourceName;

@end

//
//  DZNPhotoDescription.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoDescription.h"

@implementation DZNPhotoDescription

+ (instancetype)photoDescriptionWithTitle:(NSString *)title authorName:(NSString *)authorName thumbURL:(NSURL *)thumbURL fullURL:(NSURL *)fullURL sourceName:(NSString *)sourceName
{
    DZNPhotoDescription *photo = [DZNPhotoDescription new];
    photo.title = title;
    photo.authorName = authorName;
    photo.thumbURL = thumbURL;
    photo.fullURL = fullURL;
    photo.sourceName = sourceName;
    return photo;
}

@end

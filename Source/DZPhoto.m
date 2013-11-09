//
//  DZPhoto.m
//  DZPhotoPickerController
//  https://github.com/dzenbot/DZPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZPhoto.h"

@implementation DZPhoto

+ (instancetype)newPhotoWithTitle:(NSString *)title authorName:(NSString *)authorName thumbURL:(NSURL *)thumbURL fullURL:(NSURL *)fullURL sourceName:(NSString *)sourceName
{
    DZPhoto *photo = [DZPhoto new];
    photo.title = title;
    photo.authorName = authorName;
    photo.thumbURL = thumbURL;
    photo.fullURL = fullURL;
    photo.sourceName = sourceName;
    return photo;
}

@end

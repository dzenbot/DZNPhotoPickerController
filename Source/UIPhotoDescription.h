//
//  UIPhotoDescription.h
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

@interface UIPhotoDescription : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSURL *thumbURL;
@property (nonatomic, copy) NSURL *fullURL;
@property (nonatomic, copy) NSString *sourceName;

+ (instancetype)photoDescriptionWithTitle:(NSString *)title
                               authorName:(NSString *)authorName
                                 thumbURL:(NSURL *)thumbURL
                                  fullURL:(NSURL *)fullURL
                               sourceName:(NSString *)sourceName;

@end

//
//  DZPhoto.h
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZPhoto : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSURL *thumbURL;
@property (nonatomic, copy) NSURL *fullURL;
@property (nonatomic, copy) NSString *sourceName;

+ (instancetype)newPhotoWithTitle:(NSString *)title authorName:(NSString *)authorName thumbURL:(NSURL *)thumbURL fullURL:(NSURL *)fullURL sourceName:(NSString *)sourceName;

@end

//
//  DZNPhotoCollectionViewLayout.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

/**
 A custom collection view layout allowing to display floating headers.
 */
@interface DZNPhotoCollectionViewLayout : UICollectionViewFlowLayout

/**
 Creates a new layout fitting a specific width, and honoring a minimum column count.
 
 @param width The fitting width used to compute the amount of items. (required)
 @param columnCount The minimum column count. (required)
 @return A new DZNPhotoCollectionViewLayout instance.
 */
+ (instancetype)layoutFittingWidth:(CGFloat)width columnCount:(NSUInteger)columnCount;

@end

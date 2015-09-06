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

@interface DZNPhotoCollectionViewLayout : UICollectionViewFlowLayout

+ (instancetype)layoutFittingWidth:(CGFloat)width columnCount:(NSUInteger)columnCount;

@end

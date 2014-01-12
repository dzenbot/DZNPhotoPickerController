//
//  DZNPhotoDisplayViewCell.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

/*
 * The collection view cell to be displayed on search results, with photo thumbnail.
 */
@interface DZNPhotoDisplayViewCell : UICollectionViewCell

/* The image view of the table cell. (read-only). */
@property(nonatomic, readonly, retain) UIImageView *imageView;

@end
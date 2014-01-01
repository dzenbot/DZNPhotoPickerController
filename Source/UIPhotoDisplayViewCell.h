//
//  UIPhotoDisplayViewCell.h
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

/*
 * The custom collection view cell to be displayed on search results.
 */
@interface UIPhotoDisplayViewCell : UICollectionViewCell

/* The image view of the table cell. (read-only). */
@property(nonatomic, readonly, retain) UIImageView *imageView;

@end
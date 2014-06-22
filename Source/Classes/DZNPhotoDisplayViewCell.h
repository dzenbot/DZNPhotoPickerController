//
//  DZNPhotoDisplayViewCell.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

/**
 The collection view cell to be displayed on search results, with photo thumbnail.
 */
@interface DZNPhotoDisplayViewCell : UICollectionViewCell

/** The image view of the cell. (read-only). */
@property (nonatomic, readonly) UIImageView *imageView;

/**
 Sets the thumbnail URL for download. This also forces cancellation of previous image download.
 
 @param URL The image url.
 */
- (void)setThumbURL:(NSURL *)URL;

@end
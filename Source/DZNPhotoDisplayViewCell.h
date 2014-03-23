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
 * The collection view cell to be displayed on search results, with photo thumbnail.
 */
@interface DZNPhotoDisplayViewCell : UICollectionViewCell

/** The cell's collection view. */
@property (nonatomic, weak) UICollectionView *superCollectionView;
/** The image view of the cell. (read-only). */
@property (nonatomic, readonly, strong) UIImageView *imageView;
/** The title label of the table cell. (read-only). */
@property (nonatomic, readonly, strong) UILabel *titleLabel;
/** The detail label of the cell. (read-only). */
@property (nonatomic, readonly, strong) UILabel *detailLabel;

- (void)setThumbURL:(NSURL *)URL;
- (void)setEmptyDataSetVisible:(BOOL)display;

@end
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

/** Sets the thumbnail URL for download. This also forces cancellation of previous image download.
 *
 * @param URL The image url.
 */
- (void)setThumbURL:(NSURL *)URL;

/** Toggles the cell to be used for displaying an empty data set.
 *
 * @param display YES if the data set should be visible.
 */
- (void)setEmptyDataSetVisible:(BOOL)display;

@end
//
//  DZPhotoCell.h
//  DZPhotoPickerController
//  https://github.com/dzenbot/DZPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

#import "DZPhotoDisplayController.h"

@interface DZPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) DZPhotoDisplayController *photoDisplayController;

@end

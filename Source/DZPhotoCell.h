//
//  DZPhotoCell.h
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

#import "DZPhotoDisplayController.h"

@interface DZPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) DZPhotoDisplayController *photoDisplayController;

@end

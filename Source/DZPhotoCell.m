//
//  DZPhotoCell.m
//  DZPhotoPickerController
//  https://github.com/dzenbot/DZPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZPhotoCell.h"

@implementation DZPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundView = self.imageView;
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        self.exclusiveTouch = YES;
    }
    return self;
}


#pragma mark - Getter methods

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}


#pragma mark - UIView methods

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView cancelCurrentImageLoad];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end

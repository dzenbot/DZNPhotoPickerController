//
//  UIPhotoDisplayViewCell.m
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "UIPhotoDisplayViewCell.h"

@implementation UIPhotoDisplayViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundView = self.imageView;
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
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
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
    }
    return _imageView;
}


#pragma mark - UIView methods

- (void)setSelected:(BOOL)selected
{
    if (_imageView.image) {
        [super setSelected:selected];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (_imageView.image) {
        [super setHighlighted:highlighted];
    }
}

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

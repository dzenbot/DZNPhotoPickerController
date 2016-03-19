//
//  DZNPhotoDisplayViewCell.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoDisplayViewCell.h"
#import "UIImageView+WebCache.h"

@implementation DZNPhotoDisplayViewCell
@synthesize imageView = _imageView;

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
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
    }
    return _imageView;
}


#pragma mark - Setter methods

- (void)setThumbURL:(NSURL *)URL
{
    [self.imageView sd_cancelCurrentImageLoad];
    
    [self.imageView sd_setImageWithURL:URL
                      placeholderImage:nil
                               options:SDWebImageCacheMemoryOnly
                             completed:NULL];
}


#pragma mark - UIView methods

- (void)setSelected:(BOOL)selected
{
    if (_imageView.image) {
        [UIView animateWithDuration:0.2 animations:^{
            [super setSelected:selected];
        }];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (_imageView.image) {
        [UIView animateWithDuration:0.2 animations:^{
            [super setHighlighted:highlighted];
        }];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView sd_cancelCurrentImageLoad];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}


#pragma mark - View lifeterm

- (void)dealloc
{
    _imageView.image = nil;
    _imageView = nil;
}

@end

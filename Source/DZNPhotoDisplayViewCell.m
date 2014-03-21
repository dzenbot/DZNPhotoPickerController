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

@implementation DZNPhotoDisplayViewCell
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize detailLabel = _detailLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundView = self.imageView;
        
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
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 170.0, [UIScreen mainScreen].bounds.size.width-(30.0*2), 30.0)];
        _titleLabel.font = [UIFont systemFontOfSize:27.0];
        _titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+12.0, [UIScreen mainScreen].bounds.size.width-(30.0*2), 44.0)];
        _detailLabel.font = [UIFont systemFontOfSize:17.0];
        _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 2;
        
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (BOOL)usedForEmptyDataSet
{
    return (self.tag == 0 && _titleLabel.text) ? YES : NO;
}


#pragma mark - Setter methods

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    
    if (!_titleLabel) [self.contentView addSubview:self.titleLabel];
    if (!_detailLabel) [self.contentView addSubview:self.detailLabel];
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

    self.titleLabel.hidden = [self usedForEmptyDataSet] ? NO : YES;
    self.detailLabel.hidden = [self usedForEmptyDataSet] ? NO : YES;
    self.imageView.hidden = [self usedForEmptyDataSet] ? YES : NO;
    self.backgroundView.backgroundColor = [self usedForEmptyDataSet] ? [UIColor clearColor] : [UIColor colorWithWhite:0.9 alpha:1.0];
}


#pragma mark - View lifeterm

- (void)dealloc
{
    _imageView.image = nil;
    _imageView = nil;
}

@end

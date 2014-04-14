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

#define DZNPhotoDisplayViewCellMargin 30.0

@implementation DZNPhotoDisplayViewCell
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize detailLabel = _detailLabel;

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
        _titleLabel = [[UILabel alloc] init];
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
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:17.0];
        _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 2;
        
        [self.contentView addSubview:_detailLabel];
        [self layoutLabels];
    }
    return _detailLabel;
}


#pragma mark - Getter methods

- (void)setThumbURL:(NSURL *)URL
{
    [self.imageView cancelCurrentImageLoad];
    
    [self.imageView setImageWithURL:URL
                   placeholderImage:nil
                            options:SDWebImageCacheMemoryOnly
                          completed:NULL];
}

- (void)setEmptyDataSetVisible:(BOOL)visible
{
    if (visible) [self displayEmptyDataSet];
    else [self clearEmptyDataSet];
}


#pragma mark - DZNPhotoDisplayViewCell methods

- (void)displayEmptyDataSet
{
    if (self.imageView.hidden) {
        return;
    }
    
    self.titleLabel.text = NSLocalizedString(@"No Photos Found", nil);
    self.titleLabel.hidden = NO;

    self.detailLabel.text = NSLocalizedString(@"Make sure that all words are spelled correctly.", nil);
    self.detailLabel.hidden = NO;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    
    self.superCollectionView.scrollEnabled = NO;
    self.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)clearEmptyDataSet
{
    if (!self.imageView.hidden) {
        return;
    }
    
    self.titleLabel.text = nil;
    self.titleLabel.hidden = YES;

    self.detailLabel.text = nil;
    self.detailLabel.hidden = YES;
    
    self.imageView.hidden = NO;
    
    self.superCollectionView.scrollEnabled = YES;
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
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

- (void)layoutLabels
{
    CGFloat dataSetHeight = _titleLabel.frame.size.height + _detailLabel.frame.size.height + DZNPhotoDisplayViewCellMargin/2;
    CGFloat superviewHeight = _superCollectionView.bounds.size.height + _superCollectionView.bounds.origin.y;
    
    CGRect titleRect = CGRectMake(DZNPhotoDisplayViewCellMargin, 0, _superCollectionView.frame.size.width-(DZNPhotoDisplayViewCellMargin*2), DZNPhotoDisplayViewCellMargin);
    titleRect.origin.y = roundf((superviewHeight-dataSetHeight)/2)-10.0;
    _titleLabel.frame = titleRect;
    
    CGRect detailRect = CGRectMake(DZNPhotoDisplayViewCellMargin, 0, _superCollectionView.frame.size.width-(DZNPhotoDisplayViewCellMargin*2), 44.0);
    detailRect.origin.y = roundf(_titleLabel.frame.origin.y+_titleLabel.frame.size.height+DZNPhotoDisplayViewCellMargin/2);
    _detailLabel.frame = detailRect;
}


#pragma mark - View lifeterm

- (void)dealloc
{
    _imageView.image = nil;
    _imageView = nil;
    _titleLabel = nil;
    _detailLabel = nil;
}

@end

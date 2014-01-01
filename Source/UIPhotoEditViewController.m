//
//  UIPhotoEditViewController.m
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "UIPhotoEditViewController.h"
#import "UIPhotoPickerController.h"
#import "UIPhotoDisplayViewController.h"
#import "UIPhotoDescription.h"

#import "UIImageView+WebCache.h"

#define kInnerEdgeInset 15.0

@interface UIPhotoEditViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation UIPhotoEditViewController
@synthesize photo = _photo;
@synthesize cropMode = _cropMode;
@synthesize cropSize = _cropSize;

- (instancetype)initWithCropMode:(UIPhotoEditViewControllerCropMode)mode;
{
    self = [super init];
    if (self) {
        _cropMode = mode;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bottomView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = CGPointMake(roundf(_bottomView.frame.size.width/2), roundf(_bottomView.frame.size.height/2));
    [activityIndicatorView startAnimating];
    [_bottomView addSubview:activityIndicatorView];
    
    __weak UIButton *_button = _acceptButton;
    __weak UIPhotoEditViewController *_self = self;
    
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:[self overlayMask]];
    [self.view insertSubview:maskImageView aboveSubview:_scrollView];

    [_imageView setImageWithURL:_photo.fullURL placeholderImage:nil
                        options:SDWebImageCacheMemoryOnly|SDWebImageProgressiveDownload|SDWebImageRetryFailed
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                          if (!error) [_button setEnabled:YES];
                          [activityIndicatorView removeFromSuperview];
                          
                          [_self updateScrollViewContentInset];
                      }];
}

- (void)updateScrollViewContentInset
{
    CGFloat maskHeight = 0;
    if (_cropMode == UIPhotoEditViewControllerCropModeCircular) maskHeight = [self circularDiameter];
    else maskHeight = [self cropSize].height;
    
    CGSize imageSize = [self imageSize];
    
    CGFloat hInset = (_cropMode == UIPhotoEditViewControllerCropModeCircular) ? kInnerEdgeInset : 0.0;
    CGFloat vInset = (maskHeight-imageSize.height)/2;
    
    NSLog(@"hInset : %f", hInset);
    NSLog(@"vInset : %f", vInset);
    NSLog(@"imageSize : %@", NSStringFromCGSize(imageSize));
    
    _scrollView.contentInset =  UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Getter methods

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.minimumZoomScale = 1.002;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_scrollView addSubview:_imageView];
        [_scrollView setZoomScale:_scrollView.minimumZoomScale];
    }
    return _scrollView;
}

- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-72.0, self.view.bounds.size.width, 72.0)];
        
        _cancelButton = [self buttonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [_cancelButton addTarget:self action:@selector(cancelEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_cancelButton];
        
        _acceptButton = [self buttonWithTitle:NSLocalizedString(@"Choose", nil)];
        [_acceptButton addTarget:self action:@selector(acceptEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_acceptButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_acceptButton setEnabled:NO];
        [_bottomView addSubview:_acceptButton];
        
        CGRect rect = _cancelButton.frame;
        rect.origin = CGPointMake(13.0, roundf(_bottomView.frame.size.height/2-_cancelButton.frame.size.height/2));
        [_cancelButton setFrame:rect];
        
        rect = _acceptButton.frame;
        rect.origin = CGPointMake(roundf(_bottomView.frame.size.width-_acceptButton.frame.size.width-13.0), roundf(_bottomView.frame.size.height/2-_acceptButton.frame.size.height/2));
        [_acceptButton setFrame:rect];
        
        if (_cropMode == UIPhotoEditViewControllerCropModeCircular) {
            UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            topLabel.text = NSLocalizedString(@"Move and Scale", nil);
            topLabel.textColor = [UIColor whiteColor];
            topLabel.font = [UIFont systemFontOfSize:18.0];
            [topLabel sizeToFit];
            
            rect = topLabel.frame;
            rect.origin = CGPointMake(self.view.bounds.size.width/2-rect.size.width/2, 64.0);
            topLabel.frame = rect;
            [self.view addSubview:topLabel];
        }
    }
    return _bottomView;
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 0)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [button sizeToFit];
    return button;
}

- (CGSize)cropSize
{
    CGSize viewSize = self.view.bounds.size;
    
    switch (_cropMode) {
        case UIPhotoEditViewControllerCropModeCustom:
            if (CGSizeEqualToSize(_cropSize, CGSizeZero) ) {
                return CGSizeMake(viewSize.width, viewSize.width);
            }
            else {
                if (viewSize.height > 0 && _cropSize.height > viewSize.height) {
                    _cropSize.height = viewSize.height;
                }
                return _cropSize;
            }
            
        case UIPhotoEditViewControllerCropModeSquare:
        case UIPhotoEditViewControllerCropModeCircular:
        default:
            return CGSizeMake(viewSize.width, viewSize.width);
    }
}

- (CGRect)cropRect
{
    CGSize viewSize = self.navigationController.view.bounds.size;
    CGSize cropSize = [self cropSize];
    CGFloat verticalMargin = (viewSize.height-cropSize.height)/2;
    return CGRectMake(0.0, verticalMargin, cropSize.width, cropSize.height);
}

- (CGFloat)circularDiameter
{
    CGSize viewSize = self.navigationController.view.bounds.size;
    return viewSize.width-(kInnerEdgeInset*2);
}

- (CGSize)imageSize
{
    return CGSizeAspectFit(_imageView.image.size,_imageView.frame.size);
}

CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize)
{
    NSLog(@"aspectRatio : %@", NSStringFromCGSize(aspectRatio));
    NSLog(@"boundingSize : %@", NSStringFromCGSize(boundingSize));
    
    float hRatio = boundingSize.width / aspectRatio.width;
    float vRation = boundingSize.height / aspectRatio.height;
    if (hRatio < vRation) {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    }
    else if (vRation < hRatio) {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    }
    return boundingSize;
}

- (UIImage *)overlayMask
{
    switch (_cropMode) {
        case UIPhotoEditViewControllerCropModeSquare:
        case UIPhotoEditViewControllerCropModeCustom:
            return [self squareOverlayMask];
            
        case UIPhotoEditViewControllerCropModeCircular:
            return [self circularOverlayMask];
            
        default:
            return nil;
    }
}

- (UIImage *)squareOverlayMask
{
    // Constant sizes
    CGSize size = self.navigationController.view.bounds.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat margin = (height-[self cropSize].height)/2;
    CGFloat lineWidth = 1.0;
    
    // Create a UIBezierPath
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // Color Declarations
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIColor *strokeColor = [UIColor colorWithWhite:1.0 alpha:0.5];

    // Bezier Drawing
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(width, margin)];
    [maskPath addLineToPoint:CGPointMake(0, margin)];
    [maskPath addLineToPoint:CGPointMake(0, 0)];
    [maskPath addLineToPoint:CGPointMake(width, 0)];
    [maskPath addLineToPoint:CGPointMake(width, margin)];
    [maskPath closePath];
    [maskPath moveToPoint:CGPointMake(width, height)];
    [maskPath addLineToPoint:CGPointMake(0, height)];
    [maskPath addLineToPoint:CGPointMake(0, [self cropSize].height+margin)];
    [maskPath addLineToPoint:CGPointMake(width, [self cropSize].height+margin)];
    [maskPath addLineToPoint:CGPointMake(width, height)];
    [maskPath closePath];
    [fillColor setFill];
    [maskPath fill];
    
    // Crop square Drawing
    CGRect cropRect = CGRectMake(lineWidth/2, margin+lineWidth/2, width-lineWidth, [self cropSize].height-lineWidth);
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:cropRect];
    [strokeColor setStroke];
    cropPath.lineWidth = lineWidth;
    [cropPath stroke];
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)circularOverlayMask
{
    // Constant sizes
    CGSize size = self.navigationController.view.bounds.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat diameter = width-(kInnerEdgeInset*2);
    CGFloat radius = diameter/2;
    CGPoint center = CGPointMake(width/2, height/2);
    
    // Create a UIBezierPath
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // Color Declarations
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];

    // Arc Bezier Drawing
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.navigationController.view.bounds];
    [maskPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:NO];
    [maskPath closePath];
    [fillColor setFill];
    [maskPath fill];
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)editedPhoto
{
    UIImage *_image = nil;
    
    // Constant sizes
    CGSize viewSize = self.navigationController.view.bounds.size;
    CGRect cropRect = [self cropRect];

    CGFloat verticalMargin = (viewSize.height-cropRect.size.height)/2;

    cropRect.origin.x = -_scrollView.contentOffset.x;
    cropRect.origin.y = -_scrollView.contentOffset.y - verticalMargin;

    UIGraphicsBeginImageContextWithOptions(cropRect.size, NO, 0);{
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, cropRect.origin.x, cropRect.origin.y);
        [_scrollView.layer renderInContext:context];
        
        _image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    if (_cropMode == UIPhotoEditViewControllerCropModeCircular) {
        
        CGFloat diameter = [self circularDiameter];
        CGRect roundedRect = CGRectMake(0, 0, diameter, diameter);
        
        UIGraphicsBeginImageContextWithOptions(roundedRect.size, NO, 0.0);{
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:roundedRect];
            [bezierPath addClip];
            
            // Draw the image
            [_image drawInRect:CGRectMake(0, -kInnerEdgeInset, 320, 320)];
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGPathRef path = [bezierPath CGPath];
            CGContextAddPath(context, path);
            
            _image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }

    return _image;
}


#pragma mark - Setter methods

- (void)setCropSize:(CGSize)cropSize
{
    CGSize viewSize = self.view.bounds.size;
    CGFloat cropHeight = roundf((cropSize.height * viewSize.width) / cropSize.width);
    _cropSize = CGSizeMake(cropSize.width, cropHeight);
}


#pragma mark - UIPhotoEditViewController methods

+ (void)didFinishPickingEditedImage:(UIImage *)editedImage
                       withCropRect:(CGRect)cropRect
                  fromOriginalImage:(UIImage *)originalImage
                       referenceURL:(NSURL *)referenceURL
                         authorName:(NSString *)authorName
                         sourceName:(NSString *)sourceName
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [NSValue valueWithCGRect:cropRect],UIImagePickerControllerCropRect,
                                     @"public.image",UIImagePickerControllerMediaType,
                                     nil];

    if (editedImage != nil) [userInfo setObject:editedImage forKey:UIImagePickerControllerEditedImage];
    if (originalImage != nil) [userInfo setObject:originalImage forKey:UIImagePickerControllerOriginalImage];
    if (referenceURL != nil) [userInfo setObject:referenceURL.absoluteString forKey:UIImagePickerControllerReferenceURL];
    if (authorName != nil) [userInfo setObject:authorName forKey:UIPhotoPickerControllerAuthorCredits];
    if (sourceName != nil) [userInfo setObject:sourceName forKey:UIPhotoPickerControllerSourceName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUIPhotoPickerDidChooseNotification object:nil userInfo:userInfo];
}

- (void)acceptEdition:(id)sender
{
    [UIPhotoEditViewController didFinishPickingEditedImage:[self editedPhoto]
                                              withCropRect:[self cropRect]
                                         fromOriginalImage:_imageView.image
                                              referenceURL:_photo.fullURL
                                                authorName:_photo.authorName
                                                sourceName:_photo.sourceName];
}

- (void)cancelEdition:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UIScrollViewDelegate
#pragma mark Responding to Scrolling and Dragging

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark Managing Zooming

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self updateScrollViewContentInset];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
}

#pragma mark Responding to Scrolling Animations

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    _imageView.image = nil;
    _imageView = nil;
    _scrollView = nil;
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

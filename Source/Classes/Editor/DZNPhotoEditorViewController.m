//
//  DZNPhotoEditorViewController.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoEditorViewController.h"

#define DZN_IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define DZN_IS_IOS8 [[UIDevice currentDevice].systemVersion floatValue] > 8.0

typedef NS_ENUM(NSInteger, DZNPhotoAspect) {
    DZNPhotoAspectUnknown,
    DZNPhotoAspectSquare,
    DZNPhotoAspectVerticalRectangle,
    DZNPhotoAspectHorizontalRectangle
};

@interface DZNPhotoEditorContainerView : UIView
@end

@implementation DZNPhotoEditorContainerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([self.subviews containsObject:view]) {
        return view;
    }
    else if ([view isEqual:self]) {
        return nil;
    }
    return view;
}

@end

@interface DZNPhotoEditorViewController () <UIScrollViewDelegate>

/** An optional UIImage use for displaying the already existing full size image. */
@property (nonatomic, copy) UIImage *editingImage;

/** The scrollview containing the image for allowing panning and zooming. */
@property (nonatomic, readonly) UIScrollView *scrollView;
/** The container for the mask guide image. */
@property (nonatomic, readonly) UIImageView *maskView;
/** The view layed out at the bottom for displaying action buttons. */
@property (nonatomic, readonly) DZNPhotoEditorContainerView *bottomView;

/** The last registered zoom scale. */
@property (nonatomic) CGFloat lastZoomScale;

@end

@implementation DZNPhotoEditorViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize maskView = _maskView;
@synthesize bottomView = _bottomView;
@synthesize activityIndicator = _activityIndicator;
@synthesize cropSize = _cropSize;
@synthesize rightButton = _rightButton;
@synthesize leftButton = _leftButton;

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.editingImage = image;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    if (DZN_IS_IPAD) {
        self.title = NSLocalizedString(@"Edit Photo", nil);
    }
    else {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_scrollView.superview) {
        return;
    }
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.bottomView];
    
    self.imageView.image = self.editingImage;
    [self.view insertSubview:self.maskView aboveSubview:self.scrollView];
    
    NSDictionary *views = @{@"bottomView": self.bottomView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(88)]|" options:0 metrics:nil views:views]];
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!DZN_IS_IPAD) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!DZN_IS_IPAD) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    else if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationItem.hidesBackButton = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    if (!DZN_IS_IPAD) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
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
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        [_scrollView setZoomScale:_scrollView.minimumZoomScale];
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {        
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _imageView;
}

- (UIImageView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIImageView alloc] initWithImage:[self overlayMask]];
        _maskView.userInteractionEnabled = NO;
    }
    return _maskView;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [self buttonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [_leftButton addTarget:self action:@selector(cancelEdition:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [self buttonWithTitle:NSLocalizedString(@"Choose", nil)];
        [_rightButton addTarget:self action:@selector(acceptEdition:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (DZNPhotoEditorContainerView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [DZNPhotoEditorContainerView new];
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomView.tintColor = [UIColor whiteColor];
        _bottomView.userInteractionEnabled = YES;
        
        NSMutableDictionary *views = [NSMutableDictionary new];
        NSDictionary *metrics = @{@"hmargin" : @(13), @"barsHeight": @(self.barsHeight)};
        
        if (DZN_IS_IPAD) {
            if (self.navigationController.viewControllers.count == 1) {
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
            }

            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
        }
        else {
            self.leftButton.translatesAutoresizingMaskIntoConstraints = NO;
            self.rightButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            [_bottomView addSubview:self.leftButton];
            [_bottomView addSubview:self.rightButton];
            
            [views setObject:self.leftButton forKey:@"leftButton"];
            [views setObject:self.rightButton forKey:@"rightButton"];
            
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hmargin-[leftButton]" options:0 metrics:metrics views:views]];
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightButton]-hmargin-|" options:0 metrics:metrics views:views]];
            
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftButton]|" options:0 metrics:metrics views:views]];
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightButton]|" options:0 metrics:metrics views:views]];
        }
        
        if (self.cropMode == DZNPhotoEditorViewControllerCropModeCircular)
        {
            UILabel *topLabel = [UILabel new];
            topLabel.translatesAutoresizingMaskIntoConstraints = NO;
            topLabel.textColor = [UIColor whiteColor];
            topLabel.textAlignment = NSTextAlignmentCenter;
            topLabel.font = [UIFont systemFontOfSize:18.0];
            topLabel.text = NSLocalizedString(@"Move and Scale", nil);
            [self.view addSubview:topLabel];
            
            NSDictionary *labels = @{@"label" : topLabel};
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|" options:0 metrics:nil views:labels]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-barsHeight-[label]" options:0 metrics:metrics views:labels]];
        }
        
        if (!_imageView.image)
        {
            [_bottomView addSubview:self.activityIndicator];
            
            [views setObject:self.activityIndicator forKey:@"activityIndicator"];
            
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activityIndicator]|" options:0 metrics:nil views:views]];
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[activityIndicator]|" options:0 metrics:metrics views:views]];
        }
    }
    return _bottomView;
}
    
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.color = [UIColor whiteColor];
    }
    return _activityIndicator;
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];
    [button setUserInteractionEnabled:YES];
    [button sizeToFit];
    return button;
}

- (CGSize)cropSize
{
    CGSize viewSize = (!DZN_IS_IPAD) ? self.view.bounds.size : self.navigationController.preferredContentSize;
    
    if (self.cropMode == DZNPhotoEditorViewControllerCropModeCustom) {
        CGFloat cropHeight = roundf((_cropSize.height * viewSize.width) / _cropSize.width);
        if (cropHeight > viewSize.height) {
            cropHeight = viewSize.height;
        }
        return CGSizeMake(_cropSize.width, cropHeight);
    }
    else {
        return CGSizeMake(viewSize.width, viewSize.width);
    }
}

- (CGRect)guideRect
{
    CGFloat margin = (CGRectGetHeight(self.navigationController.view.bounds)-self.cropSize.height)/2;
    return CGRectMake(0.0, margin, self.cropSize.width, self.cropSize.height);
}

- (CGFloat)innerInset
{
    return 15.0;
}

- (CGFloat)barsHeight
{
    CGFloat height = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    height += CGRectGetHeight(self.navigationController.navigationBar.frame);
    return height;
}

CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize)
{
    CGFloat hRatio = boundingSize.width / aspectRatio.width;
    CGFloat vRation = boundingSize.height / aspectRatio.height;
    if (hRatio < vRation) {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    }
    else if (vRation < hRatio) {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    }
    return boundingSize;
}

DZNPhotoAspect photoAspectFromSize(CGSize aspectRatio)
{
    if (aspectRatio.width > aspectRatio.height) {
        return DZNPhotoAspectHorizontalRectangle;
    }
    else if (aspectRatio.width < aspectRatio.height) {
        return DZNPhotoAspectVerticalRectangle;
    }
    else if (aspectRatio.width == aspectRatio.height) {
        return DZNPhotoAspectSquare;
    }
    else {
        return DZNPhotoAspectUnknown;
    }
}

- (UIImage *)overlayMask
{
    switch (self.cropMode) {
        case DZNPhotoEditorViewControllerCropModeNone:
        case DZNPhotoEditorViewControllerCropModeSquare:
        case DZNPhotoEditorViewControllerCropModeCustom:        return [self squareOverlayMask];
        case DZNPhotoEditorViewControllerCropModeCircular:      return [self circularOverlayMask];
    }
}

/*
 The square overlay mask image to be displayed on top of the photo as cropping guideline.
 Created with PaintCode. The source file is available inside of the Resource folder.
 */
- (UIImage *)squareOverlayMask
{
    // Constants
    CGRect bounds = self.navigationController.view.bounds;
    
    CGFloat width = self.cropSize.width;
    CGFloat height = self.cropSize.height;
    CGFloat margin = (bounds.size.height-self.cropSize.height)/2;
    CGFloat lineWidth = 1.0;
    
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);

    // Create the bezier path & drawing
    UIBezierPath *clipPath = [UIBezierPath bezierPath];
    [clipPath moveToPoint:CGPointMake(width, margin)];
    [clipPath addLineToPoint:CGPointMake(0, margin)];
    [clipPath addLineToPoint:CGPointMake(0, 0)];
    [clipPath addLineToPoint:CGPointMake(width, 0)];
    [clipPath addLineToPoint:CGPointMake(width, margin)];
    [clipPath closePath];
    [clipPath moveToPoint:CGPointMake(width, CGRectGetHeight(bounds))];
    [clipPath addLineToPoint:CGPointMake(0, CGRectGetHeight(bounds))];
    [clipPath addLineToPoint:CGPointMake(0, margin+height)];
    [clipPath addLineToPoint:CGPointMake(width, margin+height)];
    [clipPath addLineToPoint:CGPointMake(width, CGRectGetHeight(bounds))];
    [clipPath closePath];
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    [clipPath fill];
    
    // Add the square crop
    CGRect rect = CGRectMake(lineWidth/2, margin+lineWidth/2, width-lineWidth, self.cropSize.height-lineWidth);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor colorWithWhite:1.0 alpha:0.5] setStroke];
    maskPath.lineWidth = lineWidth;
    [maskPath stroke];
    
    //Create the image using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 The circular overlay mask image to be displayed on top of the photo as cropping guideline.
 Created with PaintCode. The source file is available inside of the Resource folder.
 */
- (UIImage *)circularOverlayMask
{
    // Constants
    CGRect bounds = self.navigationController.view.bounds;
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    CGFloat diameter = width-(self.innerInset*2);
    CGFloat radius = diameter/2;
    CGPoint center = CGPointMake(width/2, height/2);
    
    if (DZN_IS_IPAD && DZN_IS_IOS8) {
        center.y += CGRectGetHeight(self.navigationController.navigationBar.frame)/2.0;
    }
    
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    
    // Create the bezier paths
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:bounds];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x-radius, center.y-radius, diameter, diameter)];
    
    [clipPath appendPath:maskPath];
    clipPath.usesEvenOddFillRule = YES;
    
    [clipPath addClip];
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    [clipPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

/*
 The final edited photo rendering.
 */
- (UIImage *)editedImage
{
    UIImage *image = nil;
    
    CGRect viewRect = self.navigationController.view.bounds;
    CGRect guideRect = [self guideRect];
    
    CGFloat verticalMargin = (viewRect.size.height-guideRect.size.height)/2;

    guideRect.origin.x = -self.scrollView.contentOffset.x;
    guideRect.origin.y = -self.scrollView.contentOffset.y - verticalMargin;
    
    if (DZN_IS_IPAD && self.cropMode == DZNPhotoEditorViewControllerCropModeCircular) {
        guideRect.origin.y -= CGRectGetHeight(self.navigationController.navigationBar.bounds)/2.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(guideRect.size, NO, 0);{
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, guideRect.origin.x, guideRect.origin.y);
        [self.scrollView.layer renderInContext:context];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (self.cropMode == DZNPhotoEditorViewControllerCropModeCircular) {
        
        CGFloat diameter = viewRect.size.width-(self.innerInset*2);
        CGRect circularRect = CGRectMake(0, 0, diameter, diameter);
        
        CGFloat increment = 1.0/(((self.innerInset*2)*100.0)/viewRect.size.width);
        CGFloat scale = 1.0 + round(increment * 10) / 10.0;
        
        UIGraphicsBeginImageContextWithOptions(circularRect.size, NO, 0.0);{

            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, -self.innerInset, -self.innerInset);
            CGContextScaleCTM(context, scale, scale);

            [image drawInRect:circularRect];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }

    return image;
}

/**
 Trims the image removing any alpha in its edges.
 Code from http://stackoverflow.com/a/12617031/590010
 */
- (UIImage *)trimmedImage:(UIImage *)image
{
    CGImageRef inImage = image.CGImage;
    CFDataRef m_DataRef;
    m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    
    CGPoint top,left,right,bottom;
    
    BOOL breakOut = NO;
    for (int x = 0;breakOut==NO && x < width; x++) {
        for (int y = 0; y < height; y++) {
            NSInteger loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                left = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
        }
    }
    
    breakOut = NO;
    for (int y = 0;breakOut==NO && y < height; y++) {
        
        for (int x = 0; x < width; x++) {
            
            NSInteger loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                top = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
            
        }
    }
    
    breakOut = NO;
    for (NSInteger y = height-1;breakOut==NO && y >= 0; y--) {
        
        for (NSInteger x = width-1; x >= 0; x--) {
            
            NSInteger loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                bottom = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
            
        }
    }
    
    breakOut = NO;
    for (NSInteger x = width-1;breakOut==NO && x >= 0; x--) {
        
        for (NSInteger y = height-1; y >= 0; y--) {
            
            NSInteger loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                right = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
            
        }
    }
    
    
    CGFloat scale = image.scale;
    
    CGRect cropRect = CGRectMake(left.x / scale, top.y/scale, (right.x - left.x)/scale, (bottom.y - top.y) / scale);
    
    UIGraphicsBeginImageContextWithOptions(cropRect.size, NO, scale);
    [image drawAtPoint:CGPointMake(-cropRect.origin.x, -cropRect.origin.y) blendMode:kCGBlendModeCopy alpha:1.];
    
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(m_DataRef);
    return croppedImage;
}


#pragma mark - Setter methods

- (void)setCropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    NSAssert(mode > DZNPhotoEditorViewControllerCropModeNone, @"Expecting other cropMode than 'None' for edition.");
    
    _cropMode = mode;
}

/*
 Sets the crop size
 Instead of asigning the same CGSize value, we first calculate a proportional height
 based on the maximum width of the container (ie: for iPhone, 320px).
 */
- (void)setCropSize:(CGSize)size
{
    if (self.cropMode == DZNPhotoEditorViewControllerCropModeCustom) {
        NSAssert(!CGSizeEqualToSize(size, CGSizeZero) , @"Expecting a non-zero CGSize for cropMode 'Custom'.");
    }
    
    _cropSize = size;
}


#pragma mark - DZNPhotoEditorViewController methods

/*
 It is important to update the scroll view content inset, specilally after zooming.
 This allows the user to move the image around with control, from edge to edge of the overlay masks.
 */
- (void)updateScrollViewContentInset
{
    CGSize imageSize = CGSizeAspectFit(self.imageView.image.size, self.imageView.frame.size);
    
    CGFloat maskHeight = (self.cropMode == DZNPhotoEditorViewControllerCropModeCircular) ? self.cropSize.width-(self.innerInset*2) : self.cropSize.height;
    
    CGFloat hInset = (self.cropMode == DZNPhotoEditorViewControllerCropModeCircular) ? self.innerInset : 0.0;
    CGFloat vInset = fabs((maskHeight-imageSize.height)/2);
    
    if (vInset == 0) vInset = 0.25;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    
    if (self.cropMode == DZNPhotoEditorViewControllerCropModeCircular && DZN_IS_IPAD && DZN_IS_IOS8) {
        inset.top += CGRectGetHeight(self.navigationController.navigationBar.frame)/2.0;
        inset.bottom -= CGRectGetHeight(self.navigationController.navigationBar.frame)/2.0;
    }
    
    self.scrollView.contentInset = inset;
}

- (void)acceptEdition:(id)sender
{
    if (self.scrollView.zoomScale > self.scrollView.maximumZoomScale || !self.imageView.image) {
        return;
    }
    
    dispatch_queue_t exampleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(exampleQueue, ^{
        
        UIImage *editedImage = [self trimmedImage:[self editedImage]];
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            
            if (self.acceptBlock) {
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 [NSValue valueWithCGRect:self.guideRect], UIImagePickerControllerCropRect,
                                                 @"public.image", UIImagePickerControllerMediaType,
                                                 @(self.cropMode), DZNPhotoPickerControllerCropMode,
                                                 @(self.scrollView.zoomScale), DZNPhotoPickerControllerCropZoomScale,
                                                 nil];
                
                if (self.editingImage) [userInfo setObject:self.editingImage forKey:UIImagePickerControllerOriginalImage];
                else [userInfo setObject:self.imageView.image forKey:UIImagePickerControllerOriginalImage];
                
                if (editedImage) [userInfo setObject:editedImage forKey:UIImagePickerControllerEditedImage];
                
                self.acceptBlock(self, userInfo);
            }
        });
    });
}

- (void)cancelEdition:(id)sender
{
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    _lastZoomScale = self.scrollView.zoomScale;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
}


#pragma mark - Key Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.imageView] && [keyPath isEqualToString:@"image"]) {
        [self updateScrollViewContentInset];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - View Auto-Rotation

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_imageView removeObserver:self forKeyPath:@"image" context:nil];
    
    _imageView.image = nil;
    _imageView = nil;
    _scrollView = nil;
    _editingImage = nil;
    _bottomView = nil;
    _activityIndicator = nil;
}

@end

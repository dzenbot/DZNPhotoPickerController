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
#import "DZNPhotoMetadata.h"

#import "UIImageView+WebCache.h"

#define kDZNPhotoEditorViewControllerInnerEdgeInset 15.0

static CGFloat _lastZoomScale;

typedef NS_ENUM(NSInteger, DZNPhotoAspect) {
    DZNPhotoAspectUnknown,
    DZNPhotoAspectSquare,
    DZNPhotoAspectVerticalRectangle,
    DZNPhotoAspectHorizontalRectangle
};

@interface DZNPhotoEditorViewController () <UIScrollViewDelegate>

/** An optional DZNPhotoMetadata use for downloading the image. */
@property (nonatomic, weak) DZNPhotoMetadata *photoMetadata;
/** An optional UIImage use for displaying the already existing full size image. */
@property (nonatomic, copy) UIImage *editingImage;
/** The scrollview containing the image for allowing panning and zooming. */
@property (nonatomic, readonly) UIScrollView *scrollView;
/** The container for the edited image. */
@property (nonatomic, readonly) UIImageView *imageView;
/** The container for the mask guide image. */
@property (nonatomic, readonly) UIImageView *maskView;
/** The view layed out at the bottom for displaying action buttons. */
@property (nonatomic, readonly) UIView *bottomView;
/** The left acion button. */
@property (nonatomic, readonly) UIButton *leftButton;
/** The right acion button. */
@property (nonatomic, readonly) UIButton *rightButton;
/** The activity indicator to be used for notifying when image is being downloaded. */
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
/** The cropping mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic) DZNPhotoEditorViewControllerCropMode cropMode;
/** The cropping size. Default is view's size.width,size.width (most of the cases 320,320). */
@property (nonatomic) CGSize cropSize;

@end

@implementation DZNPhotoEditorViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize bottomView = _bottomView;
@synthesize activityIndicator = _activityIndicator;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(self.editingImage || self.photoMetadata, @"Expecting an image or metadata for using the editor. Instead, use other initializer methods like initWithMetadata:cropMode:cropSize: or initWithImage:cropMode:cropSize:");
    }
    return nil;
}

- (instancetype)initWithMetadata:(DZNPhotoMetadata *)metadata cropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    NSAssert(mode != DZNPhotoEditorViewControllerCropModeCustom, @"Expecting other cropMode than 'custom' for edition. Instead, use initWithMetadata:cropMode:cropSize:");
    
    return [self initWithMetadata:metadata cropMode:mode cropSize:CGSizeZero];
}

- (instancetype)initWithMetadata:(DZNPhotoMetadata *)metadata cropMode:(DZNPhotoEditorViewControllerCropMode)mode cropSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.photoMetadata = metadata;
        self.cropMode = mode;
        self.cropSize = size;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image cropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    NSAssert(mode != DZNPhotoEditorViewControllerCropModeCustom, @"Expecting other cropMode than 'custom' for edition. Instead, use initWithImage:cropMode:cropSize:");
    
    return [self initWithImage:image cropMode:mode cropSize:CGSizeZero];
}

- (instancetype)initWithImage:(UIImage *)image cropMode:(DZNPhotoEditorViewControllerCropMode)mode cropSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.editingImage = image;
        self.cropMode = mode;
        self.cropSize = size;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareSubviews];
    
    [self setBarsHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self setBarsHidden:NO];
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
        
        [_scrollView addSubview:self.imageView];
        
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
        _imageView.image = _editingImage;
    }
    return _imageView;
}

- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [UIView new];
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _leftButton = [self buttonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [_leftButton addTarget:self action:@selector(cancelEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_leftButton];
        
        _rightButton = [self buttonWithTitle:NSLocalizedString(@"Choose", nil)];
        [_rightButton addTarget:self action:@selector(acceptEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_rightButton];
        
        NSMutableDictionary *views = [[NSMutableDictionary alloc] initWithDictionary:@{@"leftButton": _leftButton, @"rightButton": _rightButton}];
        NSDictionary *metrics = @{@"hmargin" : @(13), @"vmargin" : @(21), @"barsHeight": @([UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height)};
        
        [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hmargin-[leftButton]" options:0 metrics:metrics views:views]];
        [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightButton]-hmargin-|" options:0 metrics:metrics views:views]];
        
        [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[leftButton]-vmargin-|" options:0 metrics:metrics views:views]];
        [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[rightButton]-vmargin-|" options:0 metrics:metrics views:views]];
        
        if (_cropMode == DZNPhotoEditorViewControllerCropModeCircular)
        {
            UILabel *topLabel = [UILabel new];
            topLabel.translatesAutoresizingMaskIntoConstraints = NO;
            topLabel.textColor = [UIColor whiteColor];
            topLabel.textAlignment = NSTextAlignmentCenter;
            topLabel.font = [UIFont systemFontOfSize:18.0];
            topLabel.text = NSLocalizedString(@"Move and Scale", nil);
            [self.view addSubview:topLabel];
            
            NSDictionary *labels = @{@"label" : topLabel};
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:labels]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-barsHeight-[label]" options:0 metrics:metrics views:labels]];
        }
        
        if (!_imageView.image)
        {
            [_bottomView addSubview:self.activityIndicator];
            
            [views setObject:_activityIndicator forKey:@"activityIndicator"];
            
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[activityIndicator]-|" options:0 metrics:nil views:views]];
            [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[activityIndicator]-|" options:0 metrics:nil views:views]];
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
        _activityIndicator.color = [UIColor whiteColor];
    }
    return _activityIndicator;
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    return button;
}

// TODO: Implement this rectangle calculation, considering the guideRect, zoomScale and offset positioning.
- (CGRect)croppingRect
{
    return CGRectZero;
}

- (CGRect)guideRect
{
    CGFloat margin = (self.navigationController.view.bounds.size.height-_cropSize.height)/2;
    return CGRectMake(0.0, margin, _cropSize.width, _cropSize.height);
}

CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize)
{
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
    switch (_cropMode) {
        case DZNPhotoEditorViewControllerCropModeCircular:      return [self circularOverlayMask];
        case DZNPhotoEditorViewControllerCropModeSquare:
        case DZNPhotoEditorViewControllerCropModeCustom:        return [self squareOverlayMask];
        case DZNPhotoEditorViewControllerCropModeNone:          return nil;
    }
}

/*
 * The square overlay mask image to be displayed on top of the photo as cropping guideline.
 * Created with PaintCode. The source file is available inside of the Resource folder.
 */
- (UIImage *)squareOverlayMask
{
    // Constants
    CGRect bounds = self.navigationController.view.bounds;
    
    CGFloat width = _cropSize.width;
    CGFloat height = _cropSize.height;
    CGFloat margin = (bounds.size.height-_cropSize.height)/2;
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
    [clipPath moveToPoint:CGPointMake(width, bounds.size.height)];
    [clipPath addLineToPoint:CGPointMake(0, bounds.size.height)];
    [clipPath addLineToPoint:CGPointMake(0, margin+height)];
    [clipPath addLineToPoint:CGPointMake(width, margin+height)];
    [clipPath addLineToPoint:CGPointMake(width, bounds.size.height)];
    [clipPath closePath];
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    [clipPath fill];
    
    // Add the square crop
    CGRect rect = CGRectMake(lineWidth/2, margin+lineWidth/2, width-lineWidth, _cropSize.height-lineWidth);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor colorWithWhite:1.0 alpha:0.5] setStroke];
    maskPath.lineWidth = lineWidth;
    [maskPath stroke];
    
    //Create the image using the current context.
    UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _image;
}

/*
 * The circular overlay mask image to be displayed on top of the photo as cropping guideline.
 * Created with PaintCode. The source file is available inside of the Resource folder.
 */
- (UIImage *)circularOverlayMask
{
    // Constants
    CGRect bounds = self.navigationController.view.bounds;
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    CGFloat diameter = width-(kDZNPhotoEditorViewControllerInnerEdgeInset*2);
    CGFloat radius = diameter/2;
    CGPoint center = CGPointMake(width/2, height/2);
    
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
    
    UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return _image;
}

/*
 * The final edited photo rendering.
 */
- (UIImage *)editedPhoto
{
    UIImage *_image = nil;
    
    CGRect viewRect = self.navigationController.view.bounds;
    CGRect guideRect = [self guideRect];
    
    CGFloat verticalMargin = (viewRect.size.height-guideRect.size.height)/2;

    guideRect.origin.x = -_scrollView.contentOffset.x;
    guideRect.origin.y = -_scrollView.contentOffset.y - verticalMargin;
    
    UIGraphicsBeginImageContextWithOptions(guideRect.size, NO, 0);{
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, guideRect.origin.x, guideRect.origin.y);
        [_scrollView.layer renderInContext:context];
        
        _image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (_cropMode == DZNPhotoEditorViewControllerCropModeCircular) {
        
        CGFloat diameter = viewRect.size.width-(kDZNPhotoEditorViewControllerInnerEdgeInset*2);
        CGRect circularRect = CGRectMake(0, 0, diameter, diameter);
        
        CGFloat increment = 1.0/(((kDZNPhotoEditorViewControllerInnerEdgeInset*2)*100.0)/viewRect.size.width);
        CGFloat scale = 1.0 + round(increment * 10) / 10.0;
        
        UIGraphicsBeginImageContextWithOptions(circularRect.size, NO, 0.0);{

            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, -kDZNPhotoEditorViewControllerInnerEdgeInset, -kDZNPhotoEditorViewControllerInnerEdgeInset);
            CGContextScaleCTM(context, scale, scale);

            [_image drawInRect:circularRect];
            
            _image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }

    return _image;
}


#pragma mark - Setter methods

- (void)setCropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    NSAssert(mode > DZNPhotoEditorViewControllerCropModeNone, @"Expecting other cropMode than 'None' for edition.");
    
    _cropMode = mode;
}

/*
 * Sets the crop size
 * Instead of asigning the same CGSize value, we first calculate a proportional height
 * based on the maximum width of the container (ie: for iPhone, 320px).
 */
- (void)setCropSize:(CGSize)size
{
    if (_cropMode == DZNPhotoEditorViewControllerCropModeCustom) {
        NSAssert(!CGSizeEqualToSize(size, CGSizeZero) , @"Expecting a non-zero CGSize for cropMode 'Custom'.");
    }
    
    CGSize viewSize = self.view.bounds.size;
    
    if (_cropMode == DZNPhotoEditorViewControllerCropModeCircular || _cropMode == DZNPhotoEditorViewControllerCropModeSquare) {
        _cropSize = CGSizeMake(viewSize.width, viewSize.width);
    }
    else {
        CGFloat cropHeight = roundf((size.height * viewSize.width) / size.width);
        if (cropHeight > viewSize.height) {
            cropHeight = viewSize.height;
        }
        _cropSize = CGSizeMake(size.width, cropHeight);
    }
}

- (void)setBarsHidden:(BOOL)hidden
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    }
    
    [self.navigationController setNavigationBarHidden:hidden animated:!hidden];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSDictionary *views = [[NSMutableDictionary alloc] initWithDictionary:@{@"bottomView": _bottomView}];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(72)]|" options:0 metrics:nil views:views]];
}


#pragma mark - DZNPhotoEditorViewController methods

- (void)prepareSubviews
{
    if (!_imageView.image)
    {
        __weak DZNPhotoEditorViewController *weakSelf = self;
        __weak UIButton *_button = _rightButton;
        _button.enabled = NO;
        
        [_activityIndicator startAnimating];
        
        [_imageView setImageWithURL:_photoMetadata.sourceURL placeholderImage:nil
                            options:SDWebImageCacheMemoryOnly|SDWebImageProgressiveDownload|SDWebImageRetryFailed
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (!error) {
                                  _button.enabled = YES;
                              }
                              else {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:DZNPhotoPickerDidFailPickingNotification
                                                                                      object:nil
                                                                                    userInfo:@{@"error": error}];
                              }
                              
                              [[weakSelf activityIndicator] removeFromSuperview];
                              [weakSelf updateScrollViewContentInset];
                          }];
    }
    else {
        [self updateScrollViewContentInset];
    }
    
    if (!_maskView) {
        _maskView = [[UIImageView alloc] initWithImage:[self overlayMask]];
        [self.view insertSubview:_maskView aboveSubview:_scrollView];
    }
}

/*
 * It is important to update the scroll view content inset, specilally after zooming.
 * This allows the user to move the image around with control, from edge to edge of the overlay masks.
 */
- (void)updateScrollViewContentInset
{
    CGSize imageSize = CGSizeAspectFit(_imageView.image.size, _imageView.frame.size);
    
    CGFloat maskHeight = (_cropMode == DZNPhotoEditorViewControllerCropModeCircular) ? _cropSize.width-(kDZNPhotoEditorViewControllerInnerEdgeInset*2) : _cropSize.height;
    
    CGFloat hInset = (_cropMode == DZNPhotoEditorViewControllerCropModeCircular) ? kDZNPhotoEditorViewControllerInnerEdgeInset : 0.0;
    CGFloat vInset = fabs((maskHeight-imageSize.height)/2);
    
    if (vInset == 0) vInset = 0.5;
    
    _scrollView.contentInset =  UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
}

- (void)acceptEdition:(id)sender
{
    if (_scrollView.zoomScale > _scrollView.maximumZoomScale || !_imageView.image) {
        return;
    }
    
    dispatch_queue_t exampleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(exampleQueue, ^{
        
        UIImage *photo = [self editedPhoto];
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            
            if (photo) {
                [DZNPhotoEditorViewController didFinishPickingOriginalImage:_imageView.image
                                                                editedImage:photo
                                                                   cropRect:[self guideRect]
                                                                  zoomScale:_scrollView.zoomScale
                                                                   cropMode:_cropMode
                                                              photoMetadata:_photoMetadata];
            }
        });
    });
}

- (void)cancelEdition:(id)sender
{
    if (_scrollView.zoomScale > _scrollView.maximumZoomScale) {
        return;
    }
    
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

+ (void)didFinishPickingOriginalImage:(UIImage *)originalImage
                          editedImage:(UIImage *)editedImage
                             cropRect:(CGRect)cropRect
                            zoomScale:(CGFloat)zoomScale
                             cropMode:(DZNPhotoEditorViewControllerCropMode)cropMode
                        photoMetadata:(DZNPhotoMetadata *)metadata;
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [NSValue valueWithCGRect:cropRect], UIImagePickerControllerCropRect,
                                     @"public.image", UIImagePickerControllerMediaType,
                                     @(cropMode), DZNPhotoPickerControllerCropMode,
                                     @(zoomScale), DZNPhotoPickerControllerCropZoomScale,
                                     nil];
    
    if (originalImage) [userInfo setObject:originalImage forKey:UIImagePickerControllerOriginalImage];
    if (editedImage) [userInfo setObject:editedImage forKey:UIImagePickerControllerEditedImage];
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (metadata.serviceName) [attributes setObject:metadata.serviceName forKey:@"source_name"];
    if (metadata.Id) [attributes setObject:metadata.Id forKey:@"source_id"];
    if (metadata.detailURL) [attributes setObject:metadata.detailURL forKey:@"source_detail_url"];
    if (metadata.sourceURL) [attributes setObject:metadata.sourceURL forKey:@"source_url"];
    if (metadata.authorName) [attributes setObject:metadata.authorName forKey:@"author_name"];
    if (metadata.authorUsername) [attributes setObject:metadata.authorUsername forKey:@"author_username"];
    if (metadata.authorProfileURL) [attributes setObject:metadata.authorProfileURL forKey:@"author_profile_url"];
    
    if (attributes.allKeys.count > 0) {
        [userInfo setObject:attributes forKey:DZNPhotoPickerControllerPhotoMetadata];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DZNPhotoPickerDidFinishPickingNotification object:nil userInfo:userInfo];
}


#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    _lastZoomScale = _scrollView.zoomScale;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //[self updateScrollViewContentInset];
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
    _editingImage = nil;
    _bottomView = nil;
    _activityIndicator = nil;
}


#pragma mark - View Auto-Rotation

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

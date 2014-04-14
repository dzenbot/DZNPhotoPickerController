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
{
    UIImageView *_imageView;
    UIImageView *_maskView;
    UIButton *_cancelButton;
    UIButton *_acceptButton;
}

/** An optional . */
@property (nonatomic, weak) DZNPhotoMetadata *photoMetadata;
/** An optional UIImage assigned when starting the editor with an already existing full size image. */
@property (nonatomic, assign) UIImage *editingImage;
/** The scrollview containing the image for allowing panning and zooming. */
@property (nonatomic, strong) UIScrollView *scrollView;
/** The view layed out at the bottom for displaying action buttons and activity indicator. */
@property (nonatomic, strong) UIView *bottomView;
/** The cropping mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic) DZNPhotoEditorViewControllerCropMode cropMode;
/** The cropping size. Default is view's size.width,size.width (most of the cases 320,320). */
@property (nonatomic) CGSize cropSize;

@end

@implementation DZNPhotoEditorViewController

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setBarsHidden:YES];
    [self prepareLayout];
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
        
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = _editingImage;
        
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
        [_bottomView addSubview:_acceptButton];
        
        CGRect rect = _cancelButton.frame;
        rect.origin = CGPointMake(15.0, roundf(_bottomView.frame.size.height/2-_cancelButton.frame.size.height/2));
        [_cancelButton setFrame:rect];
        
        rect = _acceptButton.frame;
        rect.origin = CGPointMake(roundf(_bottomView.frame.size.width-_acceptButton.frame.size.width-15.0), roundf(_bottomView.frame.size.height/2-_acceptButton.frame.size.height/2));
        [_acceptButton setFrame:rect];
        
        if (_cropMode == DZNPhotoEditorViewControllerCropModeCircular) {
            
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
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [button sizeToFit];
    return button;
}

- (CGRect)cropRect
{
//    CGFloat density = [UIScreen mainScreen].scale;
//    CGFloat zoomScale = _scrollView.zoomScale;
//    CGFloat margin = (self.navigationController.view.bounds.size.height-_cropSize.height)/2;
//    CGRect guideRect = [self guideRect];
    
    return CGRectZero;
}

- (CGRect)guideRect
{
    CGFloat margin = (self.navigationController.view.bounds.size.height-_cropSize.height)/2;
    return CGRectMake(0.0, margin, _cropSize.width, _cropSize.height);
}

- (CGSize)imageSize
{
    return CGSizeAspectFit(_imageView.image.size,_imageView.frame.size);
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


#pragma mark - DZNPhotoEditorViewController methods

- (void)prepareLayout
{
    if (!_imageView.image) {
        
        __weak UIButton *_button = _acceptButton;
        _button.enabled = NO;
        
        __weak DZNPhotoEditorViewController *_self = self;
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.center = CGPointMake(roundf(_bottomView.frame.size.width/2), roundf(_bottomView.frame.size.height/2));
        [activityIndicatorView startAnimating];
        [_bottomView addSubview:activityIndicatorView];
        
        [_imageView setImageWithURL:_photoMetadata.sourceURL placeholderImage:nil
                            options:SDWebImageCacheMemoryOnly|SDWebImageProgressiveDownload|SDWebImageRetryFailed
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (!error) _button.enabled = YES;
                              [activityIndicatorView removeFromSuperview];
                              
                              [_self updateScrollViewContentInset];
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
    CGSize imageSize = [self imageSize];
    
    CGFloat maskHeight = (_cropMode == DZNPhotoEditorViewControllerCropModeCircular) ? _cropSize.width-(kDZNPhotoEditorViewControllerInnerEdgeInset*2) : _cropSize.height;
    
    CGFloat hInset = (_cropMode == DZNPhotoEditorViewControllerCropModeCircular) ? kDZNPhotoEditorViewControllerInnerEdgeInset : 0.0;
    CGFloat vInset = fabs((maskHeight-imageSize.height)/2);
    
    if (vInset == 0) vInset = 0.5;
    
    _scrollView.contentInset =  UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
}

- (void)acceptEdition:(id)sender
{
    if (_scrollView.zoomScale > _scrollView.maximumZoomScale) {
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
    _cancelButton = nil;
    _acceptButton = nil;
    _bottomView = nil;
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

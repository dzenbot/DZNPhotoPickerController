//
//  DZPhotoEditViewController.m
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "DZPhotoEditViewController.h"
#import "DZPhotoDisplayController.h"

// pi is approximately equal to 3.14159265359.
#define DEGREES_TO_RADIANS(degrees) ((pi * degrees)/ 180)

@interface DZPhotoEditViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation DZPhotoEditViewController

- (instancetype)initWithCropMode:(DZPhotoEditViewControllerCropMode)mode;
{
    self = [super init];
    if (self) {
        _cropMode = mode;
//        _cropHeight = self.view.bounds.size.width;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = CGPointMake(roundf(_bottomView.frame.size.width/2), roundf(_bottomView.frame.size.height/2));
    activityIndicatorView.hidesWhenStopped = YES;
    [activityIndicatorView startAnimating];
    [_bottomView addSubview:activityIndicatorView];
    
    __block UIButton *_weakButton = _acceptButton;
//    __block DZPhotoEditViewController *_weakSelf = self;
    
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:[self overlayMask]];
    [self.view insertSubview:maskImageView aboveSubview:_scrollView];

    [_imageView setImageWithURL:_photo.fullURL placeholderImage:nil
                        options:SDWebImageProgressiveDownload|SDWebImageRetryFailed|SDWebImageCacheMemoryOnly
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                          if (!error) [_weakButton setEnabled:YES];
                          [activityIndicatorView stopAnimating];

//                          [_weakSelf fitContentSize];
                      }];
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
        _scrollView.backgroundColor = [UIColor blackColor];
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
        
        _cancelButton = [self buttonWithTitle:@"Cancel"];
        [_cancelButton addTarget:self action:@selector(cancelEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_cancelButton];
        
        _acceptButton = [self buttonWithTitle:@"Choose"];
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
        
        
        if (_cropMode == DZPhotoEditViewControllerCropModeCircular)
        {
            UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            topLabel.text = @"Move and Scale";
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

- (void)setCropSize:(CGSize)cropSize
{
    CGSize viewSize = self.view.bounds.size;
    CGFloat cropHeight = roundf(cropSize.height/(cropSize.width/viewSize.width));
    
    _cropSize = CGSizeMake(cropSize.width, cropHeight);
}

- (UIImage *)overlayMask
{
    switch (_cropMode) {
        case DZPhotoEditViewControllerCropModeSquare:
            return [self squareOverlayMask];
            
        case DZPhotoEditViewControllerCropModeCircular:
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
    CGFloat margin = (height-width)/2;
    
    // Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // Color Declarations
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIColor *strokeColor = [UIColor colorWithWhite:1.0 alpha:0.5];

    // Bezier Drawing
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(width, margin)];
    [path addLineToPoint:CGPointMake(0, margin)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointMake(width, margin)];
    [path closePath];
    [path moveToPoint:CGPointMake(width, height)];
    [path addLineToPoint:CGPointMake(0, height)];
    [path addLineToPoint:CGPointMake(0, width+margin)];
    [path addLineToPoint:CGPointMake(width, width+margin)];
    [path addLineToPoint:CGPointMake(width, height)];
    [path closePath];
    [fillColor setFill];
    [path fill];
    
    // Crop square Drawing
    UIBezierPath *square = [UIBezierPath bezierPathWithRect: CGRectMake(0.5, margin+0.5, width-1, width-1)];
    [strokeColor setStroke];
    square.lineWidth = 1;
    [square stroke];
    
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
    
    CGFloat diameter = 290.0;
    CGFloat radius = diameter/2;
    CGPoint center = CGPointMake(width/2, height/2);
    
    // Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // Color Declarations
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];

    // Arc Bezier Drawing
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.navigationController.view.bounds];
    [path addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:NO];
    [path closePath];
    [fillColor setFill];
    [path fill];
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)editedPhoto
{
    UIImage *_image = nil;
    
    CGFloat margin = (_cropMode == DZPhotoEditViewControllerCropModeCircular) ? 15.0 : 0.0;
    CGFloat width = self.view.bounds.size.width-(margin*2.0);
    CGRect rect = CGRectMake(-_scrollView.contentOffset.x - (margin), -_scrollView.contentOffset.y - 80.0, width, width);

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,width), NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);

    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    
    if (_cropMode == DZPhotoEditViewControllerCropModeCircular) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(margin, 80.0, width, width) cornerRadius:width/2];
        [bezierPath addClip];
        
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextSetLineWidth(context, 0);
        CGContextStrokeEllipseInRect(context, rect);
    }
    
    [_scrollView.layer renderInContext:context];
    
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _image;
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


#pragma mark - Setter methods



#pragma mark - DZPhotoEditViewController methods

- (void)fitContentSize
{
    CGFloat factor = roundf(_imageView.image.size.width/_scrollView.frame.size.width);
    NSLog(@"factor : %f",factor);
    
    CGFloat height = roundf(_imageView.image.size.height/factor);
    NSLog(@"height : %f",height);
    
    CGFloat difference = _scrollView.contentSize.height-height;
    NSLog(@"difference : %f",difference);
    
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height += difference;
    [_scrollView setContentSize:contentSize];
    
    CGRect frame = _imageView.frame;
    frame.origin.y += difference/2;
    _scrollView.frame = frame;
    
    NSLog(@"image.size : %@", NSStringFromCGSize(_imageView.image.size));
    NSLog(@"_weakImageView.frame.size : %@", NSStringFromCGSize(_imageView.frame.size));
    
    NSLog(@"_weakScrollView.contentSize : %@", NSStringFromCGSize(_scrollView.contentSize));
    NSLog(@"_weakScrollView.contentOffset : %@", NSStringFromCGPoint(_scrollView.contentOffset));
}

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
    if (authorName != nil) [userInfo setObject:authorName forKey:UIImagePickerControllerAuthorCredits];
    if (sourceName != nil) [userInfo setObject:sourceName forKey:UIImagePickerControllerSourceName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZPhotoPickerChooseNotification object:nil userInfo:userInfo];
}

- (void)acceptEdition:(id)sender
{
    [DZPhotoEditViewController didFinishPickingEditedImage:[self editedPhoto]
                                              withCropRect:_imageView.bounds
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
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
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


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

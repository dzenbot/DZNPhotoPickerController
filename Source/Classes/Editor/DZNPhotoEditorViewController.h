//
//  DZNPhotoEditorViewController.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "DZNPhotoPickerControllerConstants.h"

@class DZNPhotoEditorViewController;

typedef void (^DZNPhotoEditorAcceptBlock)(DZNPhotoEditorViewController *editor, NSDictionary *userInfo);
typedef void (^DZNPhotoEditorCancelBlock)(DZNPhotoEditorViewController *editor);

/**
 The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface DZNPhotoEditorViewController : UIViewController

/** The cropping mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic, assign) DZNPhotoEditorViewControllerCropMode cropMode;
/** The cropping size. Default is view's size.width,size.width (most of the cases 320,320). */
@property (nonatomic, assign) CGSize cropSize;

/** The container for the edited image. */
@property (nonatomic, readonly) UIImageView *imageView;
/** The bottom-left action button. */
@property (nonatomic, readonly) UIButton *leftButton;
/** The bottom-right action button. */
@property (nonatomic, readonly) UIButton *rightButton;
/** The activity indicator to indicate that the image is being downloaded. */
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

/** A block to be executed whenever the user accepts the edition. */
@property (nonatomic, strong) DZNPhotoEditorAcceptBlock acceptBlock;
/** A block to be executed whenever the user cancels the edition. */
@property (nonatomic, strong) DZNPhotoEditorCancelBlock cancelBlock;

/**
 Initializes a photo editor with the specified image, and default cropping mode (Square).
 
 @param image The image to display in the photo editor.
 @return A new instance of the editor controller.
 */
- (instancetype)initWithImage:(UIImage *)image;

@end
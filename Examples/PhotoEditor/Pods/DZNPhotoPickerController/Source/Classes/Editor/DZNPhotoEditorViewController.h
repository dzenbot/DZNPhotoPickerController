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

typedef void (^DZNPhotoEditorAcceptBlock)(NSDictionary *userInfo);
typedef void (^DZNPhotoEditorCancelBlock)(void);

/**
 The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface DZNPhotoEditorViewController : UIViewController

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

/**
 Initializes a photo editor with the specified image and cropping size.
 
 @param image The image to display in the photo editor.
 @param mode The crop mode to be used. Assigning 'DZNPhotoEditorViewControllerCropModeNone' will throw an exception.
 @param size The crop size to be used.
 @return A new instance of the editor controller.
 */
- (instancetype)initWithImage:(UIImage *)image cropMode:(DZNPhotoEditorViewControllerCropMode)mode cropSize:(CGSize)size;

@end
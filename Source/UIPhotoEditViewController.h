//
//  UIPhotoEditViewController.h
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

@class UIPhotoDescription;

typedef NS_ENUM(NSInteger, UIPhotoEditViewControllerCropMode) {
    UIPhotoEditViewControllerCropModeSquare = 0,
    UIPhotoEditViewControllerCropModeCircular,
    UIPhotoEditViewControllerCropModeCustom
};

/*
 * The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface UIPhotoEditViewController : UIViewController


/* The photo data object. */
@property (nonatomic, weak) UIPhotoDescription *photo;
/* The crop mode currently being used. */
@property (nonatomic, readonly) UIPhotoEditViewControllerCropMode cropMode;
/* The crop size proportions. */
@property (nonatomic) CGSize cropSize;


/*
 * Initializes a photo editor with a specified cropping mode (square, circular or custom)
 *
 * @param mode The crop mode.
 * @return A new instance of the editor controller.
 */
- (instancetype)initWithCropMode:(UIPhotoEditViewControllerCropMode)mode;

/*
 *
 */
+ (void)didFinishPickingEditedImage:(UIImage *)editedImage
                       withCropRect:(CGRect)cropRect
                  fromOriginalImage:(UIImage *)originalImage
                       referenceURL:(NSURL *)referenceURL
                         authorName:(NSString *)authorName
                         sourceName:(NSString *)sourceName;

@end

//
//  DZNPhotoEditViewController.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

@class DZNPhotoDescription;

typedef NS_ENUM(NSInteger, DZNPhotoEditViewControllerCropMode) {
    DZNPhotoEditViewControllerCropModeNone = -1,
    DZNPhotoEditViewControllerCropModeSquare = 0,
    DZNPhotoEditViewControllerCropModeCircular
};

/*
 * The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface DZNPhotoEditViewController : UIViewController

/* The crop mode currently being used. */
@property (nonatomic, readonly) DZNPhotoEditViewControllerCropMode cropMode;
/* The crop size proportions. */
@property (nonatomic) CGSize cropSize;


/*
 * Initializes a photo editor with a specified cropping mode (square, circular or custom)
 *
 * @param mode The crop mode.
 * @return A new instance of the editor controller.
 */
- (instancetype)initWithPhotoDescription:(DZNPhotoDescription *)description cropMode:(DZNPhotoEditViewControllerCropMode)mode;

/*
 * Initializes a photo editor initialized with the specified image and cropping mode (square, circular or custom).
 * Use this initializer to push a DZNPhotoEditViewController after picking an image with UIImagePickerController, and use a custom crop mode. This will give users the ability to crop an avatar image, with a circular crop like the Contacts app.
 *
 * @param image The image to display in the photo editor.
 * @param mode The crop mode.
 * @return A new instance of the editor controller.
 */
- (instancetype)initWithImage:(UIImage *)image cropMode:(DZNPhotoEditViewControllerCropMode)mode;

/*
 * Proxy class method to be called whenever the user picks a photo, with or without editing the image.
 *
 * @param editedImage The image result after edition.
 * @param cropRect The applied rectangle on the cropping. If no edited, the default value is CGRectZero.
 * @param originalImage The original image before edition.
 * @param referenceURL The source url of the original image.
 * @param authorName The name of the author of the photo.
 * @param sourceName The name of the photo service from where the photo was fetched.
 */
+ (void)didFinishPickingEditedImage:(UIImage *)editedImage
                       withCropRect:(CGRect)cropRect
                  fromOriginalImage:(UIImage *)originalImage
                       referenceURL:(NSURL *)referenceURL
                         authorName:(NSString *)authorName
                         sourceName:(NSString *)sourceName;

@end

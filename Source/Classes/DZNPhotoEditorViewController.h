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

@class DZNPhotoMetadata;

/**
 The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface DZNPhotoEditorViewController : UIViewController

/**
 Initializes a photo editor with a specified cropping mode (i.e. square, circular).
 This is a reserved method to be used internally by DZNPhotoPickerController. For custom usage of the editor, use initWithMetadata:cropMode:cropSize: or initWithImage:cropMode:cropSize:
 
 @param metadata The photo metadata.
 @param mode The crop mode to be used. Assigning 'DZNPhotoEditorViewControllerCropModeNone' will throw an exception.
 @param mode The crop size to be used.
 @return A new instance of the editor controller.
 */
- (instancetype)initWithMetadata:(DZNPhotoMetadata *)metadata cropMode:(DZNPhotoEditorViewControllerCropMode)mode cropSize:(CGSize)size;
- (instancetype)initWithMetadata:(DZNPhotoMetadata *)metadata cropMode:(DZNPhotoEditorViewControllerCropMode)mode;

/**
 Initializes a photo editor with the specified image and cropping size.
 
 @param image The image to display in the photo editor.
 @param mode The crop mode to be used. Assigning 'DZNPhotoEditorViewControllerCropModeNone' will throw an exception.
 @param size The crop size to be used.
 @return A new instance of the editor controller.
 */
- (instancetype)initWithImage:(UIImage *)image cropMode:(DZNPhotoEditorViewControllerCropMode)mode cropSize:(CGSize)size;
- (instancetype)initWithImage:(UIImage *)image cropMode:(DZNPhotoEditorViewControllerCropMode)mode;

/**
 Proxy class method to be called whenever the user picks a photo, with or without editing the image.
 This is a reserved method to be used internally by DZNPhotoPickerController.
 
 @param originalImage The original image before edition.
 @param editedImage The image result after edition.
 @param cropRect The applied rectangle on the cropping. If no edited, the default value is CGRectZero.
 @param zoomScale The applied zoom scale on the cropping. If no edited, the default value is 1.0
 @param cropMode The crop mode being used.
 @param photoDescription The photo metadata.
 */
+ (void)didFinishPickingOriginalImage:(UIImage *)originalImage
                          editedImage:(UIImage *)editedImage
                             cropRect:(CGRect)cropRect
                            zoomScale:(CGFloat)zoomScale
                             cropMode:(DZNPhotoEditorViewControllerCropMode)cropMode
                        photoMetadata:(DZNPhotoMetadata *)metadata;;

@end

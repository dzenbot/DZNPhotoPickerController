//
//  UIImagePickerController+Edit.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 1/2/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIImagePickerController.h>
#import "DZNPhotoPickerControllerConstants.h"

typedef void (^UIImagePickerControllerFinalizationBlock)(UIImagePickerController *picker, NSDictionary *info);
typedef void (^UIImagePickerControllerCancellationBlock)(UIImagePickerController *picker);

/**
 A category class allowing custom edition modes on UIImagePickerController with special crop guides, like the circular guide from the Contacts app.
 */
@interface UIImagePickerController (Edit)

/** The cropping mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic, assign) DZNPhotoEditorViewControllerCropMode cropMode;
/** The cropping size. Default is view's square size (generally 320,320). */
@property (nonatomic) CGSize cropSize;

/** A block to be executed whenever the user picks a new photo. Use this block to replace delegate method imagePickerController:didFinishPickingPhotoWithInfo: */
@property (nonatomic, strong) UIImagePickerControllerFinalizationBlock finalizationBlock;
/** A block to be executed whenever the user cancels the pick operation. Use this block to replace delegate method imagePickerControllerDidCancel: */
@property (nonatomic, strong) UIImagePickerControllerCancellationBlock cancellationBlock;

@end

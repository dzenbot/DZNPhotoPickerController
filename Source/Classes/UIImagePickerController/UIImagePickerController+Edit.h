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

/** 
 A category class allowing custom edition modes on UIImagePickerController with specially crop for circular avatars like the Contacts app on iOS7.
 */
@interface UIImagePickerController (Edit)

/** The cropping mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic, assign) DZNPhotoEditorViewControllerCropMode cropMode;

@end

//
//  UIImagePickerController+Edit.h
//  Sample
//
//  Created by Ignacio on 1/2/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPhotoEditViewController.h"

/* 
 * An unformal protocol for allowing custom edition modes on UIImagePickerController,
 * specially crop for circular avatars like the Contacts app on iOS7.
 */
@interface UIImagePickerController (Edit)

/* The editing mode to be used after selecting an image. */
@property (nonatomic) UIPhotoEditViewControllerCropMode editingMode;

@end

//
//  UIImagePickerController+Edit.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 1/2/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "UIImagePickerController+Edit.h"

static DZNPhotoEditorViewControllerCropMode _cropMode;

@implementation UIImagePickerController (Edit)

- (void)setCropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    self.allowsEditing = NO;
    _cropMode = mode;

    switch (mode) {
        case DZNPhotoEditorViewControllerCropModeNone:
            [[NSNotificationCenter defaultCenter] removeObserver:self name:DZNPhotoPickerDidFinishPickingNotification object:nil];
            break;
            
        default:
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickImage:) name:DZNPhotoPickerDidFinishPickingNotification object:nil];
            break;
    }
}

- (DZNPhotoEditorViewControllerCropMode)cropMode
{
    return _cropMode;
}

- (void)didPickImage:(NSNotification *)notification
{
    if (!self.allowsEditing && self.delegate &&
        [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        
        if ([[notification.userInfo allKeys] containsObject:UIImagePickerControllerEditedImage]) {
            self.cropMode = DZNPhotoEditorViewControllerCropModeNone;
        }
        
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:notification.userInfo];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DZNPhotoPickerDidFinishPickingNotification object:nil];
}

@end

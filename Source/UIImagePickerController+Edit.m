//
//  UIImagePickerController+Edit.m
//  Sample
//
//  Created by Ignacio on 1/2/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "UIImagePickerController+Edit.h"
#import "UIPhotoPickerController.h"

static UIPhotoEditViewControllerCropMode _editingMode;

@implementation UIImagePickerController (Edit)

- (void)setEditingMode:(UIPhotoEditViewControllerCropMode)mode
{
    _editingMode = mode;
    
    switch (mode) {
        case UIPhotoEditViewControllerCropModeSquare:
            self.allowsEditing = YES;
            break;
            
        case UIPhotoEditViewControllerCropModeCircular:
        case UIPhotoEditViewControllerCropModeCustom:
            self.allowsEditing = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickImage:) name:kUIPhotoPickerDidFinishPickingNotification object:nil];
            break;
            
        default:
            self.allowsEditing = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kUIPhotoPickerDidFinishPickingNotification object:nil];
            break;
    }
}

- (UIPhotoEditViewControllerCropMode)editingMode
{
    return _editingMode;
}

- (void)didPickImage:(NSNotification *)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]){
        self.editingMode = UIPhotoEditViewControllerCropNone;
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:notification.userInfo];
    }
}

@end

//
//  UIImagePickerController+Block.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 3/25/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "UIImagePickerController+Block.h"

static UIImagePickerControllerFinalizationBlock _finalizationBlock;
static UIImagePickerControllerCancellationBlock _cancellationBlock;

@interface UIImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation UIImagePickerController (Block)

#pragma mark - Getter methods

- (UIImagePickerControllerFinalizationBlock)finalizationBlock
{
    return _finalizationBlock;
}

- (UIImagePickerControllerCancellationBlock)cancellationBlock
{
    return _cancellationBlock;
}


#pragma mark - Setter methods

- (void)setFinalizationBlock:(UIImagePickerControllerFinalizationBlock)block
{
    if (block) {
        self.delegate = self;
        _finalizationBlock = [block copy];
    }
}

- (void)setCancellationBlock:(UIImagePickerControllerCancellationBlock)block
{
    if (block) {
        self.delegate = self;
        _cancellationBlock = [block copy];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.finalizationBlock) {
        self.finalizationBlock(picker, info);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.cancellationBlock) {
        self.cancellationBlock(self);
    }
}

@end
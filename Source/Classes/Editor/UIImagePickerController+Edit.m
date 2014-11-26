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
#import "DZNPhotoEditorViewController.h"
#import <objc/runtime.h>

static char cropModeKey;
static char cropSizeKey;
static char previousDelegateKey;

static char finalizationBlockKey;
static char cancelationBlockKey;

@interface UIImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> previousDelegate;
@end

@implementation UIImagePickerController (Edit)

#pragma mark - Getters

- (DZNPhotoEditorViewControllerCropMode)cropMode
{
    return [objc_getAssociatedObject(self, &cropModeKey) integerValue];
}

- (CGSize)cropSize
{
    return [objc_getAssociatedObject(self, &cropSizeKey) CGSizeValue];
}

- (id<UIImagePickerControllerDelegate>)previousDelegate
{
    return objc_getAssociatedObject(self, &previousDelegateKey);
}

- (UIImagePickerControllerFinalizationBlock)finalizationBlock
{
    return objc_getAssociatedObject(self, &finalizationBlockKey);
}

- (UIImagePickerControllerCancellationBlock)cancellationBlock
{
    return objc_getAssociatedObject(self, &cancelationBlockKey);
}


#pragma mark - Getters

- (void)setCropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    self.allowsEditing = NO;
    
    objc_setAssociatedObject(self, &cropModeKey, @(mode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (mode != DZNPhotoEditorViewControllerCropModeNone) {
        self.previousDelegate = self.delegate;
        self.delegate = self;
    }
    else {
        self.delegate = self.previousDelegate;
        objc_setAssociatedObject(self, &previousDelegateKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)setCropSize:(CGSize)size
{
    self.allowsEditing = NO;
    
    objc_setAssociatedObject(self, &cropSizeKey, [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.cropMode != DZNPhotoEditorViewControllerCropModeCustom) {
        self.cropMode = DZNPhotoEditorViewControllerCropModeCustom;
    }
}

- (void)setPreviousDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate
{
    objc_setAssociatedObject(self, &previousDelegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setFinalizationBlock:(UIImagePickerControllerFinalizationBlock)block
{
    if (!block) {
        return;
    }
    
    self.delegate = self;
    objc_setAssociatedObject(self, &finalizationBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCancellationBlock:(UIImagePickerControllerCancellationBlock)block
{
    if (!block) {
        return;
    }
    
    self.delegate = self;
    objc_setAssociatedObject(self, &cancelationBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Private Methods

- (void)handleCompletion:(NSDictionary *)userInfo
{
    if (self.finalizationBlock) {
        self.finalizationBlock(self, userInfo);
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:userInfo];
    }
}

- (void)handleCancellation:(id)delegate
{
    if (self.cancellationBlock) {
        self.cancellationBlock(self);
    }
    else if (delegate && [delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [delegate imagePickerControllerDidCancel:self];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.cropMode != DZNPhotoEditorViewControllerCropModeNone && (self.previousDelegate || self.finalizationBlock)) {
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        DZNPhotoEditorViewController *controller = [[DZNPhotoEditorViewController alloc] initWithImage:image];
        controller.cropMode = self.cropMode;
        controller.cropSize = self.cropSize;
        [picker pushViewController:controller animated:YES];
        
        [controller setAcceptBlock:^(DZNPhotoEditorViewController *editor, NSDictionary *userInfo){
            self.cropMode = DZNPhotoEditorViewControllerCropModeNone;
            [self handleCompletion:userInfo];
        }];
        
        [controller setCancelBlock:^(DZNPhotoEditorViewController *editor){
            [self handleCancellation:self.delegate];
        }];
    }
    else if (self.delegate && !self.previousDelegate) {
        [self handleCompletion:info];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self handleCancellation:self.previousDelegate];

}

@end

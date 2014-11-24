//
//  ViewController.m
//  PhotoEditor
//
//  Created by Ignacio Romero Z. on 11/23/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "ViewController.h"

#import <DZNPhotoPickerController/DZNPhotoEditorViewController.h>
#import <DZNPhotoPickerController/UIImagePickerController+Edit.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIPopoverController *_popoverController;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"Photo Editor";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStyleDone target:self action:@selector(importImage:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editImage:)];
}

- (void)editImage:(id)sender
{
    DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:self.imageView.image];
    
    [editor setAcceptBlock:^(NSDictionary *userInfo){
        
        UIImage *image = userInfo[UIImagePickerControllerEditedImage];
        self.imageView.image = image;
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [editor setCancelBlock:^(void){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self presentController:editor push:YES sender:sender];
}

- (void)importImage:(id)sender
{
    __weak __typeof(self)weakSelf = self;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    picker.cropSize = CGSizeMake(CGRectGetWidth(self.view.frame), 100.0);
    
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        
        UIImage *image = info[UIImagePickerControllerEditedImage];
        weakSelf.imageView.image = image;
        
        // Dismiss when the crop mode was disabled
        if (picker.cropMode == DZNPhotoEditorViewControllerCropModeNone) {
            [weakSelf dismissController:picker];
        }
        
        return weakSelf;
    };

    picker.cancellationBlock = ^(UIImagePickerController *picker) {
        
        [weakSelf dismissController:picker];
        
        return weakSelf;
    };
    
    [self presentController:picker push:NO sender:sender];
}

- (void)presentController:(UIViewController *)controller push:(BOOL)push sender:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (push) {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        }
        else {
            _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        
        _popoverController.popoverContentSize = CGSizeMake(320.0, 512.0);
        
        [_popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        if (push) {
            [self.navigationController pushViewController:controller animated:YES];
        }
        else {
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
}

- (void)dismissController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        if (controller.presentingViewController) {
            [controller dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            [controller.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.imageView.image = image;
    
    [self dismissController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissController:picker];
}

@end

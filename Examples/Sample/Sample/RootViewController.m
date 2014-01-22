//
//  RootViewController.m
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "RootViewController.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"

#import "Private.h"

@interface RootViewController () {
    UIPopoverController *_popoverController;
}
@end

@implementation RootViewController

+ (void)initialize
{
    [DZNPhotoPickerController registerForServiceType:DZNPhotoPickerControllerService500px
                                    withConsumerKey:k500pxConsumerKey
                                  andConsumerSecret:k500pxConsumerSecret];
    
    [DZNPhotoPickerController registerForServiceType:DZNPhotoPickerControllerServiceFlickr
                                    withConsumerKey:kFlickrConsumerKey
                                  andConsumerSecret:kFlickrConsumerSecret];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}


#pragma mark - ViewController methods

- (IBAction)importImage:(UIButton *)button
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Photo", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Search Photo", nil)];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    
    [actionSheet setDelegate:self];
    
    [actionSheet showFromRect:_button.frame inView:self.view animated:YES];
}

- (void)presentImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.editingMode = DZNPhotoEditViewControllerCropModeCircular;
    picker.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        _popoverController.popoverContentSize = CGSizeMake(320.0, 548.0);
        [_popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:picker animated:YES completion:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)presentPhotoPicker
{
    DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
    picker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr;
    picker.allowsEditing = YES;
    picker.editingMode = DZNPhotoEditViewControllerCropModeSquare;
    picker.delegate = self;
    
//    picker.initialSearchTerm = @"Daft Punk";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        _popoverController.popoverContentSize = CGSizeMake(320.0, 548.0);
        [_popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:picker animated:YES completion:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)updateImage:(NSDictionary *)userInfo
{
    NSLog(@"UIImagePickerControllerEditedImage : %@",[userInfo objectForKey:UIImagePickerControllerEditedImage]);
    NSLog(@"UIImagePickerControllerCropRect : %@", NSStringFromCGRect([[userInfo objectForKey:UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"UIImagePickerControllerOriginalImage : %@",[userInfo objectForKey:UIImagePickerControllerOriginalImage]);
    NSLog(@"UIImagePickerControllerMediaType : %@",[userInfo objectForKey:UIImagePickerControllerMediaType]);
    NSLog(@"UIImagePickerControllerReferenceURL : %@",[userInfo objectForKey:UIImagePickerControllerReferenceURL]);
    NSLog(@"DZNPhotoPickerControllerAuthorCredits : %@",[userInfo objectForKey:DZNPhotoPickerControllerAuthorCredits]);
    NSLog(@"DZNPhotoPickerControllerSourceName : %@",[userInfo objectForKey:DZNPhotoPickerControllerSourceName]);

    UIImage *image = [userInfo objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"%s %@ size : %@",__FUNCTION__, image, NSStringFromCGSize(image.size));
    
    _imageView.image = image;
    _imageView.contentMode = UIViewContentModeCenter;
}

- (void)saveImage:(NSDictionary *)userInfo
{
    UIImage *image = [userInfo objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
        [self presentImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose Photo", nil)]) {
        [self presentImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Search Photo",nil)]) {
        [self presentPhotoPicker];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.editingMode == DZNPhotoEditViewControllerCropModeCircular) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        DZNPhotoEditViewController *photoEditViewController = [[DZNPhotoEditViewController alloc] initWithImage:image cropMode:DZNPhotoEditViewControllerCropModeCircular];
        [picker pushViewController:photoEditViewController animated:YES];
    }
    else {
        [self updateImage:info];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_popoverController dismissPopoverAnimated:YES];
        }
        else {
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - DZNPhotoPickerControllerDelegate methods

- (void)photoPickerController:(DZNPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)info
{
    [self updateImage:info];
    [self saveImage:info];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)photoPickerControllerDidCancel:(DZNPhotoPickerController *)picker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


@end

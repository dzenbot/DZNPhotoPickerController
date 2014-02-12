//
//  RootViewController.m
//  Sample
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "RootViewController.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"

#import "Private.h"

@interface RootViewController () {
    UIPopoverController *_popoverController;
    NSDictionary *_photoPayload;
}
@end

@implementation RootViewController

+ (void)initialize
{
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerService500px
                                    consumerKey:k500pxConsumerKey
                                  consumerSecret:k500pxConsumerSecret];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceFlickr
                                    consumerKey:kFlickrConsumerKey
                                  consumerSecret:kFlickrConsumerSecret];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGraphicsBeginImageContextWithOptions(_button.frame.size, NO, 0);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _button.frame.size.width, _button.frame.size.height)];
    [[UIColor colorWithWhite:0 alpha:0.25] setFill];
    [clipPath fill];
    [_button setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateHighlighted];
    UIGraphicsEndImageContext();
}


#pragma mark - ViewController methods

- (IBAction)pressButton:(UIButton *)button
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Photo", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Search Photo", nil)];
    
    if (_imageView.image) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Edit Photo", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete Photo", nil)];
    }
    
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet setDelegate:self];
    
    CGRect rect = button.frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rect.origin = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height/2);
    }
    
    [actionSheet showFromRect:rect inView:self.view animated:YES];
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
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)presentPhotoPicker
{
    DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
    picker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr;
    picker.allowsEditing = YES;
    picker.editingMode = DZNPhotoEditViewControllerCropModeSquare;
    picker.delegate = self;
//    picker.initialSearchTerm = @"Nature";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        _popoverController.popoverContentSize = CGSizeMake(320.0, 548.0);
        [_popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)presentPhotoEditor
{
    UIImage *image = [_photoPayload objectForKey:UIImagePickerControllerOriginalImage];
    
    DZNPhotoPickerController *editor = [[DZNPhotoPickerController alloc] initWithEditableImage:image];
    editor.editingMode = [[_photoPayload objectForKey:DZNPhotoPickerControllerCropMode] integerValue];
    editor.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:editor];
        _popoverController.popoverContentSize = CGSizeMake(320.0, 548.0);
        [_popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:editor animated:YES completion:NULL];
    }
}

- (void)updateImage:(NSDictionary *)userInfo
{
    _photoPayload = userInfo;
    
    NSLog(@"OriginalImage : %@",[userInfo objectForKey:UIImagePickerControllerOriginalImage]);
    NSLog(@"EditedImage : %@",[userInfo objectForKey:UIImagePickerControllerEditedImage]);
    NSLog(@"MediaType : %@",[userInfo objectForKey:UIImagePickerControllerMediaType]);
    NSLog(@"CropRect : %@", NSStringFromCGRect([[userInfo objectForKey:UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"CropMode : %@", [userInfo objectForKey:DZNPhotoPickerControllerCropMode]);
    NSLog(@"PhotoAttributes : %@",[userInfo objectForKey:DZNPhotoPickerControllerPhotoAttributes]);
    
    UIImage *image = [userInfo objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    _imageView.image = image;
    [_button setTitle:nil forState:UIControlStateNormal];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
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
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Edit Photo",nil)]) {
        [self presentPhotoEditor];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Delete Photo",nil)]) {
        [_button setTitle:@"Tap Here" forState:UIControlStateNormal];
        _imageView.image = nil;
        _photoPayload = nil;
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.editingMode == DZNPhotoEditViewControllerCropModeCircular) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [DZNPhotoEditViewController editImage:image cropMode:picker.editingMode inNavigationController:picker];
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

//
//  RootViewController.m
//  Sample
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "RootViewController.h"
#import "Private.h"

#import <DZNPhotoPickerController/DZNPhotoPickerController.h>
#import <DZNPhotoPickerController/UIImagePickerController+Edit.h>

@interface RootViewController () {
    UIPopoverController *_popoverController;
    NSDictionary *_photoPayload;
}
@end

@implementation RootViewController

+ (void)initialize
{
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerService500px
                                      consumerKey:k500pxConsumerKey
                                   consumerSecret:k500pxConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceFlickr
                                      consumerKey:kFlickrConsumerKey
                                   consumerSecret:kFlickrConsumerSecret];

    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceInstagram
                                      consumerKey:kInstagramConsumerKey
                                   consumerSecret:kInstagramConsumerSecret];

    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGoogleImages
                                      consumerKey:kGoogleImagesConsumerKey
                                   consumerSecret:kGoogleImagesSearchEngineID];
    
    //Bing does not require a secret. Rather just an "Account Key"
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceBingImages
                                      consumerKey:kBingImagesAccountKey
                                   consumerSecret:nil];

    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGiphy
                                      consumerKey:kGiphyConsumerKey
                                   consumerSecret:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)importImage:(id)sender
{
    [self showImportActionSheet:sender];
}

- (IBAction)editImage:(id)sender
{
    [self showEditActionSheet:sender];
}


#pragma mark - ViewController methods

- (void)showImportActionSheet:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera sender:self.navigationItem.leftBarButtonItem];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Search Photo...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self presentPhotoSearch:self.navigationItem.leftBarButtonItem];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose Photo...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary sender:self.navigationItem.leftBarButtonItem];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        alert.popoverPresentationController.barButtonItem = sender;
    }
    else if ([sender isKindOfClass:[UIView class]]) {
        alert.popoverPresentationController.sourceView = [sender superview];
        alert.popoverPresentationController.sourceRect = [sender frame];
    }
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)showEditActionSheet:(id)sender
{
    if (!self.imageView.image) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Edit Photo...", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self presentPhotoEditor:self.navigationItem.rightBarButtonItem];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Photo", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self resetContent];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        alert.popoverPresentationController.barButtonItem = sender;
    }
    else if ([sender isKindOfClass:[UIView class]]) {
        alert.popoverPresentationController.sourceView = [sender superview];
        alert.popoverPresentationController.sourceRect = [sender frame];
    }
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)presentPhotoSearch:(id)sender
{
    DZNPhotoPickerController *picker = [DZNPhotoPickerController new];
    picker.supportedServices =  DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGiphy;
    picker.allowsEditing = NO;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
    picker.initialSearchTerm = @"Chile";
    picker.enablePhotoDownload = YES;
    picker.allowAutoCompletedSearch = YES;
    picker.infiniteScrollingEnabled = YES;
    picker.title = @"Search Photos";
    
    [picker setFinalizationBlock:^(DZNPhotoPickerController *picker, NSDictionary *info){
        [self updateImageWithPayload:info];
        [self dismissController:picker];
    }];
    
    [picker setFailureBlock:^(DZNPhotoPickerController *picker, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    [picker setCancellationBlock:^(DZNPhotoPickerController *picker){
        [self dismissController:picker];
    }];
    
    [self presentController:picker sender:sender];
}

- (void)presentPhotoEditor:(id)sender
{
    UIImage *image = _photoPayload[UIImagePickerControllerOriginalImage];
    if (!image) image = self.imageView.image;
    
    DZNPhotoEditorViewControllerCropMode cropMode = [_photoPayload[DZNPhotoPickerControllerCropMode] integerValue];

    DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image];
    editor.cropMode = (cropMode != DZNPhotoEditorViewControllerCropModeNone) ? : DZNPhotoEditorViewControllerCropModeSquare;
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:editor];
    
    [editor setAcceptBlock:^(DZNPhotoEditorViewController *editor, NSDictionary *userInfo){
        [self updateImageWithPayload:userInfo];
        [self dismissController:editor];
    }];
    
    [editor setCancelBlock:^(DZNPhotoEditorViewController *editor){
        [self dismissController:editor];
    }];
    
    [self presentController:controller sender:sender];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType sender:(id)sender
{
    __weak __typeof(self)weakSelf = self;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
    
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        
        // Dismiss when the crop mode was disabled
        if (picker.cropMode == DZNPhotoEditorViewControllerCropModeNone) {
            [weakSelf handleImagePicker:picker withMediaInfo:info];
        }
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {
        [weakSelf dismissController:picker];
    };
    
    [self presentController:picker sender:sender];
}

- (void)handleImagePicker:(UIImagePickerController *)picker withMediaInfo:(NSDictionary *)info
{
    [self updateImageWithPayload:info];
    [self dismissController:picker];
}

- (void)updateImageWithPayload:(NSDictionary *)payload
{
    _photoPayload = payload;
    
    NSLog(@"OriginalImage : %@", payload[UIImagePickerControllerOriginalImage]);
    NSLog(@"EditedImage : %@", payload[UIImagePickerControllerEditedImage]);
    NSLog(@"MediaType : %@", payload[UIImagePickerControllerMediaType]);
    NSLog(@"CropRect : %@", NSStringFromCGRect([ payload[UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"ZoomScale : %f", [ payload[DZNPhotoPickerControllerCropZoomScale] floatValue]);

    NSLog(@"CropMode : %@", payload[DZNPhotoPickerControllerCropMode]);
    NSLog(@"PhotoAttributes : %@", payload[DZNPhotoPickerControllerPhotoMetadata]);
    
    UIImage *image = payload[UIImagePickerControllerEditedImage];
    if (!image) image = payload[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = image;
    self.navigationItem.rightBarButtonItem.enabled = image ? YES : NO;
    
//    [self saveImage:image];
}

- (void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)resetContent
{
    _photoPayload = nil;
    self.imageView.image = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)presentController:(UIViewController *)controller sender:(id)sender
{
    if (_popoverController.isPopoverVisible) {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = nil;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.preferredContentSize = CGSizeMake(320.0, 520.0);
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [_popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)dismissController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self handleImagePicker:picker withMediaInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self handleImagePicker:picker withMediaInfo:nil];
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

- (BOOL)shouldAutorotate
{
    return YES;
}

@end

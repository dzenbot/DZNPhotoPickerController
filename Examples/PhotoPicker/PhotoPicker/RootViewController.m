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
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGettyImages
                                      consumerKey:kGettyImagesConsumerKey
                                   consumerSecret:kGettyImagesConsumerSecret];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"DZNPhotoEditorViewControllerCropModeNone : %lu", DZNPhotoEditorViewControllerCropModeNone);
    NSLog(@"DZNPhotoEditorViewControllerCropModeSquare : %lu", DZNPhotoEditorViewControllerCropModeSquare);
    NSLog(@"DZNPhotoEditorViewControllerCropModeCircular : %lu", DZNPhotoEditorViewControllerCropModeCircular);
    NSLog(@"DZNPhotoEditorViewControllerCropModeCustom : %lu", DZNPhotoEditorViewControllerCropModeCustom);
    
    [self resetLayout];
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

- (void)presentPhotoPicker
{
    [self presentPhotoPickerWithImage:nil];
}

- (void)presentPhotoEditor
{
    UIImage *image = _photoPayload[UIImagePickerControllerOriginalImage];
    [self presentPhotoPickerWithImage:image];
}

- (void)presentPhotoPickerWithImage:(UIImage *)image
{
    DZNPhotoPickerController *picker = nil;
    
    if (image && _photoPayload) {
        picker = [[DZNPhotoPickerController alloc] initWithEditableImage:image];
        picker.allowsEditing = YES;
        
        DZNPhotoEditorViewControllerCropMode cropMode = [_photoPayload[DZNPhotoPickerControllerCropMode] integerValue];
        picker.cropMode = cropMode;
    }
    else {
        picker = [DZNPhotoPickerController new];
        picker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGoogleImages;
        picker.allowsEditing = NO;
        picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
        picker.initialSearchTerm = @"California";
        picker.enablePhotoDownload = YES;
        picker.allowAutoCompletedSearch = YES;
    }
    
    picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {
        [self updateImageWithPayload:info];
        [self dismissController:picker];
    };
    
    picker.failureBlock = ^(DZNPhotoPickerController *picker, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
        [self dismissController:picker];
    };
    
    [self presentController:picker];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    __weak __typeof(self)weakSelf = self;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
//    picker.delegate = self;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
    
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        
        // Dismiss when the crop mode was disabled
        if (picker.cropMode == DZNPhotoEditorViewControllerCropModeNone) {
            [weakSelf handleImagePicker:picker withMediaInfo:info];
        }
        
        return weakSelf;
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {
        
        [weakSelf dismissController:picker];
        
        return weakSelf;
    };
    
    [self presentController:picker];
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
    
    [self setButtonImage:image];
//    [self saveImage:image];
}

- (void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)resetLayout
{
    [_button setTitle:@"Tap Here to Start" forState:UIControlStateNormal];
    [_button setBackgroundImage:nil forState:UIControlStateHighlighted];

    _photoPayload = nil;
    _imageView.image = nil;
}

- (void)setButtonImage:(UIImage *)image
{
    _imageView.image = image;
    [_button setTitle:nil forState:UIControlStateNormal];
    
    
    UIGraphicsBeginImageContextWithOptions(_button.frame.size, NO, 0);
    
    CGSize imageSize = CGSizeMake(self.view.frame.size.width, (image.size.height*self.view.frame.size.width)/image.size.width);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, (_button.frame.size.height-imageSize.height)/2, imageSize.width, imageSize.height)];
    [[UIColor colorWithWhite:0 alpha:0.75] setFill];
    [clipPath fill];
    
    [_button setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateHighlighted];
    
    UIGraphicsEndImageContext();
}

- (void)presentController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popoverController.popoverContentSize = CGSizeMake(320.0, 548.0);
        
        [_popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose Photo", nil)]) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Search Photo",nil)]) {
        [self presentPhotoPicker];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Edit Photo",nil)]) {
        [self presentPhotoEditor];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Delete Photo",nil)]) {
        [self resetLayout];
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

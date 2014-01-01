//
//  RootViewController.m
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "RootViewController.h"
#import "UIPhotoPickerController.h"

#define k500pxConsumerKey       @"9sUVdra51AYawcQwQjFaQA7ueUqpaXLEZQJT7Pzy"
#define k500pxConsumerSecret    @"CmmZmHfSu1xi9BfVq4cS5RcAAhnR9UylGzPJQjqc"

#define kFlickrConsumerKey      @"7f8cf8f237f79fef1fff97f253ec341a"
#define kFlickrConsumerSecret   @"c8a8ce8e92912bf9"

@interface RootViewController () {
    UIPopoverController *popoverController;
}
@end

@implementation RootViewController

+ (void)initialize
{
    [UIPhotoPickerController registerForServiceType:UIPhotoPickerControllerServiceType500px
                                    withConsumerKey:k500pxConsumerKey
                                  andConsumerSecret:k500pxConsumerSecret];
    
    [UIPhotoPickerController registerForServiceType:UIPhotoPickerControllerServiceTypeFlickr
                                    withConsumerKey:kFlickrConsumerKey
                                  andConsumerSecret:kFlickrConsumerSecret];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - ViewController methods

- (IBAction)importImage:(UIButton *)button
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) [actionSheet addButtonWithTitle:@"Take Photo"];
    [actionSheet addButtonWithTitle:@"Choose Photo"];
    [actionSheet addButtonWithTitle:@"Search Photos"];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
    
    [actionSheet setDelegate:self];
    
    [actionSheet showFromRect:_button.frame inView:self.view animated:YES];
}


- (void)presentImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *_controller = [[UIImagePickerController alloc] init];
    _controller.allowsEditing = YES;
    _controller.sourceType = sourceType;
    _controller.delegate = self;
    [UIImagePickerController availableMediaTypesForSourceType:0];
    
    [self presentViewController:_controller animated:YES completion:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:_controller];
        [popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:_controller animated:YES completion:NO];
    }
}

- (void)presentPhotoPicker
{
    UIPhotoPickerController *_controller = [[UIPhotoPickerController alloc] init];
    _controller.allowsEditing = YES;
    _controller.serviceType = UIPhotoPickerControllerServiceType500px | UIPhotoPickerControllerServiceTypeFlickr;
    _controller.delegate = self;
    
    [self presentViewController:_controller animated:YES completion:NO];
    
    _controller.startSearchingTerm = @"Surf";

    
//    photoPickerController.editingMode = UIPhotoEditViewControllerCropModeCircular;
//    photoPickerController.customCropSize = CGSizeMake(320.0, 160.0);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:_controller];
//        popoverController.popoverContentSize = CGSizeMake(320.0, 600.0);
        [popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:_controller animated:YES completion:NO];
    }
}

- (void)updateImage:(NSDictionary *)userInfo
{
    NSLog(@"UIImagePickerControllerEditedImage : %@",[userInfo objectForKey:UIImagePickerControllerEditedImage]);
    NSLog(@"UIImagePickerControllerCropRect : %@", NSStringFromCGRect([[userInfo objectForKey:UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"UIImagePickerControllerOriginalImage : %@",[userInfo objectForKey:UIImagePickerControllerOriginalImage]);
    NSLog(@"UIImagePickerControllerMediaType : %@",[userInfo objectForKey:UIImagePickerControllerMediaType]);
    NSLog(@"UIImagePickerControllerReferenceURL : %@",[userInfo objectForKey:UIImagePickerControllerReferenceURL]);
    NSLog(@"UIPhotoPickerControllerAuthorCredits : %@",[userInfo objectForKey:UIPhotoPickerControllerAuthorCredits]);
    NSLog(@"UIPhotoPickerControllerSourceName : %@",[userInfo objectForKey:UIPhotoPickerControllerSourceName]);

    UIImage *image = [userInfo objectForKey:UIImagePickerControllerEditedImage];
//    if (!image) image = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"%s %@ size : %@",__FUNCTION__, image, NSStringFromCGSize(image.size));
    
    _imageView.image = image;
    _imageView.contentMode = UIViewContentModeCenter;
    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Take Photo"]) {
        [self presentImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:@"Choose Photo"]) {
        [self presentImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    else if ([buttonTitle isEqualToString:@"Search Photos"]) {
        [self presentPhotoPicker];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self updateImage:info];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - UIPhotoPickerControllerDelegate methods

- (void)photoPickerController:(UIPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)info
{
    [self updateImage:info];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)photoPickerControllerDidCancel:(UIPhotoPickerController *)picker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
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

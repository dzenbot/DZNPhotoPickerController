//
//  RootViewController.m
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "RootViewController.h"
#import "DZPhotoPickerController.h"

@interface RootViewController () {
    UIPopoverController *popoverController;
}
@end

@implementation RootViewController

+ (void)initialize
{
    [DZPhotoPickerController registerForServiceType:DZPhotoPickerControllerServiceTypeFlickr
                                    withConsumerKey:@"7f8cf8f237f79fef1fff97f253ec341a"
                                  andConsumerSecret:@"c8a8ce8e92912bf9"];
    
    [DZPhotoPickerController registerForServiceType:DZPhotoPickerControllerServiceType500px
                                    withConsumerKey:@"9sUVdra51AYawcQwQjFaQA7ueUqpaXLEZQJT7Pzy"
                                  andConsumerSecret:@"CmmZmHfSu1xi9BfVq4cS5RcAAhnR9UylGzPJQjqc"];
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
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:imagePickerController animated:YES completion:NO];
    }
}

- (void)presentPhotoPicker
{
    DZPhotoPickerController *photoPickerController = [[DZPhotoPickerController alloc] init];
    photoPickerController.allowsEditing = YES;
    photoPickerController.serviceType = DZPhotoPickerControllerServiceType500px | DZPhotoPickerControllerServiceTypeFlickr | DZPhotoPickerControllerServiceTypeInstagram;
    photoPickerController.startSearchingTerm = @"Patagonia";
    photoPickerController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:photoPickerController];
        [popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:photoPickerController animated:YES completion:NO];
    }
}

- (void)updateImage:(NSDictionary *)userInfo
{
    NSLog(@"UIImagePickerControllerEditedImage : %@",[userInfo objectForKey:UIImagePickerControllerEditedImage]);
    NSLog(@"UIImagePickerControllerCropRect : %@", NSStringFromCGRect([[userInfo objectForKey:UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"UIImagePickerControllerOriginalImage : %@",[userInfo objectForKey:UIImagePickerControllerOriginalImage]);
    NSLog(@"UIImagePickerControllerMediaType : %@",[userInfo objectForKey:UIImagePickerControllerMediaType]);
    NSLog(@"UIImagePickerControllerReferenceURL : %@",[userInfo objectForKey:UIImagePickerControllerReferenceURL]);
    NSLog(@"UIImagePickerControllerAuthorCredits : %@",[userInfo objectForKey:UIImagePickerControllerAuthorCredits]);
    NSLog(@"UIImagePickerControllerSourceName : %@",[userInfo objectForKey:UIImagePickerControllerSourceName]);

    UIImage *image = [userInfo objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [userInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"%s %@ size : %@",__FUNCTION__, image, NSStringFromCGSize(image.size));
    
    _imageView.image = image;
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.clipsToBounds = NO;
    
    CGRect rect = _imageView.frame;
    rect.size = image.size;
    _imageView.frame = rect;
    
    _imageView.center = self.view.center;
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"%s",__FUNCTION__);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - DZPhotoPickerControllerDelegate methods

- (void)photoPickerController:(DZPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)info
{
    [self updateImage:info];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)photoPickerControllerDidCancel:(DZPhotoPickerController *)picker
{
    NSLog(@"%s",__FUNCTION__);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
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

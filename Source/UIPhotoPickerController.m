//
//  UIPhotoPickerController.m
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "UIPhotoPickerController.h"
#import "UIPhotoDisplayViewController.h"
#import "UIPhotoEditViewController.h"
#import "UIPhotoDescription.h"

#import <MobileCoreServices/UTCoreTypes.h>

@interface UIPhotoPickerController ()
@end

@implementation UIPhotoPickerController

- (id)init
{
    self = [super init];
    if (self) {
        
        _allowsEditing = NO;
        _serviceType = UIPhotoPickerControllerServiceType500px | UIPhotoPickerControllerServiceTypeFlickr;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kUIPhotoPickerDidFinishPickingNotification object:nil];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showPhotoDisplayController];
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


#pragma mark - Getter methods

/*
 * Returns an array of the available media types for the specified service type.
 */
+ (NSArray *)availableMediaTypesForServiceType:(UIPhotoPickerControllerServiceType)serviceType
{
    return @[(NSString*)kUTTypeImage];
}


#pragma mark - Setter methods

/*
 * Registers for a specified photo search service and enables API transactions.
 */
+ (void)registerForServiceType:(UIPhotoPickerControllerServiceType)serviceType withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret
{
    switch (serviceType) {
        case UIPhotoPickerControllerServiceType500px:
            [PXRequest setConsumerKey:consumerKey consumerSecret:consumerSecret];
            break;
            
        case UIPhotoPickerControllerServiceTypeFlickr:
            [[FlickrKit sharedFlickrKit] initializeWithAPIKey:consumerKey sharedSecret:consumerSecret];
            break;
            
        case UIPhotoPickerControllerServiceTypeGoogleImages:
            break;
            
        case UIPhotoPickerControllerServiceTypeBingImages:
            break;
            
        case UIPhotoPickerControllerServiceTypeYahooImages:
            break;
            
        case UIPhotoPickerControllerServiceTypePanoramio:
            break;
            
        case UIPhotoPickerControllerServiceTypeInstagram:
            break;
            
        default:
            break;
    }
}

/*
 * Sets the custom crop size if not circular crop mode.
 */
- (void)setCustomCropSize:(CGSize)size
{
    if (_editingMode != UIPhotoEditViewControllerCropModeCircular) {
        _editingMode = UIPhotoEditViewControllerCropModeCustom;
        _customCropSize = size;
    }
}


#pragma mark - UIPhotoPickerController methods

/*
 * Shows the photo display controller.
 */
- (void)showPhotoDisplayController
{
    [self setViewControllers:nil];

    UIPhotoDisplayViewController *photoDisplayController = [[UIPhotoDisplayViewController alloc] init];
    photoDisplayController.searchTerm = _initialSearchTerm;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPicker:)];
        [photoDisplayController.navigationItem setRightBarButtonItem:cancel];
    }
    
    [self setViewControllers:@[photoDisplayController]];
}

/*
 * Called by a notification whenever the user picks a photo.
 */
- (void)didPickPhoto:(NSNotification *)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotoWithInfo:)]){
        [self.delegate photoPickerController:self didFinishPickingPhotoWithInfo:notification.userInfo];
    }
}

/*
 * Called whenever the user cancels the picker.
 */
- (void)cancelPicker:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [self.delegate photoPickerControllerDidCancel:self];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

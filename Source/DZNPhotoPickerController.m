//
//  DZNPhotoPickerController.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoPickerController.h"
#import "DZNPhotoDisplayViewController.h"
#import "DZNPhotoEditViewController.h"
#import "DZNPhotoDescription.h"

#import <MobileCoreServices/UTCoreTypes.h>

@interface DZNPhotoPickerController ()
@end

@implementation DZNPhotoPickerController

- (id)init
{
    self = [super init];
    if (self) {
        
        _allowsEditing = NO;
        _serviceType = DZNPhotoPickerControllerServiceType500px | DZNPhotoPickerControllerServiceTypeFlickr;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kDZNPhotoPickerDidFinishPickingNotification object:nil];
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
+ (NSArray *)availableMediaTypesForServiceType:(DZNPhotoPickerControllerServiceType)serviceType
{
    return @[(NSString*)kUTTypeImage];
}


#pragma mark - Setter methods

/*
 * Registers for a specified photo service and enables API transactions.
 */
+ (void)registerForServiceType:(DZNPhotoPickerControllerServiceType)serviceType withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret
{
    switch (serviceType) {
        case DZNPhotoPickerControllerServiceType500px:
            [PXRequest setConsumerKey:consumerKey consumerSecret:consumerSecret];
            break;
            
        case DZNPhotoPickerControllerServiceTypeFlickr:
            [[FlickrKit sharedFlickrKit] initializeWithAPIKey:consumerKey sharedSecret:consumerSecret];
            break;
            
        case DZNPhotoPickerControllerServiceTypeGoogleImages:
            break;
            
        case DZNPhotoPickerControllerServiceTypeBingImages:
            break;
            
        case DZNPhotoPickerControllerServiceTypeYahooImages:
            break;
            
        case DZNPhotoPickerControllerServiceTypePanoramio:
            break;
            
        case DZNPhotoPickerControllerServiceTypeInstagram:
            break;
            
        default:
            break;
    }
}


#pragma mark - DZNPhotoPickerController methods

/*
 * Shows the photo display controller.
 */
- (void)showPhotoDisplayController
{
    [self setViewControllers:nil];

    DZNPhotoDisplayViewController *photoDisplayController = [[DZNPhotoDisplayViewController alloc] init];
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

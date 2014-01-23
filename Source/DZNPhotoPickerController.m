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
@property (nonatomic, getter = isEditing) BOOL editing;
@property (nonatomic, assign) UIImage *editingImage;
@end

@implementation DZNPhotoPickerController

- (id)init
{
    self = [super init];
    if (self) {
        
        _allowsEditing = NO;
        _supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr;
        _supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
    }
    return self;
}

- (instancetype)initWithEditableImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        
        _editingImage = image;
        _editing = YES;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kDZNPhotoPickerDidFinishPickingNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.isEditing) [self showPhotoEditorController];
    else [self showPhotoDisplayController];
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
 * Returns an array whose elements identify the available media types for the supported services.
 */
+ (NSArray *)availableMediaTypesForSupportedServices:(DZNPhotoPickerControllerService)supportedServices
{
    return @[(NSString*)kUTTypeImage];
}

/*
 * Returns the photo service name string.
 */
NSString *NSStringFromServiceType(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:          return @"500px";
        case DZNPhotoPickerControllerServiceFlickr:         return @"Flickr";
        case DZNPhotoPickerControllerServiceGoogleImages:   return @"Google Images";
        case DZNPhotoPickerControllerServiceBingImages:     return @"Bing Images";
        case DZNPhotoPickerControllerServiceYahooImages:    return @"Yahoo Images";
        case DZNPhotoPickerControllerServicePanoramio:      return @"Panoramio";
        case DZNPhotoPickerControllerServiceInstagram:      return @"Instagram";
        case DZNPhotoPickerControllerServiceDribbble:       return @"Dribbble";
        default:                                            return nil;
    }
}


#pragma mark - Setter methods

/*
 * Registers for a specified photo service and enables API transactions.
 */
+ (void)registerForServiceType:(DZNPhotoPickerControllerService)service withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret;
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
            [PXRequest setConsumerKey:consumerKey consumerSecret:consumerSecret];
            break;
            
        case DZNPhotoPickerControllerServiceFlickr:
            [[FlickrKit sharedFlickrKit] initializeWithAPIKey:consumerKey sharedSecret:consumerSecret];
            break;
            
        case DZNPhotoPickerControllerServiceGoogleImages:
            break;
            
        case DZNPhotoPickerControllerServiceBingImages:
            break;
            
        case DZNPhotoPickerControllerServiceYahooImages:
            break;
            
        case DZNPhotoPickerControllerServicePanoramio:
            break;
            
        case DZNPhotoPickerControllerServiceInstagram:
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
 * Shows the photo editor controller.
 */
- (void)showPhotoEditorController
{
    [self setViewControllers:nil];
    DZNPhotoEditViewController *photoEditorController = [[DZNPhotoEditViewController alloc] initWithImage:_editingImage cropMode:self.editingMode];
    
    [self setViewControllers:@[photoEditorController]];
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

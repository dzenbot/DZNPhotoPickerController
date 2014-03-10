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
#import "DZNPhotoServiceFactory.h"

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
        _enablePhotoDownload = YES;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:DZNPhotoPickerDidFinishPickingNotification object:nil];
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

+ (NSArray *)availableMediaTypesForSupportedServices:(DZNPhotoPickerControllerService)supportedServices
{
    return @[(NSString *)kUTTypeImage];
}


#pragma mark - Setter methods

- (void)setSupportedServices:(DZNPhotoPickerControllerService)services
{
    NSAssert(services > 0, @"You must set at least 1 service to be supported.");
    _supportedServices = services;
}

+ (void)registerService:(DZNPhotoPickerControllerService)service consumerKey:(NSString *)key consumerSecret:(NSString *)secret subscription:(DZNPhotoPickerControllerSubscription)subscription
{
    [DZNPhotoServiceFactory setConsumerKey:key consumerSecret:secret service:service subscription:subscription];
}


#pragma mark - DZNPhotoPickerController methods

/*
 * Shows the photo display controller.
 */
- (void)showPhotoDisplayController
{
    [self setViewControllers:nil];
    
    DZNPhotoDisplayViewController *controller = [[DZNPhotoDisplayViewController alloc] init];
    controller.searchTerm = _initialSearchTerm;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPicker:)];
        [controller.navigationItem setRightBarButtonItem:cancel];
    }
    
    [self setViewControllers:@[controller]];
}

/*
 * Shows the photo editor controller.
 */
- (void)showPhotoEditorController
{
    [self setViewControllers:nil];
    
    DZNPhotoEditViewController *controller = [[DZNPhotoEditViewController alloc] initWithImage:_editingImage cropMode:self.editingMode];
    [self setViewControllers:@[controller]];
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
    DZNPhotoDisplayViewController *controller = (DZNPhotoDisplayViewController *)[self.viewControllers objectAtIndex:0];
    if ([controller respondsToSelector:@selector(stopLoadingRequest)]) {
        [controller stopLoadingRequest];
    }
    
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
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

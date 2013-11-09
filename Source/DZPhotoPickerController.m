//
//  DZPhotoPickerController.m
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "DZPhotoPickerController.h"
#import "DZPhotoDisplayController.h"
#import "DZPhoto.h"

@interface DZPhotoPickerController ()
@end

@implementation DZPhotoPickerController

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhoto:) name:kDZPhotoPickerChooseNotification object:nil];
    }
    return self;
}

- (instancetype)initWithImageForEditing:(UIImage *)image
{
    self = [[DZPhotoPickerController alloc] init];
    if (self) {
        
    }
    return self;
}

#pragma mark - View lifecycle

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

+ (NSArray *)availableMediaTypesForServiceType:(DZPhotoPickerControllerServiceType)serviceType
{
    return nil;
}


#pragma mark - Setter methods

+ (void)registerForServiceType:(DZPhotoPickerControllerServiceType)serviceType withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret
{
    switch (serviceType) {
        case DZPhotoPickerControllerServiceTypeFlickr:
            [[FlickrKit sharedFlickrKit] initializeWithAPIKey:consumerKey sharedSecret:consumerSecret];
            break;
            
        case DZPhotoPickerControllerServiceType500px:
            [PXRequest setConsumerKey:consumerKey consumerSecret:consumerSecret];
            break;
            
        case DZPhotoPickerControllerServiceTypeInstagram:
            [NRGramKit setClientId:consumerKey clientSecret:consumerSecret andClientCallbackURL:nil];
            break;
            
        case DZPhotoPickerControllerServiceTypeGoogleImages:
            break;
            
        case DZPhotoPickerControllerServiceTypeBingImages:
            break;
            
        case DZPhotoPickerControllerServiceTypeYahooImages:
            break;
            
        default:
            break;
    }
}


#pragma mark - DZPhotoPickerController methods

- (void)showPhotoDisplayController
{
    [self setViewControllers:nil];
    
    if (_serviceType == 0) {
        _serviceType = DZPhotoPickerControllerServiceType500px | DZPhotoPickerControllerServiceTypeFlickr;
    }
    
    DZPhotoDisplayController *photoDisplayController = [[DZPhotoDisplayController alloc] init];
    photoDisplayController.searchTerm = _startingSearchTerm;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPicker:)];
    [photoDisplayController.navigationItem setRightBarButtonItem:rightButton];
    
    [self setViewControllers:@[photoDisplayController]];
}

- (void)didPickPhoto:(NSNotification *)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotoWithInfo:)]){
        [self.delegate photoPickerController:self didFinishPickingPhotoWithInfo:notification.userInfo];
    }
}

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
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

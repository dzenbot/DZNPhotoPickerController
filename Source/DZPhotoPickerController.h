//
//  DZPhotoPickerController.h
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZPhotoDisplayController.h"
#import "DZPhotoEditViewController.h"

@protocol DZPhotoPickerControllerDelegate;

typedef NS_OPTIONS(NSUInteger, DZPhotoPickerControllerServiceType) {
    DZPhotoPickerControllerServiceType500px = (1 << 0),
    DZPhotoPickerControllerServiceTypeFlickr = (1 << 1),
    DZPhotoPickerControllerServiceTypeInstagram = (1 << 2),
    DZPhotoPickerControllerServiceTypeGoogleImages = (1 << 3),
    DZPhotoPickerControllerServiceTypeBingImages = (1 << 4),
    DZPhotoPickerControllerServiceTypeYahooImages = (1 << 5)
};

/* 
 */
@interface DZPhotoPickerController : UINavigationController

/* */
@property (nonatomic, assign) id <UINavigationControllerDelegate, DZPhotoPickerControllerDelegate> delegate;
/* The multi-type of image providers to be supported by the controller. Default value are ServiceType500px & ServiceTypeFlickr. */
@property (nonatomic) DZPhotoPickerControllerServiceType serviceType;
/* A Boolean value indicating whether the user is allowed to edit a selected image. */
@property (nonatomic) BOOL allowsEditing;
/* */
@property (nonatomic) DZPhotoEditViewControllerCropMode editingMode;
/* */
@property (nonatomic, copy) NSString *startSearchingTerm;


/*
 *
 */
- (instancetype)initWithImageForEditing:(UIImage *)image;

/*
 *
 */
+ (NSArray *)availableMediaTypesForServiceType:(DZPhotoPickerControllerServiceType)serviceType;

/*
 *
 */
+ (void)registerForServiceType:(DZPhotoPickerControllerServiceType)serviceType withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret;


@end


@protocol DZPhotoPickerControllerDelegate <NSObject>
@required

/*
 *
 */
- (void)photoPickerController:(DZPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)userInfo;

/*
 *
 */
- (void)photoPickerControllerDidCancel:(DZPhotoPickerController *)picker;

@end

//
//  DZNPhotoPickerController.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "DZNPhotoEditViewController.h"

@protocol DZNPhotoPickerControllerDelegate;

/* 
 * A photo search/picker for iOS 7, similar to UIImagePickerControl, providing photos from popular photography like 500px, Flickr and many others.
 * This framework tries to mimic as close as possible the native UIImagePickerController API for iOS7, in terms of features, appearance and behavior.
 *
 * @discussion Due to Terms of Use of some photo services, the images cannot be cached when showing thumbnails results and full screen images.
 */
@interface DZNPhotoPickerController : UINavigationController

/* The photo picker's delegate object. */
@property (nonatomic, assign) id <UINavigationControllerDelegate, DZNPhotoPickerControllerDelegate> delegate;
/* The photo services to be supported by the controller. Default values are 500px & Flickr. */
@property (nonatomic) DZNPhotoPickerControllerService supportedServices;
/* A Boolean value indicating whether the user is allowed to edit a selected image. Default value is NO. */
@property (nonatomic) BOOL allowsEditing;
/* An optional string term for auto-starting the photo search, as soon as the picker is presented. */
@property (nonatomic, copy) NSString *initialSearchTerm;
/* The editing mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic) DZNPhotoEditViewControllerCropMode editingMode;
/* The supported licenses of photos to search. Default value is "All CC Reserved Attributions". Pending implementation. */
@property (nonatomic) DZNPhotoPickerControllerCCLicense supportedLicenses;
/* A Boolean value indicating whether the picker should download the photo after selecting it when allowsEditing is NO. Default value is YES. */
@property (nonatomic) BOOL enablePhotoDownload;

/*
 * Initializes and returns a newly created picker controller, on edit mode only.
 *
 * @discussion This is a convenience method for initializing the receiver and pushing a photo edit view controller onto the navigation stack, with a presetted image to edit.
 *
 * @param image The image to be edited.
 * @returns The initialized picker controller.
 */
- (instancetype)initWithEditableImage:(UIImage *)image;

/*
 * Returns an array of the available media types for the specified service type.
 *
 * @discussion Only kUTTypeImage will be returned for now. Maybe on a future, this library could have video and audio search support.
 * 
 * @param services The specified supported services.
 * @return An array whose elements identify the available media types for the supported services.
 */
+ (NSArray *)availableMediaTypesForSupportedServices:(DZNPhotoPickerControllerService)services;

/*
 * Registers for a specified photo service and enables API transactions.
 *
 * @discussion You must create an app for every photo service you'd like to use, and generate a consumer key and secret from their sites. Run this method on when initializing the view controller that will use DZNPhotoPickerController, typically in the +initialize method.
 *
 * @param service The photo service to register (i.e. 500px, Flickr, Google Images, etc.)
 * @param consumerKey The API consumer key.
 * @param consumerSecret The API consumer secret token.
 */
+ (void)registerService:(DZNPhotoPickerControllerService)service consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

@end


@protocol DZNPhotoPickerControllerDelegate <NSObject>
@required

/*
 * Tells the delegate that the user picked a new photo.
 *
 * @see UIImagePickerControllerDelegate
 *
 * @param picker The controller object managing the photo search picker interface.
 * @param userInfo A dictionary containing the original image and the edited image. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in “Editing Information Keys”.
 */
- (void)photoPickerController:(DZNPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)userInfo;

/*
 * Tells the delegate that the user cancelled the pick operation.
 * Your delegate’s implementation of this method should dismiss the picker view by calling the dismissModalViewControllerAnimated: method of the parent view controller.
 * Implementation of this method is optional, but expected.
 *
 * @see UIImagePickerControllerDelegate
 *
 * @param picker The controller object managing the image picker interfac
 */
- (void)photoPickerControllerDidCancel:(DZNPhotoPickerController *)picker;

@end

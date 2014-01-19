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

/*
 * A set of supported photo services
 */
typedef NS_OPTIONS(NSUInteger, DZNPhotoPickerControllerService) {
    DZNPhotoPickerControllerService500px = (1 << 0),            // 500px            http://500px.com/developers/
    DZNPhotoPickerControllerServiceFlickr = (1 << 1),           // Flickr           http://www.flickr.com/services/api/
    DZNPhotoPickerControllerServiceGoogleImages = (1 << 3),     // Google Images    https://developers.google.com/image-search/
    DZNPhotoPickerControllerServiceBingImages = (1 << 4),       // Bing Images      http://datamarket.azure.com/dataset/bing/search/
    DZNPhotoPickerControllerServiceYahooImages = (1 << 5),      // Yahoo Images     http://developer.yahoo.com/boss/search/
    DZNPhotoPickerControllerServicePanoramio = (1 << 6),        // Panoramio        http://www.panoramio.com/api/
    DZNPhotoPickerControllerServiceInstagram = (1 << 7),        // Instagram        http://instagram.com/developer/
    DZNPhotoPickerControllerServiceDribbble = (1 << 8)          // Dribbble         http://dribbble.com/api/
};

/*
 * A set of Creative Commons licences defined in http://creativecommons.org/licenses/
 */
typedef NS_OPTIONS(NSUInteger, DZNPhotoPickerControllerCCLicense) {
    DZNPhotoPickerControllerCCLicenseBY_ZERO = -1,              // No Rights Reserved                       http://creativecommons.org/about/cc0
    DZNPhotoPickerControllerCCLicenseBY_ALL = 0,                // All CC Reserved Attributions
    DZNPhotoPickerControllerCCLicenseBY = (1 << 0),             // All Rights Reserved Attribution          http://creativecommons.org/licenses/by/4.0
    DZNPhotoPickerControllerCCLicenseBY_SA = (1 << 1),          // Attribution-ShareAlike                   http://creativecommons.org/licenses/by-sa/4.0
    DZNPhotoPickerControllerCCLicenseBY_ND = (1 << 2),          // Attribution-NoDerivs                     http://creativecommons.org/licenses/by-nd/4.0
    DZNPhotoPickerControllerCCLicenseBY_NC = (1 << 3),          // Attribution-NonCommercial                http://creativecommons.org/licenses/by-nc/4.0
    DZNPhotoPickerControllerCCLicenseBY_NC_SA = (1 << 4),       // Attribution-NonCommercial-ShareAlike     http://creativecommons.org/licenses/by-nc-sa/4.0
    DZNPhotoPickerControllerCCLicenseBY_NC_ND = (1 << 5)        // Attribution-NonCommercial-NoDerivs       http://creativecommons.org/licenses/by-nc-nd/4.0
};

static NSString *DZNPhotoPickerControllerAuthorCredits = @"DZNPhotoPickerControllerAuthorCredits";
static NSString *DZNPhotoPickerControllerSourceName = @"DZNPhotoPickerControllerAuthorCredits";
static NSString *kDZNPhotoPickerDidFinishPickingNotification = @"kDZNPhotoPickerDidFinishPickingNotification";

@protocol DZNPhotoPickerControllerDelegate;

/* 
 * A photo picker for iOS 7 using popular photo services like 500px, Flickr and many others.
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

/*
 * Returns an array of the available media types for the specified service type.
 * NOTE: For now, this will only return kUTTypeImage. Maybe on a future, this library could have video and audio search support.
 * 
 * @param serviceType The specified service type.
 * @return An array whose elements identify the available media types for the supported services.
 */
+ (NSArray *)availableMediaTypesForSupportedServices:(DZNPhotoPickerControllerService)supportedServices;

/*
 * Returns the photo service name string.
 *
 * @param service The specified service type.
 * @return The photo service name.
 */
NSString *NSStringFromServiceType(DZNPhotoPickerControllerService service);

/*
 * Registers for a specified photo service and enables API transactions.
 * NOTE: Run this on startup with your consumer key and secret, for every service type you will need.
 *
 * @param service The photo service to register, such as 500px, Flickr, Google Images, etc.
 * @param consumerKey The API consumer key.
 * @param consumerSecret The API consumer secret token.
 *
 * @discussion You must create an app for every photo service you'd like to use, and generate a consumer key and secret from their sites.
 */
+ (void)registerForServiceType:(DZNPhotoPickerControllerService)service withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret;

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

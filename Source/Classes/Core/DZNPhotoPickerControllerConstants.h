//
//  DZNPhotoPickerControllerConstants.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

extern NSString *const DZNPhotoPickerControllerCropMode;              // An NSString (i.e. square, circular)
extern NSString *const DZNPhotoPickerControllerCropZoomScale;         // An NSString (from 1.0 to maximum zoom scale, 2.0f)
extern NSString *const DZNPhotoPickerControllerPhotoMetadata;         // An NSDictionary containing metadata from a captured photo

extern NSString *const DZNPhotoPickerDidFinishPickingNotification;    // The notification key used when picking a photo finished.
extern NSString *const DZNPhotoPickerDidFailPickingNotification;      // The notification key used when picking a photo failed.

/**
 Types of supported photo services
 */
typedef NS_OPTIONS(NSUInteger, DZNPhotoPickerControllerServices) {
    DZNPhotoPickerControllerService500px = (1 << 0),                        // 500px                        http://developers.500px.com/
    DZNPhotoPickerControllerServiceFlickr = (1 << 1),                       // Flickr                       http://www.flickr.com/services/api/
    DZNPhotoPickerControllerServiceInstagram = (1 << 2),                    // Instagram                    http://instagram.com/developer/
    DZNPhotoPickerControllerServiceGoogleImages = (1 << 3),                 // Google Images                https://developers.google.com/custom-search/
    DZNPhotoPickerControllerServiceBingImages = (1 << 4),                   // Bing Images                  http://datamarket.azure.com/dataset/bing/search/
    DZNPhotoPickerControllerServiceGiphy = (1 << 5),                        // Giphy                        http://api.giphy.com/v1/gifs/search/
};

/**
 Types of Creative Commons licences.
 Defined in http://creativecommons.org/licenses/
 
 Additional license info:
 500px: http://500px.com/creativecommons/
 Flickr: http://flickr.com/creativecommons/
 */
typedef NS_OPTIONS(NSUInteger, DZNPhotoPickerControllerCCLicenses) {
    DZNPhotoPickerControllerCCLicenseBY_ZERO = -1,              // No Rights Reserved                       http://creativecommons.org/about/cc0
    DZNPhotoPickerControllerCCLicenseBY_ALL = 0,                // All CC Reserved Attributions
    DZNPhotoPickerControllerCCLicenseBY = (1 << 0),             // All Rights Reserved Attribution          http://creativecommons.org/licenses/by/4.0
    DZNPhotoPickerControllerCCLicenseBY_SA = (1 << 1),          // Attribution-ShareAlike                   http://creativecommons.org/licenses/by-sa/4.0
    DZNPhotoPickerControllerCCLicenseBY_ND = (1 << 2),          // Attribution-NoDerivs                     http://creativecommons.org/licenses/by-nd/4.0
    DZNPhotoPickerControllerCCLicenseBY_NC = (1 << 3),          // Attribution-NonCommercial                http://creativecommons.org/licenses/by-nc/4.0
    DZNPhotoPickerControllerCCLicenseBY_NC_SA = (1 << 4),       // Attribution-NonCommercial-ShareAlike     http://creativecommons.org/licenses/by-nc-sa/4.0
    DZNPhotoPickerControllerCCLicenseBY_NC_ND = (1 << 5)        // Attribution-NonCommercial-NoDerivs       http://creativecommons.org/licenses/by-nc-nd/4.0
};

/**
 Types of supported crop modes.
 */
typedef NS_ENUM(NSInteger, DZNPhotoEditorViewControllerCropMode) {
    DZNPhotoEditorViewControllerCropModeNone = 0,
    DZNPhotoEditorViewControllerCropModeSquare,
    DZNPhotoEditorViewControllerCropModeCircular,
    DZNPhotoEditorViewControllerCropModeCustom
};

/**
 Types of photo service subscription (i.e. Free, Paid)
 For a few services, there is a limitation in terms of request per day/week/month and results per page (i.e. Google Custom Search API, Yahoo, Bing & Getty Images).
 You can subscribe to those services and register them as SubscriptionPaid for getting unlimited requests and results.
 */
typedef NS_ENUM(NSInteger, DZNPhotoPickerControllerSubscription) {
    DZNPhotoPickerControllerSubscriptionFree,
    DZNPhotoPickerControllerSubscriptionPaid
};

/**
 Returns a photo service name string.
 
 @param service The specified service type.
 @returns The photo service name.
 */
extern NSString *NSStringFromService(DZNPhotoPickerControllerServices services);

/**
 Returns a list of photo service name strings.
 
 @param services The bitmap of service types.
 @returns The list of photo service names.
 */
extern NSArray *NSArrayFromServices(DZNPhotoPickerControllerServices services);

/**
 *
 Returns a photo service type from name.
 
 @param name The specified service name.
 @returns The photo service type.
 */
extern DZNPhotoPickerControllerServices DZNPhotoServiceFromName(NSString *name);

/**
 Returns the first photo service type from a bitmask of services.
 
 @param services The bitmask of services.
 @returns The photo service type.
 */
extern DZNPhotoPickerControllerServices DZNFirstPhotoServiceFromPhotoServices(DZNPhotoPickerControllerServices services);

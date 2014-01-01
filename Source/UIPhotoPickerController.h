//
//  UIPhotoPickerController.h
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "UIPhotoEditViewController.h"

typedef NS_OPTIONS(NSUInteger, UIPhotoPickerControllerServiceType) {
    UIPhotoPickerControllerServiceType500px = (1 << 0),             // 500px            http://500px.com/developers/
    UIPhotoPickerControllerServiceTypeFlickr = (1 << 1),            // Flickr           http://www.flickr.com/services/api/
    UIPhotoPickerControllerServiceTypeGoogleImages = (1 << 3),      // Google Images    https://developers.google.com/image-search/
    UIPhotoPickerControllerServiceTypeBingImages = (1 << 4),        // Bing Images      http://datamarket.azure.com/dataset/bing/search/
    UIPhotoPickerControllerServiceTypeYahooImages = (1 << 5),       // Yahoo Images     http://developer.yahoo.com/boss/search/
    UIPhotoPickerControllerServiceTypePanoramio = (1 << 6),         // Panoramio        http://www.panoramio.com/api/
    UIPhotoPickerControllerServiceTypeInstagram = (1 << 7),         // Instagram        http://instagram.com/developer/
    UIPhotoPickerControllerServiceTypeDribbble = (1 << 8)           // Dribbble         http://dribbble.com/api/
};

NSString *const kUIPhotoPickerDidChooseNotification;
NSString *const UIPhotoPickerControllerAuthorCredits;
NSString *const UIPhotoPickerControllerSourceName;

@protocol UIPhotoPickerControllerDelegate;


/* A simple photo picker for iOS, using common services like 500px, Flickr and many others.
 * This framework tries to mimic as much as possible the native UIImagePickerController API, in terms of features, appearance and behavior.
 */
@interface UIPhotoPickerController : UINavigationController

/* The photo picker’s delegate object. */
@property (nonatomic, assign) id <UINavigationControllerDelegate, UIPhotoPickerControllerDelegate> delegate;
/* The multi-type of image providers to be supported by the controller. Default value are ServiceType500px & ServiceTypeFlickr. */
@property (nonatomic) UIPhotoPickerControllerServiceType serviceType;
/* An optional string term for auto-starting the photo search, as soon as the picker is presented. */
@property (nonatomic, copy) NSString *startSearchingTerm;
/* A Boolean value indicating whether the user is allowed to edit a selected image. */
@property (nonatomic) BOOL allowsEditing;
/* The editing mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic) UIPhotoEditViewControllerCropMode editingMode;
/* An optional and custom croping size. */
@property (nonatomic) CGSize customCropSize;


/*
 * Initializes the photo picker only for editing a specified image.
 *
 * @param image The image to be edited.
 * @return A new instance of the photo picker controller.
 */
- (instancetype)initWithImageForEditing:(UIImage *)image;

/*
 * Returns an array of the available media types for the specified service type.
 * NOTE: For now, this will only return kUTTypeImage, until video and audio is supported.
 * 
 * @param serviceType The specified service type.
 * @return An array whose elements identify the available media types for the specified source type.
 */
+ (NSArray *)availableMediaTypesForServiceType:(UIPhotoPickerControllerServiceType)serviceType;

/*
 * Registers for a specified service type, and enables API transactions.
 * NOTE: Run this on startup with your consumer key and secret, for every service type you will need.
 *
 * @param serviceType The image service provider, such as 500px, Flickr, Google Images, etc.
 * @param consumerKey The API consumer key.
 * @param consumerSecret The API consumer secret token.
 *
 * @discussion You must create an app for every image provider, and get the key and secret form them.
 * Here are the developer websites where you can create these apps:
 * Flickr: http://www.flickr.com/services/developer/
 * 500px: http://developers.500px.com/
 * Instagram: http://instagram.com/developer/
 */
+ (void)registerForServiceType:(UIPhotoPickerControllerServiceType)serviceType withConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret;


@end


@protocol UIPhotoPickerControllerDelegate <NSObject>
@required

/*
 * Tells the delegate that the user picked a new photo.
 *
 * @see UIImagePickerControllerDelegate
 *
 * @param picker The controller object managing the photo search picker interface.
 * @param userInfo A dictionary containing the original image and the edited image. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in “Editing Information Keys”.
 */
- (void)photoPickerController:(UIPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)userInfo;

/*
 * Tells the delegate that the user cancelled the pick operation.
 * Your delegate’s implementation of this method should dismiss the picker view by calling the dismissModalViewControllerAnimated: method of the parent view controller.
 * Implementation of this method is optional, but expected.
 *
 * @see UIImagePickerControllerDelegate
 *
 * @param picker The controller object managing the image picker interfac
 */
- (void)photoPickerControllerDidCancel:(UIPhotoPickerController *)picker;

@end

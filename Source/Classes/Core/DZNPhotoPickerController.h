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
#import "DZNPhotoEditorViewController.h"

@protocol DZNPhotoPickerControllerDelegate;

/** 
 A photo search/picker for iOS 7, similar to UIImagePickerControl, providing photos from popular photography like 500px, Flickr and many others.
 This framework tries to mimic as close as possible the native UIImagePickerController API for iOS7, in terms of features, appearance and behaviour.
 
 @discussion Due to Terms of Use of some photo services, the images can only be cached in memory, but not the device's hard drive.
 */
@interface DZNPhotoPickerController : UINavigationController

typedef void (^DZNPhotoPickerControllerFinalizationBlock)(DZNPhotoPickerController *picker, NSDictionary *info);
typedef void (^DZNPhotoPickerControllerFailureBlock)(DZNPhotoPickerController *picker, NSError *error);
typedef void (^DZNPhotoPickerControllerCancellationBlock)(DZNPhotoPickerController *picker);

/** The photo picker's delegate object. */
@property (nonatomic, assign) id <UINavigationControllerDelegate, DZNPhotoPickerControllerDelegate> delegate;
/** The photo services to be supported by the controller. Default are 500px & Flickr. */
@property (nonatomic) DZNPhotoPickerControllerServices supportedServices;
/** YES if the user is allowed to edit a selected image. Default is NO. */
@property (nonatomic) BOOL allowsEditing;
/** An optional string term for auto-starting the photo search, as soon as the picker is presented. */
@property (nonatomic, copy) NSString *initialSearchTerm;
/** The cropping mode (ie: Square, Circular or Custom). Default is Square. */
@property (nonatomic, assign) DZNPhotoEditorViewControllerCropMode cropMode;
/** The cropping size (i.e. 320,320). When setting this property manually, the cropMode is overidden to DZNPhotoEditorViewControllerCropModeCustom. */
@property (nonatomic, assign) CGSize cropSize;
/** The supported licenses of photos to search. Default is "All CC Reserved Attributions". Pending implementation. */
@property (nonatomic) DZNPhotoPickerControllerCCLicenses supportedLicenses;
/** YES if the picker should download the full size photo after selecting its thumbnail, when allowsEditing is NO. Default is YES. */
@property (nonatomic) BOOL enablePhotoDownload;
/** A block to be executed whenever the user pickes a new photo. Use this block to replace delegate method photoPickerController:didFinishPickingPhotoWithInfo: */
@property (nonatomic, strong) DZNPhotoPickerControllerFinalizationBlock finalizationBlock;
/** A block to be executed whenever an error occurs while picking a photo. Use this block to replace delegate method photoPickerController:didFailedPickingPhotoWithError: */
@property (nonatomic, strong) DZNPhotoPickerControllerFailureBlock failureBlock;
/** A block to be executed whenever the user cancels the pick operation. Use this block to replace delegate method photoPickerControllerDidCancel: */
@property (nonatomic, strong) DZNPhotoPickerControllerCancellationBlock cancellationBlock;
/** YES if auto-completion search is available while the user is typing on the search bar. This data uses Flickr's tag search API. Default is YES. */
@property (nonatomic, assign) BOOL allowAutoCompletedSearch;
/** YES if images should load automatically once reaching the bottom of the scroll view. Default is NO. */
@property (nonatomic, assign) BOOL infiniteScrollingEnabled;

/**
 Returns an array of the available media types for the specified service type.
 @discussion Only kUTTypeImage will be returned for now. Maybe on a future, this library could have video and audio search support.
 
 @param services The specified supported services.
 @return An array whose elements identify the available media types for the supported services.
 */
+ (NSArray *)availableMediaTypesForSupportedServices:(DZNPhotoPickerControllerServices)services;

/**
 Registers a FREE (or demo) specified photo service.
 @discussion This is a convenience method of +registerService:consumerKey:consumerSecret:subscription:
 */
+ (void)registerFreeService:(DZNPhotoPickerControllerServices)service consumerKey:(NSString *)key consumerSecret:(NSString *)secret;

/**
 Registers a specified photo service.
 @discussion You must create an app for every photo service you'd like to use, and generate a consumer key and secret from their sites. Run this method on when initializing the view controller that will use DZNPhotoPickerController, typically in the +initialize method.
 
 @param service The photo service to register (i.e. 500px, Flickr, Google Images, etc.)
 @param key The API consumer key.
 @param secret The API consumer secret token.
 @param subscription The photo service subscription type (i.e. Free & Paid). This param only affects Google Images API for now.
 */
+ (void)registerService:(DZNPhotoPickerControllerServices)service consumerKey:(NSString *)key consumerSecret:(NSString *)secret subscription:(DZNPhotoPickerControllerSubscription)subscription;

@end


/**
 The DZNPhotoPickerControllerDelegate protocol defines methods that your delegate object can implement to interact with the image picker interface. The methods of this protocol notify your delegate when the user either picks a photo, or cancels the picker operation.
 You can also use the finalizationBlock and cancellationBlock instead of the delegate methods.
 */
@protocol DZNPhotoPickerControllerDelegate <NSObject>
@required

/**
 Tells the delegate that the user picked a new photo.
 
 @param picker The controller object managing the photo search picker interface.
 @param userInfo A dictionary containing the original image and the edited image. The dictionary also contains any relevant editing information (crop size, crop mode). For exiting keys @see DZNPhotoPickerControllerConstants.h.
 */
- (void)photoPickerController:(DZNPhotoPickerController *)picker didFinishPickingPhotoWithInfo:(NSDictionary *)userInfo;


/**
 Tells the delegate that picking a photo has failed.
 
 @param picker The controller object managing the photo search picker interface.
 @param error The error
 */
- (void)photoPickerController:(DZNPhotoPickerController *)picker didFailedPickingPhotoWithError:(NSError *)error;

/**
 Tells the delegate that the user cancelled the pick operation.
 @discussion Your delegate’s implementation of this method should dismiss the picker view by calling the dismissModalViewControllerAnimated: method of the parent view controller.
 Implementation of this method is optional, but expected.
 
 @param picker The controller object managing the image picker interface.
 */
- (void)photoPickerControllerDidCancel:(DZNPhotoPickerController *)picker;

@end

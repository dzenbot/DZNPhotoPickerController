//
//  DZNPhotoServiceConstants.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/14/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerControllerConstants.h"

/**
 Returns an unique key for saving data to NSUserDefaults.
 
 @param type An integer enum type (ie: DZNPhotoPickerControllerService500px)
 @param key A constant string key (ie: DZNPhotoServiceClientSubscription)
 @returns A unique key.
 */
UIKIT_EXTERN NSString *NSUserDefaultsUniqueKey(NSUInteger type, NSString *key);

/**
 Returns a base URL for creating an HTTP client based on the specified service.
 */
UIKIT_EXTERN NSURL *baseURLForService(DZNPhotoPickerControllerServices service);

/**
 Returns a key path for tags, to retrieve them from a JSON structure, for a specified service.
 */
UIKIT_EXTERN NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerServices service);

/**
 Returns the url path for tag search, for a specified service.
 */
UIKIT_EXTERN NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerServices service);

/**
 Returns a key path for photos, to retrieve them from a JSON structure, for a specified service.
 */
UIKIT_EXTERN NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerServices service);

/**
 Returns the url path for photo search, for a specified service.
 */
UIKIT_EXTERN NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerServices service);

/**
 Returns the url path for authentication, for a specified service.
 */
UIKIT_EXTERN NSString *authUrlPathForService(DZNPhotoPickerControllerServices service);

/**
 Returns a key to be used for setting a consumer identifier value, for a specified service.
 */
UIKIT_EXTERN NSString *keyForAPIConsumerKey(DZNPhotoPickerControllerServices service);

/**
 Returns a key to be used for setting a consumer secret value, for a specified service.
 */
UIKIT_EXTERN NSString *keyForAPIConsumerSecret(DZNPhotoPickerControllerServices service);

/**
 Returns a key to be used for setting a photo search term value, for a specified service.
 */
UIKIT_EXTERN NSString *keyForSearchTerm(DZNPhotoPickerControllerServices service);

/**
 Returns a key to be used for setting a tag search term value, for a specified service.
 */
UIKIT_EXTERN NSString *keyForSearchTag(DZNPhotoPickerControllerServices service);

/**
 Returns a key to be used for setting a search result value per page, for a specified service.
 */
UIKIT_EXTERN NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerServices service);

/**
 Returns a key to be used for retrieving search tag content, for a specified service.
 */
UIKIT_EXTERN NSString *keyForSearchTagContent(DZNPhotoPickerControllerServices service);

/**
 Returns a key path for photos or tags, to retrieve them from a JSON structure, for a specified service and object name.
 */
UIKIT_EXTERN NSString *keyPathForObjectName(DZNPhotoPickerControllerServices service, NSString *objectName);

/**
 Determines if the service requires a consumer secret.
 */
UIKIT_EXTERN BOOL isConsumerSecretRequiredForService(DZNPhotoPickerControllerServices services);

/**
 Determines if the service requires the consumer key to be posted as part of the request parameters.
 */
UIKIT_EXTERN BOOL isConsumerKeyInParametersRequiredForService(DZNPhotoPickerControllerServices services);

/**
 Determines if the service requires any sort of authentification (Only Auth2 is supported for now).
 */
UIKIT_EXTERN BOOL isAuthenticationRequiredForService(DZNPhotoPickerControllerServices services);


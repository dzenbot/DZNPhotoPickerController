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
extern NSString *NSUserDefaultsUniqueKey(NSUInteger type, NSString *key);

/** Returns a base URL for creating an HTTP client based on the specified service. */
extern NSURL *baseURLForService(DZNPhotoPickerControllerServices service);

/** Returns a key path for tags, to retrieve them from a JSON structure, for a specified service. */
extern NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerServices service);

/** Returns the url path for tag search, for a specified service. */
extern NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerServices service);

/** Returns a key path for photos, to retrieve them from a JSON structure, for a specified service. */
extern NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerServices service);

/** Returns the url path for photo search, for a specified service. */
extern NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for setting a consumer identifier value, for a specified service. */
extern NSString *keyForAPIConsumerKey(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for setting a consumer secret value, for a specified service. */
extern NSString *keyForAPIConsumerSecret(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for setting a photo search term value, for a specified service. */
extern NSString *keyForSearchTerm(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for setting a tag search term value, for a specified service. */
extern NSString *keyForSearchTag(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for setting a search result value per page, for a specified service. */
extern NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for setting the search page, for a specified service. */
extern NSString *keyForSearchPage(DZNPhotoPickerControllerServices service);

/** Returns a key to be used for retrieving search tag content, for a specified service. */
extern NSString *keyForSearchTagContent(DZNPhotoPickerControllerServices service);

/** Returns a key path for photos or tags, to retrieve them from a JSON structure, for a specified service and object name. */
extern NSString *keyPathForObjectName(DZNPhotoPickerControllerServices service, NSString *objectName);

/** Determines if the service requires a consumer secret. */
extern BOOL isConsumerSecretRequiredForService(DZNPhotoPickerControllerServices services);

/** Determines if the service requires the consumer key to be posted as part of the request parameters. */
extern BOOL isConsumerKeyInParametersRequiredForService(DZNPhotoPickerControllerServices services);


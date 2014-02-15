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

UIKIT_EXTERN NSString *const DZNPhotoServiceClientConsumerKey;
UIKIT_EXTERN NSString *const DZNPhotoServiceClientConsumerSecret;

@interface DZNPhotoServiceConstants : NSObject
@end

UIKIT_EXTERN NSString *NSUserDefaultsUniqueKey(DZNPhotoPickerControllerService type, NSString *key);


UIKIT_EXTERN NSURL *baseURLForService(DZNPhotoPickerControllerService service);


UIKIT_EXTERN NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerService service);


UIKIT_EXTERN NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerService service);


UIKIT_EXTERN NSString *keyForAPIConsumerKey(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *keyForAPIConsumerSecret(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *keyForSearchTerm(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *keyForSearchTag(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *keyForSearchTagContent(DZNPhotoPickerControllerService service);

UIKIT_EXTERN NSString *keyPathForObjectName(DZNPhotoPickerControllerService service, NSString *objectName);

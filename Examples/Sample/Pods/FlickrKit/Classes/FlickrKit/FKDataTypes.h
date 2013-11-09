//
//  FKDataTypes.h
//  FlickrKit
//
//  Created by David Casserly on 03/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

typedef void (^FKAPIImageUploadCompletion)(NSString *imageID, NSError *error);
typedef void (^FKAPIRequestCompletion)(NSDictionary *response, NSError *error);
typedef void (^FKAPIAuthBeginCompletion)(NSURL *flickrLoginPageURL, NSError *error);
typedef void (^FKAPIAuthCompletion)(NSString *userName, NSString *userId, NSString *fullName, NSError *error);

extern NSString *const FKFlickrKitErrorDomain; // Errors internally from Flickr KIT
extern NSString *const FKFlickrAPIErrorDomain; // Error originating from Flickr API

#pragma mark - Error Codes

typedef enum {
	FKErrorURLParsing		= 100,
	FKErrorResponseParsing  = 101,
    FKErrorEmptyResponse    = 102,
	
	FKErrorNoInternet		= 200,
	
	FKErrorAuthenticating	= 300,
	FKErrorNoTokenToCheck	= 301,
	FKErrorNotAuthorized	= 302,
    
	FKErrorInvalidArgs      = 400,
} FKError;

#pragma mark - Flickr API Endpoint

extern NSString *const FKFlickrRESTAPI;

typedef enum {
    FKPhotoSizeUnknown = 0,
    FKPhotoSizeCollectionIconLarge,
    FKPhotoSizeBuddyIcon,
	FKPhotoSizeSmallSquare75,
    FKPhotoSizeLargeSquare150,
	FKPhotoSizeThumbnail100,
	FKPhotoSizeSmall240,
    FKPhotoSizeSmall320,
    FKPhotoSizeMedium500,
    FKPhotoSizeMedium640,
    FKPhotoSizeMedium800,
    FKPhotoSizeLarge1024,
    FKPhotoSizeLarge1600,
    FKPhotoSizeLarge2048,
    FKPhotoSizeOriginal,
    FKPhotoSizeVideoOriginal,
    FKPhotoSizeVideoHDMP4,
    FKPhotoSizeVideoSiteMP4,
    FKPhotoSizeVideoMobileMP4,
    FKPhotoSizeVideoPlayer,
} FKPhotoSize;

typedef enum {
	FKPermissionRead,
	FKPermissionWrite,
	FKPermissionDelete
} FKPermission;

NSString *FKPermissionStringForPermission(FKPermission permission);

NSString *FKIdentifierForSize(FKPhotoSize size);


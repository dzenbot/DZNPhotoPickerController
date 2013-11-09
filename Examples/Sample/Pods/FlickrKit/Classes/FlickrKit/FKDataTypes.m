//
//  FKDataTypes.m
//  FlickrKit
//
//  Created by David Casserly on 03/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDataTypes.h"

#pragma mark - Error Codes

NSString *const FKFlickrKitErrorDomain = @"com.devedup.flickrkit.ErrorDomain";
NSString *const FKFlickrAPIErrorDomain = @"com.devedup.flickrapi.ErrorDomain";

#pragma mark - Flickr API Endpoint

NSString *const FKFlickrRESTAPI = @"http://api.flickr.com/services/rest/";

NSString *FKPermissionStringForPermission(FKPermission permission) {
	switch (permission) {
		case FKPermissionRead:
			return @"READ";
		case FKPermissionWrite:
			return @"WRITE";
		case FKPermissionDelete:
			return @"DELETE";
	}
}

NSString *FKIdentifierForSize(FKPhotoSize size) {
	static NSArray *identifiers = nil;
	if (!identifiers) {
        identifiers = @[@"",
					   @"collectionIconLarge",
					   @"buddyIcon",
					   @"s",
					   @"q",
					   @"t",
					   @"m",
					   @"n",
					   @"",
					   @"z",
					   @"c",
					   @"b",
					   @"h",
					   @"k",
					   @"o",
					   @"",
					   @"",
					   @"",
					   @"",
					   @""]; 
    }
    return identifiers[size];
}
//
//  DZNPhotoServiceFactory.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerControllerConstants.h"
#import "DZNPhotoServiceClientProtocol.h"

/**
 A factory manager for creating multiple HTTP clients based on a photo search service.
 This is main object to be used to API calls.
 */
@interface DZNPhotoServiceFactory : NSObject

/**
 Returns the service’s default factory.
 
 @return The current service’s default factory, which is used for creating different HTTP service clients.
 */
+ (instancetype)defaultFactory;

/**
 Returns photo service client conforming its protocol, by either creating a new instance or reusing a previously created client.
 
 @param service The specified photo service.
 @return The photo service client.
 */
- (id<DZNPhotoServiceClientProtocol>)clientForService:(DZNPhotoPickerControllerServices)service;

/**
 Saves on NSUserDefaults API key and secret for a specific photo service.
 
 @param consumerKey The API consumer key.
 @param consumerSecret The API consumer secret token.
 @param service The photo service to save (i.e. 500px, Flickr, Google Images, etc.)
 */
+ (void)setConsumerKey:(NSString *)key consumerSecret:(NSString *)secret service:(DZNPhotoPickerControllerServices)service subscription:(DZNPhotoPickerControllerSubscription)subscription;

/**
 Resets the factory, by releasing all cached HTTP clients.
 */
- (void)reset;

@end

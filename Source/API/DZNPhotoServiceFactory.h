//
//  DZNPhotoServiceFactory.h
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerControllerConstants.h"
#import "DZNPhotoServiceClientProtocol.h"

/*
 * A factory manager for creating multiple HTTP clients based on a photo search service.
 * This is main object to be used to API calls.
 */
@interface DZNPhotoServiceFactory : NSObject


+ (instancetype)defaultFactory;

- (id<DZNPhotoServiceClientProtocol>)clientForService:(DZNPhotoPickerControllerService)service;

- (void)reset;

+ (void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret service:(DZNPhotoPickerControllerService)service;

@end

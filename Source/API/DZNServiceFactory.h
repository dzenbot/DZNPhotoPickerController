//
//  DZNServiceFactory.h
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerConstants.h"
#import "DZNClientProtocol.h"

@interface DZNServiceFactory : NSObject

+ (instancetype)defaultFactory;

- (id<DZNClientProtocol>)clientForService:(DZNPhotoPickerControllerService)service;

- (void)reset;

+ (void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret service:(DZNPhotoPickerControllerService)service;

@end

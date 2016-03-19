//
//  DZNPhotoServiceClient.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "AFNetworking.h"
#import "DZNPhotoServiceClientProtocol.h"
#import "DZNPhotoPickerControllerConstants.h"

extern NSString *const DZNPhotoServiceClientConsumerKey;
extern NSString *const DZNPhotoServiceClientConsumerSecret;
extern NSString *const DZNPhotoServiceClientSubscription;

extern NSString *const DZNPhotoServiceCredentialIdentifier;
extern NSString *const DZNPhotoServiceCredentialAccessToken;

/**
 The HTTP service client used to interact with multiple RESTful APIs for photo search services.
 */
@interface DZNPhotoServiceClient : AFHTTPSessionManager <DZNPhotoServiceClientProtocol>

/**
 Initializes a new HTTP service client.
 
 @param service The specific photo search service.
 @param subscription The photo search service subscription.
 @return A new instance of an HTTP service client.
 */
- (instancetype)initWithService:(DZNPhotoPickerControllerServices)service subscription:(DZNPhotoPickerControllerSubscription)subscription;

@end

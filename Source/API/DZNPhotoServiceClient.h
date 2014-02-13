//
//  DZNPhotoServiceClient.h
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "AFHTTPClient.h"
#import "DZNPhotoPickerControllerConstants.h"
#import "DZNPhotoServiceClientProtocol.h"

/*
 * The HTTP service client used to interact with multiple RESTful APIs for photo search services.
 */
@interface DZNPhotoServiceClient : AFHTTPClient <DZNPhotoServiceClientProtocol>

/* The current photo service. */
@property (nonatomic) DZNPhotoPickerControllerService service;

/*
 * Initializes a new HTTP service client.
 *
 * @param service The specific photo search service.
 * @return A new instance of an HTTP service client.
 */
- (instancetype)initWithService:(DZNPhotoPickerControllerService)service;

@end

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

@interface DZNPhotoServiceClient : AFHTTPClient <DZNPhotoServiceClientProtocol>

@property (nonatomic) DZNPhotoPickerControllerService service;

- (instancetype)initWithService:(DZNPhotoPickerControllerService)service;

@end

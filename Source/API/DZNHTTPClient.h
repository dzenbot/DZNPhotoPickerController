//
//  DZNHTTPClient.h
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "AFHTTPClient.h"
#import "DZNPhotoPickerConstants.h"
#import "DZNClientProtocol.h"

@interface DZNHTTPClient : AFHTTPClient <DZNClientProtocol>

@property (nonatomic) DZNPhotoPickerControllerService service;


- (instancetype)initWithService:(DZNPhotoPickerControllerService)service;

@end

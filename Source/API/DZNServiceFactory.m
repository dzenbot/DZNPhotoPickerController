//
//  DZNServiceFactory.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNServiceFactory.h"
#import "DZNHTTPClient.h"

@interface DZNServiceFactory ()
@property (nonatomic, strong) NSMutableArray *clients;
@end

@implementation DZNServiceFactory

+ (instancetype)defaultFactory
{
    static DZNServiceFactory *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [DZNServiceFactory new];
        _sharedInstance.clients = [NSMutableArray new];
    });
    return _sharedInstance;
}

- (id<DZNClientProtocol>)clientForService:(DZNPhotoPickerControllerService)service
{
    return nil;
}

@end

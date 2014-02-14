//
//  DZNPhotoServiceFactory.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNPhotoServiceFactory.h"
#import "DZNPhotoServiceClient.h"

NSString *const DZNPhotoServiceClientConsumerKey = @"DZNPhotoServiceClientConsumerKey";
NSString *const DZNPhotoServiceClientConsumerSecret = @"DZNPhotoServiceClientConsumerSecret";

@interface DZNPhotoServiceFactory ()
@property (nonatomic, strong) NSMutableArray *clients;
@end

@implementation DZNPhotoServiceFactory

+ (instancetype)defaultFactory
{
    static DZNPhotoServiceFactory *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [DZNPhotoServiceFactory new];
        _sharedInstance.clients = [NSMutableArray new];
    });
    return _sharedInstance;
}


#pragma mark - Getter methods

- (id<DZNPhotoServiceClientProtocol>)clientForService:(DZNPhotoPickerControllerService)service
{
    for (DZNPhotoServiceClient *client in self.clients) {
        if (client.service == service) {
            return client;
        }
    }
        
    DZNPhotoServiceClient *client = [[DZNPhotoServiceClient alloc] initWithService:service];
    [self.clients addObject:client];
    
    return client;
}

NSString *NSStringHashFromServiceType(DZNPhotoPickerControllerService type, NSString *key)
{
    return [NSString stringWithFormat:@"%@%@", key, NSStringFromServiceType(type)];
}


#pragma mark - Setter methods

+ (void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret service:(DZNPhotoPickerControllerService)service
{
    NSAssert(consumerKey, @"\"consumerKey\" cannot be nil.");
    NSAssert(consumerSecret, @"\"consumerSecret\" cannot be nil.");
    NSAssert((service == DZNPhotoPickerControllerService500px || service == DZNPhotoPickerControllerServiceFlickr), @"Only 500px and Flickr are supported at this moment.");

    [[NSUserDefaults standardUserDefaults] setObject:consumerKey forKey:NSStringHashFromServiceType(service, DZNPhotoServiceClientConsumerKey)];
    [[NSUserDefaults standardUserDefaults] setObject:consumerSecret forKey:NSStringHashFromServiceType(service, DZNPhotoServiceClientConsumerSecret)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - DZNPhotoServiceFactory methods

- (void)reset
{
    for (id<DZNPhotoServiceClientProtocol> client in _clients) {
        [client cancelRequest];
    }
    
    _clients = nil;
    _clients = [NSMutableArray new];
}

@end

//
//  DZNPhotoServiceFactory.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoServiceFactory.h"
#import "DZNPhotoServiceClient.h"
#import "DZNPhotoServiceConstants.h"

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

- (id<DZNPhotoServiceClientProtocol>)clientForService:(DZNPhotoPickerControllerServices)service
{
    for (DZNPhotoServiceClient *client in self.clients) {
        if (client.service == service) {
            return client;
        }
    }
    
    NSString *consumerKey = [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientConsumerKey)];
    
    if (!consumerKey) {
        return nil;
    }
    
    DZNPhotoPickerControllerSubscription subscription = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientSubscription)] integerValue];
    
    DZNPhotoServiceClient *client = [[DZNPhotoServiceClient alloc] initWithService:service subscription:subscription];
    [self.clients addObject:client];
    
    return client;
}


#pragma mark - Setter methods

+ (void)setConsumerKey:(NSString *)key consumerSecret:(NSString *)secret service:(DZNPhotoPickerControllerServices)service subscription:(DZNPhotoPickerControllerSubscription)subscription
{
    NSAssert(key, @"'key' cannot be nil");
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientConsumerKey)];
    
    if (isConsumerSecretRequiredForService(service)) {
        
        NSAssert(secret, @"'secret' cannot be nil");
        
        [[NSUserDefaults standardUserDefaults] setObject:secret forKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientConsumerSecret)];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(subscription) forKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientSubscription)];
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

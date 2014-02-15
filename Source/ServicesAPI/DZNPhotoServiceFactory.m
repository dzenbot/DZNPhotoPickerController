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
#import "DZNPhotoServiceEndpoints.h"

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


#pragma mark - Setter methods

+ (void)setConsumerKey:(NSString *)key consumerSecret:(NSString *)secret service:(DZNPhotoPickerControllerService)service
{
    NSAssert(key, @"\"key\" cannot be nil.");
    NSAssert(secret, @"\"secret\" cannot be nil.");
    NSAssert((service == DZNPhotoPickerControllerService500px ||
              service == DZNPhotoPickerControllerServiceFlickr ||
              service == DZNPhotoPickerControllerServiceInstagram ||
              service == DZNPhotoPickerControllerServiceGoogleImages), @"Only 500px, Flickr, Instagram & Google Images are supported at this moment.");

    [[NSUserDefaults standardUserDefaults] setObject:key forKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientConsumerKey)];
    [[NSUserDefaults standardUserDefaults] setObject:secret forKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceClientConsumerSecret)];
    
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

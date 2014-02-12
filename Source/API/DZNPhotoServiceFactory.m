//
//  DZNPhotoServiceFactory.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNPhotoServiceFactory.h"
#import "DZNPhotoServiceClient.h"

#import <CommonCrypto/CommonDigest.h>

NSString *const DZNPhotoServiceClientConsumerKey = @"DZNPhotoServiceClientConsumerKey";
NSString *const DZNPhotoServiceClientConsumerSecret = @"DZNPhotoServiceClientConsumerSecret";

@interface NSString (hash)
@end

@implementation NSString (hash)

- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
    CC_SHA1(data.bytes, data.length, digest);
#pragma clang diagnostic pop
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end

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

+ (void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret service:(DZNPhotoPickerControllerService)service
{
    NSAssert(consumerKey, @"Please provide a non-null consumer key.");
    NSAssert(consumerSecret, @"Please provide a non-null consumer key.");
    
    [[NSUserDefaults standardUserDefaults] setObject:consumerKey forKey:NSStringHashFromServiceType(service, DZNPhotoServiceClientConsumerKey)];
    [[NSUserDefaults standardUserDefaults] setObject:consumerSecret forKey:NSStringHashFromServiceType(service, DZNPhotoServiceClientConsumerSecret)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *NSStringHashFromServiceType(DZNPhotoPickerControllerService type, NSString *key)
{
    NSString *appended = [NSString stringWithFormat:@"%@%@", key, NSStringFromServiceType(type)];
    return [appended sha1];
}


#pragma mark - DZNPhotoServiceFactory methods

- (void)reset
{
    _clients = nil;
    _clients = [NSMutableArray new];
}

@end

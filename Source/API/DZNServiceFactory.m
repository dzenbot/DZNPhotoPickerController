//
//  DZNServiceFactory.m
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNServiceFactory.h"
#import "DZNHTTPClient.h"

#import <CommonCrypto/CommonDigest.h>

NSString *const DZNHTTPClientConsumerKey = @"DZNHTTPClientConsumerKey";
NSString *const DZNHTTPClientConsumerSecret = @"DZNHTTPClientConsumerSecret";

@interface NSString (hash)
@end

@implementation NSString (hash)

- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end

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


#pragma mark - Getter methods

- (id<DZNClientProtocol>)clientForService:(DZNPhotoPickerControllerService)service
{
    for (DZNHTTPClient *client in self.clients) {
        if (client.service == service) {
            return client;
        }
    }
    
    DZNHTTPClient *client = [[DZNHTTPClient alloc] initWithService:service];
    [self.clients addObject:client];
    
    return client;
}

+ (void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret service:(DZNPhotoPickerControllerService)service
{
    NSAssert(consumerKey, @"Please provide a non-null consumer key.");
    NSAssert(consumerSecret, @"Please provide a non-null consumer key.");
    
    [[NSUserDefaults standardUserDefaults] setObject:consumerKey forKey:NSStringHashFromServiceType(service, DZNHTTPClientConsumerKey)];
    [[NSUserDefaults standardUserDefaults] setObject:consumerSecret forKey:NSStringHashFromServiceType(service, DZNHTTPClientConsumerSecret)];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *NSStringHashFromServiceType(DZNPhotoPickerControllerService type, NSString *key)
{
    NSString *appended = [NSString stringWithFormat:@"%@%@", key, NSStringFromServiceType(type)];
    return [appended sha1];
}


#pragma mark - DZNServiceFactory methods

- (void)reset
{
    _clients = nil;
    _clients = [NSMutableArray new];
}

@end

//
//  FKAPI.h
//  FlickrKit
//
//  Created by David Casserly on 27/05/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import <UIKit/UIKit.h>
#import "FKDUDiskCache.h"
#import "FKDataTypes.h"
#import "FKFlickrNetworkOperation.h"
#import "FKImageUploadNetworkOperation.h"
#import "FKFlickrAPIMethod.h"
#import "FKAPIMethods.h"

@class FKFlickrNetworkOperation;

@interface FlickrKit : NSObject

//You can inject your own disk cache if you like, or just use the default one and ignore this
@property (nonatomic, strong) id<FKDUDiskCache> diskCache;
// Flickr API Key
@property (nonatomic, strong, readonly) NSString *apiKey;
@property (nonatomic, strong, readonly) NSString *secret;
// Auth
@property (nonatomic, strong, readonly) NSString *authToken;
@property (nonatomic, strong, readonly) NSString *authSecret;
@property (nonatomic, assign, readonly) FKPermission permissionGranted;

+ (FlickrKit *) sharedFlickrKit;

#pragma mark - Initialisation - run this on startup with your API key and Shared Secret
- (void) initializeWithAPIKey:(NSString *)apiKey sharedSecret:(NSString *)secret;

#pragma mark - Flickr Data Requests - using basic string and dictionary
- (FKFlickrNetworkOperation *) call:(NSString * )apiMethod args:(NSDictionary *)requestArgs completion:(FKAPIRequestCompletion)completion; //doesn't use the cache
- (FKFlickrNetworkOperation *) call:(NSString *)apiMethod args:(NSDictionary *)requestArgs maxCacheAge:(FKDUMaxAge)maxAge completion:(FKAPIRequestCompletion)completion; //with caching specified

#pragma mark - Flickr Using the Model Objects
- (FKFlickrNetworkOperation *) call:(id<FKFlickrAPIMethod>)method completion:(FKAPIRequestCompletion)completion; //doesn't use the cache
- (FKFlickrNetworkOperation *) call:(id<FKFlickrAPIMethod>)method maxCacheAge:(FKDUMaxAge)maxAge completion:(FKAPIRequestCompletion)completion; //with caching specified

@end


#pragma mark - Authentication
@interface FlickrKit (Authentication)

// Check if they are authorized
@property (nonatomic, assign, readonly, getter = isAuthorized) BOOL authorized;

// 1. Begin Authorization, onSuccess display authURL in a UIWebView - the url is a callback into your app with a URL scheme
- (FKDUNetworkOperation *) beginAuthWithCallbackURL:(NSURL *)url permission:(FKPermission)permission completion:(FKAPIAuthBeginCompletion)completion;
// 2. After they login and authorize the app, need to get an auth token - this will happen via your URL scheme - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
- (FKDUNetworkOperation *) completeAuthWithURL:(NSURL *)url completion:(FKAPIAuthCompletion)completion;
// 3. On returning to the app, you want to re-log them in automatically - do it here
- (FKFlickrNetworkOperation *) checkAuthorizationOnCompletion:(FKAPIAuthCompletion)completion;
// 4. Logout - just removes all the stored keys
- (void) logout;

@end


#pragma mark - Building Photo URLs
@interface FlickrKit (ImageURL)

// Build your own from the components required
- (NSURL *) photoURLForSize:(FKPhotoSize)size photoID:(NSString *)photoID server:(NSString *)server secret:(NSString *)secret farm:(NSString *)farm;
// Utility methods to extract the photoID/server/secret/farm from the input
- (NSURL *) photoURLForSize:(FKPhotoSize)size fromPhotoDictionary:(NSDictionary *)photoDict;
- (NSURL *) buddyIconURLForUser:(NSString *)userID;

@end


#pragma mark - Photo Upload
@interface FlickrKit (PhotoUpload)

- (FKImageUploadNetworkOperation *) uploadImage:(UIImage *)image args:(NSDictionary *)args completion:(FKAPIImageUploadCompletion)completion;

@end


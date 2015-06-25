//
//  DZNPhotoServiceClient.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoServiceClient.h"

#import "DZNPhotoServiceConstants.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "GROAuth2SessionManager.h"

@interface DZNPhotoServiceClient ()
@property (nonatomic, copy) DZNHTTPRequestCompletion completion;
@end

@implementation DZNPhotoServiceClient
@synthesize service = _service;
@synthesize subscription = _subscription;
@synthesize loading = _loading;

- (instancetype)initWithService:(DZNPhotoPickerControllerServices)service subscription:(DZNPhotoPickerControllerSubscription)subscription
{
    self = [super initWithBaseURL:baseURLForService(service)];
    if (self) {

        _service = service;
        _subscription = subscription;

        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];

        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

        [self configureHTTPHeader];
    }
    return self;
}

- (void)configureHTTPHeader
{
    NSString *consumerKey = [self consumerKey];

    if (!consumerKey) {
        return;
    }

    NSString *accessToken = [self accessToken];

    // Add basic auth to Bing service
    if (self.service == DZNPhotoPickerControllerServiceBingImages) {

        //Bing requires basic auth with password and user name as the consumer key.
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:consumerKey password:consumerKey];
    }
    else if (self.service == DZNPhotoPickerControllerServiceGettyImages) {

        // Getty Images requires authentification via the custom 'Api-Key' HTTP Header
        [self.requestSerializer setValue:consumerKey forHTTPHeaderField:@"Api-Key"];

        if (accessToken) {
            // Getty Images requires basic auth with access token via the standard Authorization HTTP header as type Bearer.
            [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
        }
    }
}


#pragma mark - Getters

- (NSString *)consumerKey
{
    return [self cachedValueForKey:DZNPhotoServiceClientConsumerKey];
}

- (NSString *)consumerSecret
{
    return [self cachedValueForKey:DZNPhotoServiceClientConsumerSecret];
}

- (NSString *)credentialIdentifier
{
    return [self cachedValueForKey:DZNPhotoServiceCredentialIdentifier];
}

- (NSString *)accessToken
{
    NSString *identifier = [self credentialIdentifier];

    if (!identifier) {
        return nil;
    }

    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:identifier];

    // If still found but expired, the credential is deleted and returns nil
    if (credential.isExpired) {
        [AFOAuthCredential deleteCredentialWithIdentifier:identifier];
        return nil;
    }

    return credential.accessToken;
}

- (NSString *)cachedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsUniqueKey(self.service, key)];
}

- (NSDictionary *)tagsParamsWithKeyword:(NSString *)keyword
{
    NSAssert(keyword, @"'keyword' cannot be nil for %@", NSStringFromService(self.service));
    NSAssert([self consumerKey], @"'consumerKey' cannot be nil for %@", NSStringFromService(self.service));
    NSAssert([self consumerSecret], @"'consumerSecret' cannot be nil for %@", NSStringFromService(self.service));

    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self consumerKey] forKey:keyForAPIConsumerKey(self.service)];
    [params setObject:keyword forKey:keyForSearchTag(self.service)];

    if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        [params setObject:tagSearchUrlPathForService(self.service) forKey:@"method"];
        [params setObject:@"json" forKey:@"format"];
    }

    return params;
}

- (NSDictionary *)photosParamsWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage
{
    NSAssert(keyword, @"'keyword' cannot be nil for %@", NSStringFromService(self.service));
    NSAssert((resultPerPage > 0), @"'result per page' must be higher than 0 for %@", NSStringFromService(self.service));
    NSAssert([self consumerKey], @"'consumerKey' cannot be nil for %@", NSStringFromService(self.service));
    if (isConsumerSecretRequiredForService(self.service)) {
        NSAssert([self consumerSecret], @"'consumerSecret' cannot be nil for %@", NSStringFromService(self.service));
    }

    NSMutableDictionary *params = [NSMutableDictionary new];

    if (isConsumerKeyInParametersRequiredForService(self.service)) {
        [params setObject:[self consumerKey] forKey:keyForAPIConsumerKey(self.service)];
    }

    //Bing requires parameters to be wrapped in '' values.
    if (self.service == DZNPhotoPickerControllerServiceBingImages) {
        [params setObject:[NSString stringWithFormat:@"'%@'", keyword] forKey:keyForSearchTerm(self.service)];
    } else {
        [params setObject:keyword forKey:keyForSearchTerm(self.service)];
    }

    if (keyForSearchResultPerPage(self.service)) {
        [params setObject:@(resultPerPage) forKey:keyForSearchResultPerPage(self.service)];
    }
    if (self.service == DZNPhotoPickerControllerService500px || self.service == DZNPhotoPickerControllerServiceFlickr || self.service == DZNPhotoPickerControllerServiceGettyImages) {
        [params setObject:@(page) forKey:@"page"];
    }

    if (self.service == DZNPhotoPickerControllerService500px)
    {
        [params setObject:@[@(2),@(4)] forKey:@"image_size"];
        [params setObject:@"Nude" forKey:@"exclude"];
    }
    else if (self.service == DZNPhotoPickerControllerServiceFlickr)
    {
        [params setObject:photoSearchUrlPathForService(self.service) forKey:@"method"];
        [params setObject:@"json" forKey:@"format"];
        [params setObject:@"photos" forKey:@"media"];
        [params setObject:@"relevance" forKey:@"sort"];
        [params setObject:@(YES) forKey:@"in_gallery"];
        [params setObject:@(1) forKey:@"safe_search"];
        [params setObject:@(1) forKey:@"content_type"];
    }
    else if (self.service == DZNPhotoPickerControllerServiceGoogleImages)
    {
        [params setObject:[self consumerSecret] forKey:keyForAPIConsumerSecret(self.service)];
        [params setObject:@"image" forKey:@"searchType"];
        [params setObject:@"medium" forKey:@"safe"];
        if (page > 1) [params setObject:@((page - 1) * resultPerPage + 1) forKey:@"start"];
    }
    else if (self.service == DZNPhotoPickerControllerServiceBingImages)
    {
        [params setObject:@"'Moderate'" forKey:@"Adult"];

        //Default to size medium. Size Large causes some buggy behavior with download times.
        [params setObject:@"'Size:Medium'" forKey:@"ImageFilters"];
    }
    else if (self.service == DZNPhotoPickerControllerServiceGettyImages)
    {
        [params setObject:@"id,thumb,artist,comp,max_dimensions" forKey:@"fields"];
        [params setObject:@"photography" forKey:@"graphical_styles"];
        [params setObject:@"true" forKey:@"exclude_nudity"];
    }

    return params;
}

- (NSData *)processData:(NSData *)data
{
    if (self.service == DZNPhotoPickerControllerServiceFlickr) {

        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *responsePrefix = @"jsonFlickrApi(";

        if ([string rangeOfString:responsePrefix].location != NSNotFound) {
            string = [[string stringByReplacingOccurrencesOfString:responsePrefix withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
            return [string dataUsingEncoding:NSUTF8StringEncoding];
        }
    }

    return data;
}

- (NSArray *)parseObjects:(Class)class withJSON:(NSDictionary *)json
{
    NSString *keyPath = keyPathForObjectName(self.service, [class name]);
    NSMutableArray *objects = [NSMutableArray arrayWithArray:[json valueForKeyPath:keyPath]];

    if ([[class name] isEqualToString:[DZNPhotoTag name]]) {

        if (self.service == DZNPhotoPickerControllerServiceFlickr) {
            NSString *keyword = [json valueForKeyPath:@"tags.source"];
            if (keyword) [objects insertObject:@{keyForSearchTagContent(self.service):keyword} atIndex:0];
        }

        return [DZNPhotoTag photoTagListFromService:self.service withResponse:objects];
    }
    else if ([[class name] isEqualToString:[DZNPhotoMetadata name]]) {
        return [DZNPhotoMetadata metadataListWithResponse:objects service:self.service];
    }

    return nil;
}


#pragma mark - Setters

- (void)setCredentialIdentifier:(NSString *)identifier service:(DZNPhotoPickerControllerServices)service
{
    NSAssert(identifier, @"'identifier' cannot be nil");

    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:NSUserDefaultsUniqueKey(service, DZNPhotoServiceCredentialIdentifier)];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self configureHTTPHeader];
}


#pragma mark - Requests

- (void)searchTagsWithKeyword:(NSString *)keyword completion:(DZNHTTPRequestCompletion)completion
{
    NSString *path = tagSearchUrlPathForService(self.service);

    NSDictionary *params = [self tagsParamsWithKeyword:keyword];
    [self getObject:[DZNPhotoTag class] path:path params:params completion:completion];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword page:(NSInteger)page resultPerPage:(NSInteger)resultPerPage completion:(DZNHTTPRequestCompletion)completion
{
    NSString *path = photoSearchUrlPathForService(self.service);

    NSDictionary *params = [self photosParamsWithKeyword:keyword page:page resultPerPage:resultPerPage];
    [self getObject:[DZNPhotoMetadata class] path:path params:params completion:completion];
}

- (void)getObject:(Class)class path:(NSString *)path params:(NSDictionary *)params completion:(DZNHTTPRequestCompletion)completion
{
    _loading = YES;

    if (isAuthenticationRequiredForService(self.service) && ![self accessToken])
    {
        [self authenticateWithClientKey:[self consumerKey] secret:[self consumerSecret]
                       completion:^(NSString *accessToken, NSError *error) {

                           if (!error) {
                               [self getObject:class path:path params:params completion:completion];
                           }
                           else {
                               _loading = NO;
                               if (completion) completion(nil, error);
                           }
                       }];
        return;
    }

    if (self.service == DZNPhotoPickerControllerServiceInstagram) {
        NSString *keyword = [params objectForKey:keyForSearchTerm(self.service)];
        NSString *encodedKeyword = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
        path = [path stringByReplacingOccurrencesOfString:@"%@" withString:encodedKeyword];
    }
    else if (self.service == DZNPhotoPickerControllerServiceFlickr) {
        path = @"";
    }

    NSLog(@"GET %@ %@", path, params);

    [self GET:path parameters:params
      success:^(AFHTTPRequestOperation *operation, id response) {

          NSData *data = [self processData:response];
          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];

          _loading = NO;
          if (completion) completion([self parseObjects:class withJSON:json], nil);

      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

          _loading = NO;
          if (completion) completion(nil, error);
      }];
}

- (void)cancelRequest
{
    [self.operationQueue cancelAllOperations];
}


#pragma mark - Authentication

- (void)authenticateWithClientKey:(NSString *)key secret:(NSString *)secret completion:(void (^)(NSString *accessToken, NSError *error))completion;
{
    NSURL *baseURL = baseURLForService(self.service);
    GROAuth2SessionManager *sessionManager = [GROAuth2SessionManager managerWithBaseURL:baseURL clientID:key secret:secret];

    NSString *path = authUrlPathForService(self.service);

    NSDictionary *params = @{};

    if (self.service == DZNPhotoPickerControllerServiceGettyImages) {
        params = @{@"grant_type":@"client_credentials"};
    }

    [sessionManager authenticateUsingOAuthWithPath:path
                                        parameters:params
                                           success:^(AFOAuthCredential *credential) {
                                               [self setCredentialIdentifier:sessionManager.serviceProviderIdentifier service:self.service];
                                               [AFOAuthCredential storeCredential:credential withIdentifier:sessionManager.serviceProviderIdentifier];
                                               if (completion) completion(credential.accessToken, nil);
                                           } failure:^(NSError *error) {
                                               if (completion) completion(nil, error);
                                           }];
}

@end

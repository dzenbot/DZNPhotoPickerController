// GROAuth2SessionManager.m
//
// Copyright (c) 2013 Gabriel Rinaldi (http://gabrielrinaldi.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFHTTPRequestOperation.h"
#import "GROAuth2SessionManager.h"

NSString * const kGROAuthCodeGrantType = @"authorization_code";
NSString * const kGROAuthClientCredentialsGrantType = @"client_credentials";
NSString * const kGROAuthPasswordCredentialsGrantType = @"password";
NSString * const kGROAuthRefreshGrantType = @"refresh_token";
NSString * const kGROAuthErrorFailingOperationKey = @"GROAuthErrorFailingOperation";

#pragma mark GROAuth2SessionManager (Private)

@interface GROAuth2SessionManager ()

@property (readwrite, nonatomic) NSString *serviceProviderIdentifier;
@property (readwrite, nonatomic) NSString *clientID;
@property (readwrite, nonatomic) NSString *secret;
@property (readwrite, nonatomic) NSURL *oAuthURL;

@end

#pragma mark - GROAuth2SessionManager

@implementation GROAuth2SessionManager

#pragma mark - Initializers

+ (instancetype)managerWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret {
    return [self managerWithBaseURL:url oAuthURL:nil clientID:clientID secret:secret];
}

+ (instancetype)managerWithBaseURL:(NSURL *)url oAuthURL:(NSURL *)oAuthURL clientID:(NSString *)clientID secret:(NSString *)secret {
    return [[self alloc] initWithBaseURL:url oAuthURL:oAuthURL clientID:clientID secret:secret];
}

- (id)initWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret {
    return [self initWithBaseURL:url oAuthURL:nil clientID:clientID secret:secret];
}

- (id)initWithBaseURL:(NSURL *)url oAuthURL:(NSURL *)oAuthURL clientID:(NSString *)clientID secret:(NSString *)secret {
    NSParameterAssert(clientID);

    self = [super initWithBaseURL:url];
    if (self) {
        [self setServiceProviderIdentifier:[[self baseURL] host]];
        [self setClientID:clientID];
        [self setSecret:secret];
        [self setOAuthURL:oAuthURL];
    }

    return self;
}

#pragma mark - Authorization headers

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    // Use the "Bearer" type as an arbitrary default
    [self setAuthorizationHeaderWithToken:token ofType:@"Bearer"];
}

- (void)setAuthorizationHeaderWithCredential:(AFOAuthCredential *)credential {
    [self setAuthorizationHeaderWithToken:[credential accessToken] ofType:[credential tokenType]];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token ofType:(NSString *)type {
    // See http://tools.ietf.org/html/rfc6749#section-7.1
    if ([[type lowercaseString] isEqualToString:@"bearer"]) {
        [[self requestSerializer] setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    }
}

#pragma mark - Authentication

- (void)authenticateUsingOAuthWithPath:(NSString *)path username:(NSString *)username password:(NSString *)password scope:(NSString *)scope success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:kGROAuthPasswordCredentialsGrantType forKey:@"grant_type"];
    [mutableParameters setValue:username forKey:@"username"];
    [mutableParameters setValue:password forKey:@"password"];
    [mutableParameters setValue:scope forKey:@"scope"];

    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];

    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path scope:(NSString *)scope success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:kGROAuthClientCredentialsGrantType forKey:@"grant_type"];
    [mutableParameters setValue:scope forKey:@"scope"];

    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];

    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path refreshToken:(NSString *)refreshToken success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:kGROAuthRefreshGrantType forKey:@"grant_type"];
    [mutableParameters setValue:refreshToken forKey:@"refresh_token"];

    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];

    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path code:(NSString *)code redirectURI:(NSString *)redirectURI success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:kGROAuthCodeGrantType forKey:@"grant_type"];
    [mutableParameters setValue:code forKey:@"code"];
    [mutableParameters setValue:redirectURI forKey:@"redirect_uri"];

    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];

    [self authenticateUsingOAuthWithPath:path parameters:parameters success:success failure:failure];
}

- (void)authenticateUsingOAuthWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mutableParameters setObject:[self clientID] forKey:@"client_id"];
    [mutableParameters setValue:[self secret] forKey:@"client_secret"];

    parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];

    NSString *urlString;
    if ([self oAuthURL]) {
        urlString = [[NSURL URLWithString:path relativeToURL:[self oAuthURL]] absoluteString];
    } else {
        urlString = [[NSURL URLWithString:path relativeToURL:[self baseURL]] absoluteString];
    }

    NSError *error;
    NSMutableURLRequest *mutableRequest = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:&error];
    if (error) {
        failure(error);

        return;
    }

    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:mutableRequest];
    [requestOperation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject valueForKey:@"error"]) {
            if (failure) {
                // TODO: Resolve the `error` field into a proper NSError object
                // http://tools.ietf.org/html/rfc6749#section-5.2
                failure(nil);
            }

            return;
        }

        NSString *refreshToken = [responseObject valueForKey:@"refresh_token"];
        if (refreshToken == nil || [refreshToken isEqual:[NSNull null]]) {
            refreshToken = [parameters valueForKey:@"refresh_token"];
        }

        AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[responseObject valueForKey:@"access_token"] tokenType:[responseObject valueForKey:@"token_type"]];

        NSDate *expireDate = [NSDate distantFuture];
        id expiresIn = [responseObject valueForKey:@"expires_in"];
        if (expiresIn != nil && ![expiresIn isEqual:[NSNull null]]) {
            expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
        }

        [credential setRefreshToken:refreshToken expiration:expireDate];

        [self setAuthorizationHeaderWithCredential:credential];

        if (success) {
            success(credential);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            if(error) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
                userInfo[kGROAuthErrorFailingOperationKey] = operation;
                error = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            }
            failure(error);
        }
    }];

    [requestOperation start];
}

@end

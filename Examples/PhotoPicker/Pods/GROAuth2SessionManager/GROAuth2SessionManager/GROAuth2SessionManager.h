// GROAuth2SessionManager.h
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#import "AFHTTPSessionManager.h"
#else
#import "AFHTTPRequestOperationManager.h"
#endif
#import "AFOAuthCredential.h"

#ifndef _SECURITY_SECITEM_H_
#warning Security framework not found in project, or not included in precompiled header. Keychain persistence functionality will not be available.
#endif

/**
 `GROAuth2SessionManager` encapsulates common patterns to authenticate against a resource server conforming to the behavior outlined in the OAuth 2.0 specification.

 @see RFC 6749 The OAuth 2.0 Authorization Framework: http://tools.ietf.org/html/rfc6749
 */
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
@interface GROAuth2SessionManager : AFHTTPSessionManager
#else
@interface GROAuth2SessionManager : AFHTTPRequestOperationManager
#endif

///------------------------------------------
/// @name Accessing OAuth 2 Client Properties
///------------------------------------------

/**
 The service provider identifier used to store and retrieve OAuth credentials by `AFOAuthCredential`. Equivalent to the hostname of the client `baseURL`.
 */
@property (readonly, nonatomic) NSString *serviceProviderIdentifier;

/**
 The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 */
@property (readonly, nonatomic) NSString *clientID;

/**
 The OAuth URL if different than the base URL.
 */
@property (readonly, nonatomic) NSURL *oAuthURL;

///------------------------------------------------
/// @name Creating and Initializing OAuth 2 Clients
///------------------------------------------------

/**
 Creates and initializes an `GROAuth2SessionManager` object with the specified base URL, client identifier, and secret.

 @param url The base URL for the HTTP client. This argument must not be `nil`.
 @param clientID The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 @param secret The client secret.

 @return The newly-initialized OAuth 2 manager
 */
+ (instancetype)managerWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret;

/**
 Creates and initializes an `GROAuth2SessionManager` object with the specified base URL, client identifier, and secret.

 @param url The base URL for the HTTP client. This argument must not be `nil`.
 @param oAuthURL The OAuth URL for the HTTP client if different than the base URL.
 @param clientID The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 @param secret The client secret.

 @return The newly-initialized OAuth 2 manager
 */
+ (instancetype)managerWithBaseURL:(NSURL *)url oAuthURL:(NSURL *)oAuthURL clientID:(NSString *)clientID secret:(NSString *)secret;

/**
 Initializes an `GROAuth2SessionManager` object with the specified base URL, client identifier, and secret.

 @param url The base URL for the HTTP client. This argument must not be `nil`.
 @param clientID The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 @param secret The client secret.

 @return The newly-initialized OAuth 2 manager
 */
- (id)initWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret;

/**
 Initializes an `GROAuth2SessionManager` object with the specified base URL, client identifier, and secret.

 @param url The base URL for the HTTP client. This argument must not be `nil`.
 @param oAuthURL The OAuth URL for the HTTP client if different than the base URL.
 @param clientID The client identifier issued by the authorization server, uniquely representing the registration information provided by the client.
 @param secret The client secret.

 @return The newly-initialized OAuth 2 manager
 */
- (id)initWithBaseURL:(NSURL *)url oAuthURL:(NSURL *)oAuthURL clientID:(NSString *)clientID secret:(NSString *)secret;

/**
 Sets the "Authorization" HTTP header set in request objects made by the HTTP client to a basic authentication value with Base64-encoded username and password. This overwrites any existing value for this header.

 @param credential The OAuth credential
 */
- (void)setAuthorizationHeaderWithCredential:(AFOAuthCredential *)credential;

///---------------------
/// @name Authenticating
///---------------------

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server using a specified username and password, with a designated scope.

 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param username The username used for authentication
 @param password The password used for authentication
 @param scope The authorization scope
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path username:(NSString *)username password:(NSString *)password scope:(NSString *)scope success:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server with a designated scope.

 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param scope The authorization scope
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path scope:(NSString *)scope success:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server using the specified refresh token.

 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param refreshToken The OAuth refresh token
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path refreshToken:(NSString *)refreshToken success:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server with an authorization code, redirecting to a specified URI upon successful authentication.

 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param code The authorization code
 @param redirectURI The URI to redirect to after successful authentication
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path code:(NSString *)code redirectURI:(NSString *)redirectURI success:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure;

/**
 Creates and enqueues an `AFHTTPRequestOperation` to authenticate against the server with the specified parameters.

 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the OAuth credential returned by the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the error returned from the server.
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFOAuthCredential *credential))success failure:(void (^)(NSError *error))failure;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Error Information Keys

  The following key is given in the `userInfo` dictionary of the NSError object passeed to the `failure` block object executed when a request operation finished unsuccessfully.


 `kGROAuth2ErrorFailingOperationKey`: The failing AFHTTPRequestOperation object.
 */
extern NSString * const kGROAuthErrorFailingOperationKey;

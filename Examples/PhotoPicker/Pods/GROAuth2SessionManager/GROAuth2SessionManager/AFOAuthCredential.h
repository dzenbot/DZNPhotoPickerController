// AFOAuthCredential.h
//
// Copyright (c) 2013 AFNetworking (http://afnetworking.com)
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

/**
 `AFOAuthCredential` models the credentials returned from an OAuth server, storing the token type, access & refresh tokens, and whether the token is expired.

 OAuth credentials can be stored in the user's keychain, and retrieved on subsequent launches.
 */
@interface AFOAuthCredential : NSObject <NSCoding>

///--------------------------------------
/// @name Accessing Credential Properties
///--------------------------------------

/**
 The OAuth access token.
 */
@property (readonly, nonatomic) NSString *accessToken;

/**
 The OAuth token type (e.g. "bearer").
 */
@property (readonly, nonatomic) NSString *tokenType;

/**
 The OAuth refresh token.
 */
@property (readonly, nonatomic) NSString *refreshToken;

/**
 Whether the OAuth credentials are expired.
 */
@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;

///--------------------------------------------
/// @name Creating and Initializing Credentials
///--------------------------------------------

/**
 Create an OAuth credential from a token string, with a specified type.

 @param token The OAuth token string.
 @param type The OAuth token type.
 */
+ (instancetype)credentialWithOAuthToken:(NSString *)token
                               tokenType:(NSString *)type;

/**
 Initialize an OAuth credential from a token string, with a specified type.

 @param token The OAuth token string.
 @param type The OAuth token type.
 */
- (id)initWithOAuthToken:(NSString *)token
               tokenType:(NSString *)type;

///----------------------------
/// @name Setting Refresh Token
///----------------------------

/**
 Set the credential refresh token, with a specified expiration.

 @param refreshToken The OAuth refresh token.
 @param expiration The expiration of the access token. This must not be `nil`.
 */
- (void)setRefreshToken:(NSString *)refreshToken
             expiration:(NSDate *)expiration;

///-----------------------------------------
/// @name Storing and Retrieving Credentials
///-----------------------------------------

#ifdef _SECURITY_SECITEM_H_
/**
 Stores the specified OAuth credential for a given web service identifier in the Keychain with the default Keychain Accessibilty of kSecAttrAccessibleWhenUnlocked and without iCloud support.

 @param credential The OAuth credential to be stored.
 @param identifier The service identifier associated with the specified credential.

 @return Whether or not the credential was stored in the keychain.
 */
+ (BOOL)storeCredential:(AFOAuthCredential *)credential
         withIdentifier:(NSString *)identifier;

/**
 Stores the specified OAuth credential for a given web service identifier in the Keychain with the default Keychain Accessibilty of kSecAttrAccessibleWhenUnlocked.

 @param credential The OAuth credential to be stored.
 @param identifier The service identifier associated with the specified credential.
 @param shouldUseICloud Wheter ir should try to use iCloud.

 @return Whether or not the credential was stored in the keychain.
 */
+ (BOOL)storeCredential:(AFOAuthCredential *)credential
         withIdentifier:(NSString *)identifier useICloud:(BOOL)shouldUseICloud;

/**
 Stores the specified OAuth credential for a given web service identifier in the Keychain.

 @param credential The OAuth credential to be stored.
 @param identifier The service identifier associated with the specified credential.
 @param securityAccessibility The Keychain security accessibility to store the credential with.
 @param shouldUseICloud Wheter ir should try to use iCloud.

 @return Whether or not the credential was stored in the keychain.
 */
+ (BOOL)storeCredential:(AFOAuthCredential *)credential
         withIdentifier:(NSString *)identifier withAccessibility:(id)securityAccessibility useICloud:(BOOL)shouldUseICloud;

/**
 Retrieves the OAuth credential stored with the specified service identifier from the Keychain.

 @param identifier The service identifier associated with the specified credential.

 @return The retrieved OAuth credential.
 */
+ (AFOAuthCredential *)retrieveCredentialWithIdentifier:(NSString *)identifier;

/**
 Retrieves the OAuth credential stored with the specified service identifier from the Keychain.

 @param identifier The service identifier associated with the specified credential.
 @param shouldUseICloud Wheter ir should try to use iCloud.

 @return The retrieved OAuth credential.
 */
+ (AFOAuthCredential *)retrieveCredentialWithIdentifier:(NSString *)identifier useICloud:(BOOL)shouldUseICloud;

/**
 Deletes the OAuth credential stored with the specified service identifier from the Keychain.

 @param identifier The service identifier associated with the specified credential.

 @return Whether or not the credential was deleted from the keychain.
 */
+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier;

/**
 Deletes the OAuth credential stored with the specified service identifier from the Keychain.

 @param identifier The service identifier associated with the specified credential.
 @param shouldUseICloud Wheter ir should try to use iCloud.

 @return Whether or not the credential was deleted from the keychain.
 */
+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier useICloud:(BOOL)shouldUseICloud;
#endif

@end

///----------------
/// @name Constants
///----------------

/**
 ## OAuth Grant Types

 OAuth 2.0 provides several grant types, covering several different use cases. The following grant type string constants are provided:

 `kAFOAuthCodeGrantType`: "authorization_code"
 `kAFOAuthClientCredentialsGrantType`: "client_credentials"
 `kAFOAuthPasswordCredentialsGrantType`: "password"
 `kAFOAuthRefreshGrantType`: "refresh_token"
 */
extern NSString * const kAFOAuthCodeGrantType;
extern NSString * const kAFOAuthClientCredentialsGrantType;
extern NSString * const kAFOAuthPasswordCredentialsGrantType;
extern NSString * const kAFOAuthRefreshGrantType;

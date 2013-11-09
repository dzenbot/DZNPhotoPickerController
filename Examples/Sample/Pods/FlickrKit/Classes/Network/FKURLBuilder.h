//
//  FKURLBuilder.h
//  FlickrKit
//
//  Created by David Casserly on 28/05/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

typedef enum {
	FKHttpMethodGET = 0,
	FKHttpMethodPOST
} FKHttpMethod;

@interface FKURLBuilder : NSObject

#pragma mark - URL Encryption

- (NSURL *) oauthURLFromBaseURL:(NSURL *)inURL method:(FKHttpMethod)method params:(NSDictionary *)params;

#pragma mark - Create query string from args and sign it

- (NSString *) signedQueryStringFromParameters:(NSDictionary *)params;

#pragma mark - Args as array

- (NSDictionary *) signedArgsFromParameters:(NSDictionary *)params method:(FKHttpMethod)method url:(NSURL *)url;

@end

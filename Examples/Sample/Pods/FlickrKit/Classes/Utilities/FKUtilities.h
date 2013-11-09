//
//  FKUtilitis.h
//  FlickrKit
//
//  Created by David Casserly on 29/05/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import <Foundation/Foundation.h>

#pragma mark - MD5

NSString *FKMD5FromString(NSString *string);

#pragma mark - URL Escaped Strings

NSString *FKEscapedURLString(NSString *string);
NSString *FKEscapedURLStringPlus(NSString *string);

#pragma mark - Unique ID

NSString *FKGenerateUUID(void);

#pragma mark - Query Strings

NSDictionary *FKQueryParamDictionaryFromQueryString(NSString *queryString);

NSDictionary *FKQueryParamDictionaryFromURL(NSURL *url);

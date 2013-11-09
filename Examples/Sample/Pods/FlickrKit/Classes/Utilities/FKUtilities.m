//
//  FKUtilitis.m
//  FlickrKit
//
//  Created by David Casserly on 29/05/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKUtilities.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#pragma mark - MD5

NSString *FKMD5FromString(NSString *string) {
	const char *cStr = [string UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

#pragma mark - URL Escaped Strings

NSString *FKEscapedURLString(NSString *string) {
	return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

NSString *FKEscapedURLStringPlus(NSString *string) {
	CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"`~!@#$^&*()=+[]\\{}|;':\",/<>?", kCFStringEncodingUTF8);
	return (__bridge_transfer NSString *)escaped;
}

#pragma mark - Unique ID

NSString *FKGenerateUUID(void) {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
	return (__bridge_transfer NSString *)uuidStr;
}

#pragma mark - OAuthExtraction

NSDictionary *FKQueryParamDictionaryFromQueryString(NSString *queryString) {
	if (queryString.length < 1) {
		return nil;
	}
	
	NSArray *vars = [queryString componentsSeparatedByString:@"&"];
	NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
	for (NSString *var in vars) {
		NSArray *kv = [var componentsSeparatedByString:@"="];
		if ([kv count] != 2) {
            continue;
        }
		keyValues[kv[0]] = kv[1];
	}
	
	return [keyValues copy];
}

NSDictionary *FKQueryParamDictionaryFromURL(NSURL *url) {
	NSString *urlString = url.query;
	NSDictionary *params = FKQueryParamDictionaryFromQueryString(urlString);
	return params;
}

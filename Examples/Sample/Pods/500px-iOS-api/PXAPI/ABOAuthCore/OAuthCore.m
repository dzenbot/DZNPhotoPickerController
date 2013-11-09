//
//  OAuthCore.m
//
//  Created by Loren Brichter on 6/9/10.
//  Copyright 2010 Loren Brichter. All rights reserved.
//

#import "OAuthCore.h"
#import "OAuth+Additions.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>

static NSInteger SortParameter(NSString *key1, NSString *key2, NSDictionary *context) {
    NSComparisonResult r = [key1 compare:key2];
    if(r == NSOrderedSame) { // compare by value in this case
        NSString *value1 = [context objectForKey:key1];
        NSString *value2 = [context objectForKey:key2];
        return [value1 compare:value2];
    }
    return r;
}

static NSData *HMAC_SHA1(NSString *data, NSString *key) {
    unsigned char buf[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
    return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}

NSString *OAuthorizationHeader(NSURL *url, NSString *method, NSData *body, NSString *_oAuthConsumerKey, NSString *_oAuthConsumerSecret, NSString *_oAuthToken, NSString *_oAuthTokenSecret)
{
    NSString *_oAuthNonce = [NSString ab_GUID];
    NSString *_oAuthTimestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *_oAuthSignatureMethod = @"HMAC-SHA1";
    NSString *_oAuthVersion = @"1.0";

    NSMutableDictionary *oAuthAuthorizationParameters = [NSMutableDictionary dictionary];
    [oAuthAuthorizationParameters setObject:_oAuthNonce forKey:@"oauth_nonce"];
    [oAuthAuthorizationParameters setObject:_oAuthTimestamp forKey:@"oauth_timestamp"];
    [oAuthAuthorizationParameters setObject:_oAuthSignatureMethod forKey:@"oauth_signature_method"];
    [oAuthAuthorizationParameters setObject:_oAuthVersion forKey:@"oauth_version"];
    [oAuthAuthorizationParameters setObject:_oAuthConsumerKey forKey:@"oauth_consumer_key"];
    
    if(_oAuthToken)
        [oAuthAuthorizationParameters setObject:_oAuthToken forKey:@"oauth_token"];

    // get query and body parameters
    NSDictionary *additionalQueryParameters = [[url query] ab_parseURLQueryString];
    NSDictionary *additionalBodyParameters = nil;
    if(body) {
        NSString *string = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        if(string) {
            additionalBodyParameters = [string ab_parseURLQueryString];
        }
    }

    // combine all parameters
    NSMutableDictionary *parameters = [oAuthAuthorizationParameters mutableCopy];
    if(additionalQueryParameters) [parameters addEntriesFromDictionary:additionalQueryParameters];
    if(additionalBodyParameters) [parameters addEntriesFromDictionary:additionalBodyParameters];

    // -> UTF-8 -> RFC3986
    NSMutableArray *encodedParameterStringArray = [NSMutableArray array];
    for(NSString *key in parameters) {
        NSString *value = [parameters objectForKey:key];
        if ([value isKindOfClass:[NSString class]])
        {
            [encodedParameterStringArray addObject:[NSString stringWithFormat:@"%@=%@", [key ab_RFC3986EncodedString], [value ab_RFC3986EncodedString]]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            for (id item in (NSArray *)value)
            {
                [encodedParameterStringArray addObject:[NSString stringWithFormat:@"%@%%5B%%5D=%@", [key ab_RFC3986EncodedString], [item ab_RFC3986EncodedString]]];
            }
        }
    }

    NSArray *sortedParameterArray = [encodedParameterStringArray sortedArrayUsingSelector:@selector(compare:)];

    NSString *normalizedParameterString = [sortedParameterArray componentsJoinedByString:@"&"];

    NSString *normalizedURLString = [NSString stringWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]];

    NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@",
                                     [method ab_RFC3986EncodedString],
                                     [normalizedURLString ab_RFC3986EncodedString],
                                     [normalizedParameterString ab_RFC3986EncodedString]];

    // Updated this from original to allow us to pass in nil to method
    NSString *key = [NSString stringWithFormat:@"%@&%@",
                     [_oAuthConsumerSecret ab_RFC3986EncodedString],
                     (_oAuthTokenSecret) ? [_oAuthTokenSecret ab_RFC3986EncodedString] : @""];

    NSData *signature = HMAC_SHA1(signatureBaseString, key);
    NSString *base64Signature = [signature base64EncodedString];

    NSMutableDictionary *authorizationHeaderDictionary = [oAuthAuthorizationParameters mutableCopy];
    [authorizationHeaderDictionary setObject:base64Signature forKey:@"oauth_signature"];

    NSMutableArray *authorizationHeaderItems = [NSMutableArray array];
    for(NSString *key in authorizationHeaderDictionary) {
        NSString *value = [authorizationHeaderDictionary objectForKey:key];
        [authorizationHeaderItems addObject:[NSString stringWithFormat:@"%@=\"%@\"",
                                             [key ab_RFC3986EncodedString],
                                             [value ab_RFC3986EncodedString]]];
    }

    NSString *authorizationHeaderString = [authorizationHeaderItems componentsJoinedByString:@", "];

    authorizationHeaderString = [NSString stringWithFormat:@"OAuth %@", authorizationHeaderString];

    return authorizationHeaderString;
}

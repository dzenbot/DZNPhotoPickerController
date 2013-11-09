//
//  PXAuthHelper.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXAPIHelper+Auth.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"

@implementation PXAPIHelper (Auth)

-(NSDictionary *)requestTokenAndSecret
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/request_token", self.host]];
    NSMutableURLRequest *requestTokenURLRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [requestTokenURLRequest setHTTPMethod:@"POST"];
    
    NSString *requestTokenAuthorizationHeader = OAuthorizationHeader(requestURL, @"POST", nil, self.consumerKey, self.consumerSecret, nil, nil);
    
    [requestTokenURLRequest setHTTPMethod:@"POST"];
    [requestTokenURLRequest setValue:requestTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:requestTokenURLRequest returningResponse:&response error:&error];
    
    NSString *returnedRequestTokenString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *returnedRequestTokenDictionary = [returnedRequestTokenString ab_parseURLQueryString];
    return returnedRequestTokenDictionary;
}

-(NSDictionary *)authenticate500pxUserName:(NSString *)username password:(NSString *)password
{
    NSDictionary *returnedRequestTokenDictionary = [self requestTokenAndSecret];
    
    NSString *requestOauthToken = [returnedRequestTokenDictionary valueForKey:@"oauth_token"];
    NSString *requestOauthSecret = [returnedRequestTokenDictionary valueForKey:@"oauth_token_secret"];
    
    NSMutableURLRequest *accessTokenURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/access_token", self.host]]];
    [accessTokenURLRequest setHTTPMethod:@"POST"];
    
    NSDictionary *accessTokenOptions = @{ @"x_auth_mode": @"client_auth", @"x_auth_password": password, @"x_auth_username" : username };
    
    NSMutableString *accessTokenParamsAsString = [[NSMutableString alloc] init];
    [accessTokenOptions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [accessTokenParamsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    NSData *bodyData = [accessTokenParamsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(accessTokenURLRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, requestOauthToken, requestOauthSecret);
    
    
    [accessTokenURLRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [accessTokenURLRequest setHTTPBody:bodyData];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *returnedAccessTokenData = [NSURLConnection sendSynchronousRequest:accessTokenURLRequest returningResponse:&response error:&error];
    
    NSString *returnedAccessTokenString = [[NSString alloc] initWithData:returnedAccessTokenData encoding:NSUTF8StringEncoding];
    
    return [returnedAccessTokenString ab_parseURLQueryString];
}

@end

//
//  PXRequest.m
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXRequest.h"
#import "PXAPIHelper+Auth.h"

#import "PXAPI.h"

NSString *const PXRequestErrorConnectionDomain = @"connection error";
NSString *const PXRequestErrorRequestDomain = @"request cancelled";
NSString *const PXRequestAPIDomain = @"api error";

NSString *const PXRequestPhotosCompleted = @"photos returned";
NSString *const PXRequestPhotosFailed = @"photos failed";

NSString *const PXRequestLoggedInUserCompleted = @"logged in user request completed";
NSString *const PXRequestLoggedInUserFailed = @"logged in user request failed";

NSString *const PXRequestUserDetailsCompleted = @"logged in user request completed";
NSString *const PXRequestUserDetailsFailed = @"logged in user request failed";

NSString *const PXRequestPhotoDetailsCompleted = @"photo details completed";
NSString *const PXRequestPhotoDetailsFailed = @"photo details request failed";

NSString *const PXRequestReportPhotoCompleted = @"reporting of photo completed";
NSString *const PXRequestReportPhotoFailed = @"reporting of photo request failed";

NSString *const PXRequestToFavouritePhotoCompleted = @"request to favourite photo completed";
NSString *const PXRequestToFavouritePhotoFailed = @"request to favourite photo failed";

NSString *const PXRequestToVoteForPhotoCompleted = @"request to vote for photo completed";
NSString *const PXRequestToVoteForPhotoFailed = @"request to vote for photo failed";

NSString *const PXRequestToCommentOnPhotoCompleted = @"request to comment on photo completed";
NSString *const PXRequestToCommentOnPhotoFailed = @"request to comment on photo failed";

NSString *const PXRequestSearchCompleted = @"search completed";
NSString *const PXRequestSearchFailed = @"search failed";

NSString *const PXRequestToFollowUserCompleted = @"request to follow user completed";
NSString *const PXRequestToFollowUserFailed = @"request to follow user failed";

NSString *const PXRequestForUserFollowingListCompleted = @"request to list user following completed";
NSString *const PXRequestForUserFollowingListFailed = @"request to list user following failed";

NSString *const PXRequestForUserFollowersListCompleted = @"request to list user followers completed";
NSString *const PXRequestForUserFollowersListFailed = @"request to list user followers failed";

NSString *const PXAuthenticationChangedNotification = @"500px authentication changed";
NSString *const PXAuthenticationFailedNotification = @"500px authentication failed";

NSString *const PXRequestToUploadPhotoCompleted = @"request to upload photo completed";
NSString *const PXRequestToUploadPhotoFailed = @"request to upload photo failed";

@interface PXRequest () <NSURLConnectionDataDelegate>
@end

@implementation PXRequest
{
    NSURLConnection *urlConnection;
    NSMutableData *connectionMutableData;
    
    PXRequestCompletionBlock requestCompletionBlock;
}

static NSMutableSet *inProgressRequestsMutableSet;
static dispatch_queue_t inProgressRequestsMutableSetAccessQueue;
static PXAPIHelper *_apiHelper;

@synthesize urlRequest = _urlRequest;
@synthesize requestStatus = _requestStatus;

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inProgressRequestsMutableSet = [NSMutableSet set];
        inProgressRequestsMutableSetAccessQueue = dispatch_queue_create("com.inProgressRequestsMutableSetSetAccessQueue", DISPATCH_QUEUE_SERIAL);
    });
}

#pragma mark - Private Instance Methods

-(id)initWithURLRequest:(NSURLRequest *)urlRequest completion:(PXRequestCompletionBlock)completion
{
    if (!(self = [super init])) return nil;
    
    _urlRequest = urlRequest;
    requestCompletionBlock = [completion copy];
    _requestStatus = PXRequestStatusNotStarted;
    
    return self;
}

-(NSURLConnection *)urlConnectionForURLRequest:(NSURLRequest *)request
{
    return [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - Public Instance Methods

-(void)start
{
    if (self.requestStatus != PXRequestStatusNotStarted)
    {
        NSLog(@"Attempt to start existing request. Ignoring.");
    }
    
    _requestStatus = PXRequestStatusStarted;
    
    connectionMutableData = [NSMutableData data];
    
    urlConnection = [self urlConnectionForURLRequest:self.urlRequest];
    [urlConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [urlConnection start];
    
    [PXRequest addRequestToInProgressMutableSet:self];
}

-(void)cancel
{
    [urlConnection cancel];
    _requestStatus = PXRequestStatusCancelled;
    
    if (requestCompletionBlock)
    {
        NSError *error = [NSError errorWithDomain:PXRequestErrorRequestDomain
                                             code:PXRequestStatusCancelled
                                         userInfo:nil];
        requestCompletionBlock(nil, error);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}

+(PXAPIHelper *)apiHelper
{
    return _apiHelper;
}

#pragma mark - Private class methods

+(void)generateNotLoggedInError:(PXRequestCompletionBlock)completionBlock
{
    NSLog(@"Error: consumer key and secret not specified.");
    
    if (completionBlock)
    {
        completionBlock(nil, [NSError errorWithDomain:PXRequestErrorRequestDomain code:PXRequestErrorCodeUserNotLoggedIn userInfo:@{ NSLocalizedDescriptionKey : @"User must be authenticated to use this request." }]);
    }
}

+(void)generateNoConsumerKeyError:(PXRequestCompletionBlock)completionBlock
{
    NSLog(@"Error: User must be authenticated in for this request.");
    
    if (completionBlock)
    {
        completionBlock(nil, [NSError errorWithDomain:PXRequestErrorRequestDomain code:PXRequestErrorCodeNoConsumerKeyAndSecret userInfo:@{ NSLocalizedDescriptionKey : @"No Consumer Key and Consumer Secret were specified before using PXRequest." }]);
    }
}

+(void)addRequestToInProgressMutableSet:(PXRequest *)request
{
    dispatch_sync(inProgressRequestsMutableSetAccessQueue, ^{
        [inProgressRequestsMutableSet addObject:request];
    });
}

+(void)removeRequestFromInProgressMutableSet:(PXRequest *)request
{
    dispatch_sync(inProgressRequestsMutableSetAccessQueue, ^{
        if ([inProgressRequestsMutableSet containsObject:request])
        {
            [inProgressRequestsMutableSet removeObject:request];
        }
    });
}

#pragma mark - Public Class Methods
+(void)authenticateWithUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(BOOL stop))completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:nil];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *accessTokenDictionary = [self.apiHelper authenticate500pxUserName:userName password:password];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (accessTokenDictionary.allKeys.count > 0)
            {
                [PXRequest setAuthToken:[accessTokenDictionary valueForKey:@"oauth_token"] authSecret:[accessTokenDictionary valueForKey:@"oauth_token_secret"]];
                
                if (completionBlock)
                {
                    completionBlock(YES);
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationFailedNotification object:nil];
                
                if (completionBlock)
                {
                    completionBlock(NO);
                }
            }
        });
    });
}

+(void)removeUserAuthentication
{
    [PXRequest setAuthToken:nil authSecret:nil];
}

+(void)setConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    _apiHelper = [[PXAPIHelper alloc] initWithHost:nil consumerKey:consumerKey consumerSecret:consumerSecret];
}

+(void)setAuthToken:(NSString *)authToken authSecret:(NSString *)authSecret
{
    if (authToken && authSecret)
    {
        [self.apiHelper setAuthModeToOAuthWithAuthToken:authToken authSecret:authSecret];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationChangedNotification object:@(YES)];
    }
    else
    {
        [self.apiHelper setAuthModeToNoAuth];
        [[NSNotificationCenter defaultCenter] postNotificationName:PXAuthenticationChangedNotification object:@(NO)];
    }
}

#pragma mark - NSURLConnectionDelegate Methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"PXRequest to %@ failed with error: %@", self.urlRequest.URL, error);
    _requestStatus = PXRequestStatusFailed;
    
    if (requestCompletionBlock)
    {
        requestCompletionBlock(nil, error);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSUInteger statusCode = httpResponse.statusCode;
    if (statusCode != 200)
    {
        [connection cancel];
        _requestStatus = PXRequestStatusFailed;
        
        if (requestCompletionBlock)
        {
            NSError *error = [NSError errorWithDomain:PXRequestErrorConnectionDomain
                                                 code:statusCode
                                             userInfo:@{ NSURLErrorKey : self.urlRequest.URL}];
            requestCompletionBlock(nil, error);
        }
        
        [PXRequest removeRequestFromInProgressMutableSet:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [connectionMutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _requestStatus = PXRequestStatusCompleted;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:connectionMutableData options:0 error:nil];
    
    if (requestCompletionBlock)
    {
        requestCompletionBlock(responseDictionary, nil);
    }
    
    [PXRequest removeRequestFromInProgressMutableSet:self];
}


@end

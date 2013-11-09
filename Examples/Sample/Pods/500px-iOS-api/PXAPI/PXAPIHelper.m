//
//  PXAPIHelper.m
//  500px-iOS-api
//
//  Created by Ash Furrow on 12-07-27.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXAPIHelper.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"

@interface NSString (PXURLEncoding)

-(NSString *)px_urlEncode;

@end

@implementation NSString (PXURLEncoding)

-(NSString *)px_urlEncode
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

@end

@implementation PXAPIHelper
{
    PXAPIHelperMode authMode;
}

#pragma mark - Auth Mode Getters/Setters

@synthesize host=_host;
@synthesize consumerKey=_consumerKey;
@synthesize consumerSecret=_consumerSecret;

@synthesize authToken=_authToken;
@synthesize authSecret=_authSecret;

- (id)initWithHost:(NSString *)host
       consumerKey:(NSString *)consumerKey
    consumerSecret:(NSString *)consumerSecret
{
    self = [super init];
    if (self) {
        _host = host;
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if (!self.host) {
        _host = @"https://api.500px.com/v1";
        authMode = PXAPIHelperModeNoAuth;
    }
}

#pragma mark - Methods to change auth mode

-(void)setAuthModeToNoAuth
{
    authMode = PXAPIHelperModeNoAuth;
    _authToken = nil;
    _authSecret = nil;
}

-(void)setAuthModeToOAuthWithAuthToken:(NSString *)newAuthToken authSecret:(NSString *)newAuthSecret
{
    authMode = PXAPIHelperModeOAuth;
    _authToken = newAuthToken;
    _authSecret = newAuthSecret;
}

-(PXAPIHelperMode)authMode
{
    return authMode;
}

#pragma mark - Private Methods

-(NSString *)urlStringPhotoCategoryForPhotoCategory:(PXPhotoModelCategory)photoCategory
{
    NSString *urlStringPhotoCategory;
    
    switch (photoCategory) {
        case PXPhotoModelCategoryAbstract:
            urlStringPhotoCategory = @"Abstract";
            break;
        case PXPhotoModelCategoryAnimals:
            urlStringPhotoCategory = @"Animals";
            break;
        case PXPhotoModelCategoryBlackAndWhite:
            urlStringPhotoCategory = @"Black+and+White";
            break;
        case PXPhotoModelCategoryCelbrities:
            urlStringPhotoCategory = @"Celebrities";
            break;
        case PXPhotoModelCategoryCityAndArchitecture:
            urlStringPhotoCategory = @"City+and+Architecture";
            break;
        case PXPhotoModelCategoryCommercial:
            urlStringPhotoCategory = @"Commericial";
            break;
        case PXPhotoModelCategoryConcert:
            urlStringPhotoCategory = @"Concert";
            break;
        case PXPhotoModelCategoryFamily:
            urlStringPhotoCategory = @"Family";
            break;
        case PXPhotoModelCategoryFashion:
            urlStringPhotoCategory = @"Fashion";
            break;
        case PXPhotoModelCategoryFilm:
            urlStringPhotoCategory = @"Film";
            break;
        case PXPhotoModelCategoryFineArt:
            urlStringPhotoCategory = @"Fine+Art";
            break;
        case PXPhotoModelCategoryFood:
            urlStringPhotoCategory = @"Food";
            break;
        case PXPhotoModelCategoryJournalism:
            urlStringPhotoCategory = @"Journalism";
            break;
        case PXPhotoModelCategoryLandscapes:
            urlStringPhotoCategory = @"Landscapes";
            break;
        case PXPhotoModelCategoryMacro:
            urlStringPhotoCategory = @"Macro";
            break;
        case PXPhotoModelCategoryNature:
            urlStringPhotoCategory = @"Nature";
            break;
        case PXPhotoModelCategoryNude:
            urlStringPhotoCategory = @"Nude";
            break;
        case PXPhotoModelCategoryPeople:
            urlStringPhotoCategory = @"People";
            break;
        case PXPhotoModelCategoryPerformingArts:
            urlStringPhotoCategory = @"Performing+Arts";
            break;
        case PXPhotoModelCategorySport:
            urlStringPhotoCategory = @"Sport";
            break;
        case PXPhotoModelCategoryStillLife:
            urlStringPhotoCategory = @"Still+Life";
            break;
        case PXPhotoModelCategoryStreet:
            urlStringPhotoCategory = @"Street";
            break;
        case PXPhotoModelCategoryTransportation:
            urlStringPhotoCategory = @"Transportation";
            break;
        case PXPhotoModelCategoryTravel:
            urlStringPhotoCategory = @"Travel";
            break;
        case PXPhotoModelCategoryUncategorized:
            urlStringPhotoCategory = @"Uncategorized";
            break;
        case PXPhotoModelCategoryUnderwater:
            urlStringPhotoCategory = @"Underwater";
            break;
        case PXPhotoModelCategoryUrbanExploration:
            urlStringPhotoCategory = @"Urban+Exploration";
            break;
        case PXPhotoModelCategoryWedding:
            urlStringPhotoCategory = @"Wedding";
            break;
        case PXAPIHelperUnspecifiedCategory:    //this is a sentinel value used to *not* filter results.
            urlStringPhotoCategory = nil;       //should never execute this branch; only here to silence compiler warnings.
            break;
    }
    
    return urlStringPhotoCategory;
}

-(NSString *)stringForSortOrder:(PXAPIHelperSortOrder)sortOrder
{
    NSString *sortOrderString;
    
    switch (sortOrder) {
        case PXAPIHelperSortOrderCommentsCount:
            sortOrderString = @"comments_count";
            break;
        case PXAPIHelperSortOrderCreatedAt:
            sortOrderString = @"created_at";
            break;
        case PXAPIHelperSortOrderFavouritesCount:
            sortOrderString = @"favorites_count";
            break;
        case PXAPIHelperSortOrderRating:
            sortOrderString = @"rating";
            break;
        case PXAPIHelperSortOrderTakenAt:
            sortOrderString = @"taken_at";
            break;
        case PXAPIHelperSortOrderTimesViewed:
            sortOrderString = @"times_views";
            break;
        case PXAPIHelperSortOrderVotesCount:
            sortOrderString = @"votes_count";
            break;
    }
    
    return sortOrderString;
}

-(NSString *)stringForUserPhotoFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature
{
    NSString *userPhotoFeatureString;
    
    switch (userPhotoFeature)
    {
        case PXAPIHelperUserPhotoFeaturePhotos:
            userPhotoFeatureString = @"user";
            break;
        case PXAPIHelperUserPhotoFeatureFavourites:
            userPhotoFeatureString = @"user_favorites";
            break;
        case PXAPIHelperUserPhotoFeatureFriends:
            userPhotoFeatureString = @"user_friends";
            break;
    }
    
    return userPhotoFeatureString;
}

-(NSString *)stringForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature
{
    NSString *photoFeatureString;
    switch (photoFeature)
    {
        case PXAPIHelperPhotoFeaturePopular:
            photoFeatureString = @"popular";
            break;
        case PXAPIHelperPhotoFeatureEditors:
            photoFeatureString = @"editors";
            break;
        case PXAPIHelperPhotoFeatureFreshToday:
            photoFeatureString = @"fresh_today";
            break;
        case PXAPIHelperPhotoFeatureFreshWeek:
            photoFeatureString = @"fresh_week";
            break;
        case PXAPIHelperPhotoFeatureFreshYesterday:
            photoFeatureString = @"fresh_yesterday";
            break;
        case PXAPIHelperPhotoFeatureUpcoming:
            photoFeatureString = @"upcoming";
            break;
    }
    
    return photoFeatureString;
}

-(NSArray *)photoSizeArrayForSizeMask:(PXPhotoModelSize)sizeMask
{
    NSMutableArray *sizeStringArray = [NSMutableArray array];
    
    if ((sizeMask & PXPhotoModelSizeExtraSmallThumbnail) > 0)
    {
        [sizeStringArray addObject:@"1"];
    }
    if ((sizeMask & PXPhotoModelSizeSmallThumbnail) > 0)
    {
        [sizeStringArray addObject:@"2"];
    }
    if ((sizeMask & PXPhotoModelSizeThumbnail) > 0)
    {
        [sizeStringArray addObject:@"3"];
    }
    if ((sizeMask & PXPhotoModelSizeLarge) > 0)
    {
        [sizeStringArray addObject:@"4"];
    }
    if ((sizeMask & PXPhotoModelSizeExtraLarge) > 0)
    {
        [sizeStringArray addObject:@"5"];
    }
    
    return sizeStringArray;
}

#pragma mark - Photos

-(NSURLRequest *)urlRequestForPhotos
{
    return [self urlRequestForPhotoFeature:kPXAPIHelperDefaultFeature];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:1];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder
{
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder except:(PXPhotoModelCategory)PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory
{
    
    return [self urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory
{
    if (resultsPerPage > kPXAPIHelperMaximumResultsPerPage)
        resultsPerPage = kPXAPIHelperMaximumResultsPerPage;
    
    NSMutableDictionary *options = [@{@"feature" : [self stringForPhotoFeature:photoFeature],
    @"rpp" : @(resultsPerPage),
    @"sort" : [self stringForSortOrder:sortOrder],
    @"page" : @(page)} mutableCopy];
    
    if (excludedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:excludedCategory] forKey:@"exclude"];
    }
    
    if (includedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:includedCategory] forKey:@"only"];
    }
    
    NSArray *imageSizeArray = [self photoSizeArrayForSizeMask:photoSizesMask];    
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/photos?consumer_key=%@",
                                      self.host,
                                      self.consumerKey];
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        for (NSString *imageSizeString in imageSizeArray)
        {
            [urlString appendFormat:@"&image_size[]=%@", imageSizeString];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/photos",self.host];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        if (imageSizeArray.count == 1)
        {
            [paramsAsString appendFormat:@"image_size=%@&", [imageSizeArray lastObject]];
        }
        else
        {
            for (NSString *imageSizeString in imageSizeArray)
            {
                [paramsAsString appendFormat:@"image_size[]=%@&", imageSizeString];
            }
        }
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

//Private
-(NSURLRequest *)urlRequestToChangePhotoFavouriteStatus:(NSInteger)photoID method:(NSString *)method
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil; //Requires authentication
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    if ([method isEqualToString:@"DELETE"])
    {
        //500px API does not support HTTP DELETE calls, so we use this workaround
        [options setValue:@"delete" forKey:@"_method"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/photos/%d/favorite", self.host, photoID];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [mutableRequest setHTTPBody:bodyData];
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestToFavouritePhoto:(NSInteger)photoID
{
    return [self urlRequestToChangePhotoFavouriteStatus:photoID method:@"POST"];
}

-(NSURLRequest *)urlRequestToUnFavouritePhoto:(NSInteger)photoID
{
    return [self urlRequestToChangePhotoFavouriteStatus:photoID method:@"DELETE"];
}

-(NSURLRequest *)urlRequestToVoteForPhoto:(NSInteger)photoID
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil; //Requires authentication
    
    NSDictionary *options = @{ @"vote" : @(1) };
    
    NSString *urlString = [NSString stringWithFormat:@"%@/photos/%d/vote", self.host, photoID];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [mutableRequest setHTTPBody:bodyData];
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestToComment:(NSString *)comment onPhoto:(NSInteger)photoID
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil; //Requires authentication
    
    if (comment == nil) return nil; //Required parameter
    
    if ([[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) return nil; //Required to be non-empty
    
    //Need to URL-encode first so the servers don't reject it
    NSDictionary *options = @{ @"body" : [comment ab_RFC3986EncodedString] };
    
    NSString *urlString = [NSString stringWithFormat:@"%@/photos/%d/comments", self.host, photoID];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [mutableRequest setHTTPBody:bodyData];
    
    return mutableRequest;
}

#pragma mark - Photos for Specified User

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:kPXAPIHelperDefaultUserPhotoFeature];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:1];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory
{
    return [self urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory
{
    if (resultsPerPage > kPXAPIHelperMaximumResultsPerPage)
        resultsPerPage = kPXAPIHelperMaximumResultsPerPage;
    
    NSMutableDictionary *options = [@{@"feature" : [self stringForUserPhotoFeature:userPhotoFeature],
                                    @"rpp" : @(resultsPerPage),
                                    @"sort" : [self stringForSortOrder:sortOrder],
                                    @"page" : @(page),
                                    @"user_id" : @(userID)} mutableCopy];
    
    if (excludedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:excludedCategory] forKey:@"exclude"];
    }
    
    if (includedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:includedCategory] forKey:@"only"];
    }
    
    NSArray *imageSizeArray = [self photoSizeArrayForSizeMask:photoSizesMask];
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/photos?consumer_key=%@",
                                      self.host,
                                      self.consumerKey];
        
        for (id key in options.allKeys) {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
                
        for (NSString *imageSizeString in imageSizeArray)
        {
            [urlString appendFormat:@"&image_size[]=%@", imageSizeString];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/photos",self.host];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        if (imageSizeArray.count == 1)
        {
            [paramsAsString appendFormat:@"image_size=%@&", [imageSizeArray lastObject]];
        }
        else
        {
            for (NSString *imageSizeString in imageSizeArray)
            {
                [paramsAsString appendFormat:@"image_size[]=%@&", imageSizeString];
            }
        }
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}


-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:kPXAPIHelperDefaultUserPhotoFeature];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:1];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory
{
    return [self urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory
{
    if (resultsPerPage > kPXAPIHelperMaximumResultsPerPage)
        resultsPerPage = kPXAPIHelperMaximumResultsPerPage;
    
    NSMutableDictionary *options = [@{@"feature" : [self stringForUserPhotoFeature:userPhotoFeature],
                                    @"rpp" : @(resultsPerPage),
                                    @"sort" : [self stringForSortOrder:sortOrder],
                                    @"page" : @(page),
                                    @"username" : userName} mutableCopy];
    
    if (excludedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:excludedCategory] forKey:@"exclude"];
    }
    
    if (includedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:includedCategory] forKey:@"only"];
    }
    
    NSMutableURLRequest *mutableRequest;
    
    NSArray *imageSizeArray = [self photoSizeArrayForSizeMask:photoSizesMask];
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/photos?consumer_key=%@",
                                      self.host,
                                      self.consumerKey];
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        for (NSString *imageSizeString in imageSizeArray)
        {
            [urlString appendFormat:@"&image_size[]=%@", imageSizeString];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/photos",self.host];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        if (imageSizeArray.count == 1)
        {
            [paramsAsString appendFormat:@"image_size=%@&", [imageSizeArray lastObject]];
        }
        else
        {
            for (NSString *imageSizeString in imageSizeArray)
            {
                [paramsAsString appendFormat:@"image_size[]=%@&", imageSizeString];
            }
        }
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

#pragma mark - Photo Details

-(NSURLRequest *)urlRequestForPhotoID:(NSInteger)photoID
{
    return [self urlRequestForPhotoID:photoID commentsPage:-1];
}

-(NSURLRequest *)urlRequestForPhotoID:(NSInteger)photoID commentsPage:(NSInteger)commentsPage
{
    return [self urlRequestForPhotoID:photoID photoSizes:kPXAPIHelperDefaultPhotoSize commentsPage:commentsPage];
}

-(NSURLRequest *)urlRequestForPhotoID:(NSInteger)photoID photoSizes:(PXPhotoModelSize)photoSizesMask commentsPage:(NSInteger)commentPage
{
    NSMutableURLRequest *mutableRequest;
    
    NSArray *imageSizeArray = [self photoSizeArrayForSizeMask:photoSizesMask];
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/photos/%d?consumer_key=%@",
                                      self.host,
                                      photoID,
                                      self.consumerKey];
        
        if (commentPage > 0)
        {
            [urlString appendFormat:@"&comments=1&comments_page=%d", commentPage];
        }
        
        for (NSString *imageSizeString in imageSizeArray)
        {
            [urlString appendFormat:@"&image_size[]=%@", imageSizeString];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/photos/%d",self.host, photoID];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        
        if (commentPage > 0)
        {
            [paramsAsString appendFormat:@"comments=1&comments_page=%d&", commentPage];
        }
        
        if (imageSizeArray.count == 1)
        {
            [paramsAsString appendFormat:@"image_size=%@&", [imageSizeArray lastObject]];
        }
        else
        {
            for (NSString *imageSizeString in imageSizeArray)
            {
                [paramsAsString appendFormat:@"image_size[]=%@&", imageSizeString];
            }
        }
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestToReportPhotoID:(NSInteger)photoID forReason:(NSInteger)reason
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil; //Requires authentication
    
    NSString *urlString = [NSString stringWithFormat:@"%@/photos/%d/report", self.host, photoID];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [paramsAsString appendFormat:@"reason=%d", reason];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [mutableRequest setHTTPBody:bodyData];
    
    return mutableRequest;
}

#pragma mark - Photo Searching

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm
{
    return [self urlRequestForSearchTerm:searchTerm page:1];
}

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page
{
    return [self urlRequestForSearchTerm:searchTerm page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage
{
    if (!searchTerm) return nil;
    
    return [self urlRequestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory
{
    if (!searchTerm) return nil;
    
    return [self urlRequestForSearchTerm:searchTerm searchTag:nil searchGeo:nil page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
}

-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag
{
    return [self urlRequestForSearchTag:searchTag page:1];
}

-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page
{
    return [self urlRequestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage
{
    return [self urlRequestForSearchTag:searchTag page:page resultsPerPage:resultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForSearchTag:searchTag page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory
{
    if (!searchTag) return nil;
    
    return [self urlRequestForSearchTerm:nil searchTag:searchTag searchGeo:nil page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
}

-(NSURLRequest *)urlRequestForSearchGeo:(NSString *)searchGeo
{
    return [self urlRequestForSearchGeo:searchGeo page:1];
}

-(NSURLRequest *)urlRequestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page
{
    return [self urlRequestForSearchGeo:searchGeo page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage];
}

-(NSURLRequest *)urlRequestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage
{
    return [self urlRequestForSearchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize];
}

-(NSURLRequest *)urlRequestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask
{
    return [self urlRequestForSearchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory
{
    if (!searchGeo) return nil;
    
    NSLog(@"searchGeo : %@",searchGeo);
    
    return [self urlRequestForSearchTerm:nil searchTag:nil searchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
}

-(NSURLRequest *)urlRequestForSearchTerm:(NSString *)searchTerm searchTag:(NSString *)searchTag searchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory
{
    if (resultsPerPage > kPXAPIHelperMaximumResultsPerPage)
        resultsPerPage = kPXAPIHelperMaximumResultsPerPage;
    
    NSMutableDictionary *options = [@{@"rpp" : @(resultsPerPage),
                                    @"page" : @(page)} mutableCopy];
    if (searchTerm)
    {
        [options setValue:searchTerm forKey:@"term"];
    }
    if (searchTag)
    {
        [options setValue:searchTag forKey:@"tag"];
    }
    if (searchGeo)
    {
        [options setValue:searchGeo forKey:@"geo"];
    }
    
    if (excludedCategory != PXAPIHelperUnspecifiedCategory)
    {
        [options setObject:[self urlStringPhotoCategoryForPhotoCategory:excludedCategory] forKey:@"exclude"];
    }
    
    NSArray *imageSizeArray = [self photoSizeArrayForSizeMask:photoSizesMask];
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/photos/search?consumer_key=%@",
                                      self.host,
                                      self.consumerKey];
        
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        for (NSString *imageSizeString in imageSizeArray)
        {
            [urlString appendFormat:@"&image_size[]=%@", imageSizeString];
        }
        
        NSLog(@"urlString : %@",urlString);
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/photos/search", self.host];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        if (imageSizeArray.count == 1)
        {
            [paramsAsString appendFormat:@"image_size=%@&", [imageSizeArray lastObject]];
        }
        else
        {
            for (NSString *imageSizeString in imageSizeArray)
            {
                [paramsAsString appendFormat:@"image_size[]=%@&", imageSizeString];
            }
        }
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

#pragma mark - GET Users

-(NSURLRequest *)urlRequestForCurrentlyLoggedInUser
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil; //Requires authentication
    
    NSString *urlString = [NSString stringWithFormat:@"%@/users", self.host];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"GET"];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", nil, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    
    return mutableRequest;
}

//Private methods
-(NSURLRequest *)urlRequestForUserWithID:(NSInteger)userID userName:(NSString *)userName emailAddress:(NSString *)userEmailAddress
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:1];
    if (userID > 0)
    {
        [options setValue:@(userID) forKey:@"id"];
    }
    else if (userName)
    {
        [options setValue:userName forKey:@"username"];
    }
    else if (userEmailAddress)
    {
        [options setValue:userEmailAddress forKey:@"email"];
    }
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/users/show?consumer_key=%@",
                                      self.host,
                                      self.consumerKey];
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/users/show", self.host];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestForUserWithID:(NSInteger)userID
{
    return [self urlRequestForUserWithID:userID userName:nil emailAddress:nil];
}

-(NSURLRequest *)urlRequestForUserWithUserName:(NSString *)userName
{
    return [self urlRequestForUserWithID:-1 userName:userName emailAddress:nil];
}

-(NSURLRequest *)urlRequestForUserWithEmailAddress:(NSString *)userEmailAddress
{
    return [self urlRequestForUserWithID:-1 userName:nil emailAddress:userEmailAddress];
}

-(NSURLRequest *)urlRequestForUserSearchWithTerm:(NSString *)searchTerm
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:1];

    [options setValue:searchTerm forKey:@"term"];
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/users/search?consumer_key=%@",
                                      self.host,
                                      self.consumerKey];
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/users/search", self.host];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestForUserFollowing:(NSInteger)userID
{
    return [self urlRequestForUserFollowing:userID page:1];
}

-(NSURLRequest *)urlRequestForUserFollowing:(NSInteger)userID page:(NSInteger)page
{
    NSDictionary *options = @{ @"page" : @(page) };
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/users/%d/friends?consumer_key=%@",
                                      self.host,
                                      userID,
                                      self.consumerKey];
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/users/%d/friends", self.host, userID];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestForUserFollowers:(NSInteger)userID
{
    return [self urlRequestForUserFollowers:userID page:1];
}

-(NSURLRequest *)urlRequestForUserFollowers:(NSInteger)userID page:(NSInteger)page
{
    NSDictionary *options = @{ @"page" : @(page) };
    
    NSMutableURLRequest *mutableRequest;
    
    if (self.authMode == PXAPIHelperModeNoAuth)
    {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/users/%d/followers?consumer_key=%@",
                                      self.host,
                                      userID,
                                      self.consumerKey];
        
        for (id key in options.allKeys)
        {
            [urlString appendFormat:@"&%@=%@", key, [options valueForKey:key]];
        }
        
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    else if (self.authMode == PXAPIHelperModeOAuth)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@/users/%d/followers", self.host, userID];
        mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSMutableString *paramsAsString = [[NSMutableString alloc] init];
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [paramsAsString appendFormat:@"%@=%@&", key, obj];
        }];
        
        NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"GET", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
        
        [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
        [mutableRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, paramsAsString]]];
    }
    
    return mutableRequest;
}

//Private method
-(NSURLRequest *)urlRequestToChangeFollowStatus:(NSInteger)userID method:(NSString *)method
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil; //Requires authentication
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    if ([method isEqualToString:@"DELETE"])
    {
        //500px API does not support HTTP DELETE calls, so we use this workaround
        [options setValue:@"delete" forKey:@"_method"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/users/%d/friends", self.host, userID];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(mutableRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [mutableRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [mutableRequest setHTTPBody:bodyData];
    
    return mutableRequest;
}

-(NSURLRequest *)urlRequestToFollowUser:(NSInteger)userToFollowID
{
    return [self urlRequestToChangeFollowStatus:userToFollowID method:@"POST"];
}

-(NSURLRequest *)urlRequestToUnFollowUser:(NSInteger)userToUnFollowID
{
    return [self urlRequestToChangeFollowStatus:userToUnFollowID method:@"DELETE"];
}

-(NSURLRequest *)urlRequestToUploadPhoto:(NSData *)imageData photoName:(NSString *)photoName description:(NSString *)photoDescription
{
    return [self urlRequestToUploadPhoto:imageData photoName:photoName description:photoDescription category:PXAPIHelperUnspecifiedCategory];
}

-(NSURLRequest *)urlRequestToUploadPhoto:(NSData *)imageData photoName:(NSString *)photoName description:(NSString *)photoDescription category:(PXPhotoModelCategory)photoCategory
{
    if (self.authMode == PXAPIHelperModeNoAuth) return nil;
    
    NSInteger category = photoCategory;
    if (photoCategory == PXAPIHelperUnspecifiedCategory)
    {
        //There is a problem with the 500px API where it will not accept a category of -1. A category of 0 is used for unspecified. 
        category = 0;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@/photos/upload?name=%@&description=%@&category=%d", self.host, [photoName px_urlEncode], [photoDescription px_urlEncode], category];

    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [mutableRequest setHTTPMethod:@"POST"];

    NSString *boundaryString = @"----------0xKhTmLb0uNdArY";
    [mutableRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryString] forHTTPHeaderField:@"Content-Type"];

    //Construct the skeleton of the multipart request body
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Transfer-Encoding: binary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-ID: <file>\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"file.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Location: file\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    //Now append the actual image data
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];

    //Finally, sign the OAuth request
    NSString *accessTokenAuthHeader = OAuthorizationHeader(mutableRequest.URL, @"POST", body, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    [mutableRequest setValue:accessTokenAuthHeader forHTTPHeaderField:@"Authorization"];
    [mutableRequest setHTTPBody:body];

    return mutableRequest;
}

@end

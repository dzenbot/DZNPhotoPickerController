//
//  PXRequest+Creation.m
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXRequest+Creation.h"

@interface PXRequest (Private)

+(void)generateNotLoggedInError:(PXRequestCompletionBlock)completionBlock;
+(void)generateNoConsumerKeyError:(PXRequestCompletionBlock)completionBlock;

-(id)initWithURLRequest:(NSURLRequest *)urlRequest completion:(PXRequestCompletionBlock)completion;

-(void)start;

@end

@implementation PXRequest (Creation)

#pragma mark - Convenience methods for access 500px API

+(PXRequest *)requestForPhotosWithCompletion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:kPXAPIHelperDefaultFeature completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForPhotoFeature:photoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:includedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosFailed object:error];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, error);
        }
    }];
    
    [request start];
    
    return request;
}

#pragma mark Specific Users

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:kPXAPIHelperDefaultUserPhotoFeature completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForPhotosOfUserID:userID userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:includedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosFailed object:error];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, error);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:kPXAPIHelperDefaultUserPhotoFeature completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:kPXAPIHelperDefaultSortOrder completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForPhotosOfUserName:userName userFeature:userPhotoFeature resultsPerPage:resultsPerPage page:page photoSizes:photoSizesMask sortOrder:sortOrder except:excludedCategory only:includedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosFailed object:error];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotosCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, error);
        }
    }];
    
    [request start];
    
    return request;
}
#pragma mark Favourite, Vote, and Comment

//Requires Authentication
+(PXRequest *)requestToFavouritePhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToFavouritePhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeFavouriteWasRejected userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToUnFavouritePhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToUnFavouritePhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeFavouriteWasRejected userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFavouritePhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToVoteForPhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToVoteForPhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeVoteWasRejected userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToVoteForPhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToVoteForPhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToComment:(NSString *)comment onPhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToComment:comment onPhoto:photoID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeCommentWasMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToCommentOnPhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToCommentOnPhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


#pragma mark Photo Details

//Comment pages are 1-indexed
//20 comments per page

+(PXRequest *)requestForPhotoID:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoID:photoID photoSizes:kPXAPIHelperDefaultPhotoSize commentsPage:1 completion:completionBlock];
}

+(PXRequest *)requestForPhotoID:(NSInteger)photoID commentsPage:(NSInteger)commentsPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForPhotoID:photoID photoSizes:kPXAPIHelperDefaultPhotoSize commentsPage:commentsPage completion:completionBlock];
}

+(PXRequest *)requestForPhotoID:(NSInteger)photoID photoSizes:(PXPhotoModelSize)photoSizesMask commentsPage:(NSInteger)commentPage completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForPhotoID:photoID photoSizes:photoSizesMask commentsPage:commentPage];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoWasDeletedOrUserWasDeactivated userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotoDetailsFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestPhotoDetailsCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToReportPhotoID:(NSInteger)photoID forReason:(NSInteger)reason completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToReportPhotoID:photoID forReason:reason];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodePhotoWasDeletedOrUserWasDeactivated userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestReportPhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestReportPhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

#pragma mark Photo Searching

//Search page results are 1-indexed

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:1 completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:page resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForSearchTerm:searchTerm page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchGeo:searchGeo page:1 completion:completionBlock];
}

+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchGeo:searchGeo page:page resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForSearchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
        
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm searchTag:(NSString *)searchTag searchGeo:(NSString *)searchGeo  page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForSearchTerm:searchTerm searchTag:searchTag searchGeo:searchGeo page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
    
    NSLog(@"urlRequest : %@", urlRequest.URL.absoluteString);
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


+(PXRequest *)requestForSearchTag:(NSString *)searchTag completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForSearchTag:searchTag page:1 resultsPerPage:kPXAPIHelperDefaultResultsPerPage photoSizes:kPXAPIHelperDefaultPhotoSize except:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForSearchTag:searchTag page:page resultsPerPage:resultsPerPage photoSizes:photoSizesMask except:excludedCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


#pragma mark Users

//Requires Authentication
+(PXRequest *)requestForCurrentlyLoggedInUserWithCompletion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (self.apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForCurrentlyLoggedInUser];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestLoggedInUserFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestLoggedInUserCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserWithID:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForUserWithID:userID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsCompleted object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsFailed object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserWithUserName:(NSString *)userName completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForUserWithUserName:userName];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserWithEmailAddress:(NSString *)userEmailAddress completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForUserWithEmailAddress:userEmailAddress];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissing userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestUserDetailsCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


+(PXRequest *)requestForUserSearchWithTerm:(NSString *)searchTerm completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForUserSearchWithTerm:searchTerm];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestSearchCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}


//pages are 1-indexed
+(PXRequest *)requestForUserFollowing:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForUserFollowing:userID page:1 completion:completionBlock];
}

+(PXRequest *)requestForUserFollowing:(NSInteger)userID page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForUserFollowing:userID page:page];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowingListFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowingListCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestForUserFollowers:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestForUserFollowers:userID page:1 completion:completionBlock];
}

+(PXRequest *)requestForUserFollowers:(NSInteger)userID page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestForUserFollowers:userID page:page];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabled userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowersListFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestForUserFollowersListCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

//Requires Authentication
+(PXRequest *)requestToFollowUser:(NSInteger)userToFollowID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (self.apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToFollowUser:userToFollowID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabledOrIsAlreadyFollowingUser userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

+(PXRequest *)requestToUnFollowUser:(NSInteger)userToUnFollowID completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (self.apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToUnFollowUser:userToUnFollowID];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 403)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserHasBeenDisabledOrIsNotFollowingUser userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeUserDoesNotExist userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToFollowUserCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

#pragma mark - Uploading

//Requires Authentication
+(PXRequest *)requestToUploadPhotoImage:(NSData *)imageData name:(NSString *)photoName description:(NSString *)photoDescription completion:(PXRequestCompletionBlock)completionBlock
{
    return [self requestToUploadPhotoImage:imageData name:photoName description:photoDescription category:PXAPIHelperUnspecifiedCategory completion:completionBlock];
}

+(PXRequest *)requestToUploadPhotoImage:(NSData *)imageData name:(NSString *)photoName description:(NSString *)photoDescription category:(NSInteger)photoCategory completion:(PXRequestCompletionBlock)completionBlock
{
    if (!self.apiHelper)
    {
        [self generateNoConsumerKeyError:completionBlock];
        return nil;
    }
    
    if (self.apiHelper.authMode == PXAPIHelperModeNoAuth)
    {
        [self generateNotLoggedInError:completionBlock];
        return nil;
    }
    
    NSURLRequest *urlRequest = [self.apiHelper urlRequestToUploadPhoto:imageData photoName:photoName description:photoDescription category:photoCategory];
    
    PXRequest *request = [[PXRequest alloc] initWithURLRequest:urlRequest completion:^(NSDictionary *results, NSError *error) {
        
        NSError *passedOnError = error;
        
        if (error)
        {
            if (error.code == 400 || error.code == 403 || error.code == 404)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeRequiredParametersWereMissingOrInvalid userInfo:@{NSUnderlyingErrorKey : error}];
            }
            else if (error.code == 422)
            {
                passedOnError = [NSError errorWithDomain:PXRequestAPIDomain code:PXRequestAPIDomainCodeInvalidData userInfo:@{NSUnderlyingErrorKey : error}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToUploadPhotoFailed object:passedOnError];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PXRequestToUploadPhotoCompleted object:results];
        }
        
        if (completionBlock)
        {
            completionBlock(results, passedOnError);
        }
    }];
    
    [request start];
    
    return request;
}

@end

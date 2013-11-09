//
//  PXRequest+Creation.h
//  PXAPI
//
//  Created by Ash Furrow on 2012-08-10.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXRequest.h"

@interface PXRequest (Creation)

#pragma mark - Convenience methods for access 500px API

#pragma mark Photo Streams

+(PXRequest *)requestForPhotosWithCompletion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoFeature:(PXAPIHelperPhotoFeature)photoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock;

#pragma mark Specific Users

+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserID:(NSInteger)userID userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotosOfUserName:(NSString *)userName userFeature:(PXAPIHelperUserPhotoFeature)userPhotoFeature resultsPerPage:(NSInteger)resultsPerPage page:(NSInteger)page photoSizes:(PXPhotoModelSize)photoSizesMask sortOrder:(PXAPIHelperSortOrder)sortOrder except:(PXPhotoModelCategory)excludedCategory only:(PXPhotoModelCategory)includedCategory completion:(PXRequestCompletionBlock)completionBlock;

#pragma mark Favourite, Vote, and Comment

//Requires Authentication
+(PXRequest *)requestToFavouritePhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestToUnFavouritePhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestToVoteForPhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestToComment:(NSString *)comment onPhoto:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock;

#pragma mark Photo Details

//Comment pages are 1-indexed
//20 comments per page

+(PXRequest *)requestForPhotoID:(NSInteger)photoID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoID:(NSInteger)photoID commentsPage:(NSInteger)commentsPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForPhotoID:(NSInteger)photoID photoSizes:(PXPhotoModelSize)photoSizesMask commentsPage:(NSInteger)commentPage completion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestToReportPhotoID:(NSInteger)photoID forReason:(NSInteger)reason completion:(PXRequestCompletionBlock)completionBlock;

#pragma mark Photo Searching

//Search page results are 1-indexed

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestForSearchTag:(NSString *)searchTag completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchTag:(NSString *)searchTag page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForSearchGeo:(NSString *)searchGeo page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestForSearchTerm:(NSString *)searchTerm searchTag:(NSString *)searchTag searchGeo:(NSString *)searchGeo  page:(NSUInteger)page resultsPerPage:(NSUInteger)resultsPerPage photoSizes:(PXPhotoModelSize)photoSizesMask except:(PXPhotoModelCategory)excludedCategory completion:(PXRequestCompletionBlock)completionBlock;


#pragma mark Users

//Requires Authentication
+(PXRequest *)requestForCurrentlyLoggedInUserWithCompletion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestForUserWithID:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForUserWithUserName:(NSString *)userName completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForUserWithEmailAddress:(NSString *)userEmailAddress completion:(PXRequestCompletionBlock)completionBlock;

+(PXRequest *)requestForUserSearchWithTerm:(NSString *)searchTerm completion:(PXRequestCompletionBlock)completionBlock;

//pages are 1-indexed
+(PXRequest *)requestForUserFollowing:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForUserFollowing:(NSInteger)userID page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForUserFollowers:(NSInteger)userID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestForUserFollowers:(NSInteger)userID page:(NSInteger)page completion:(PXRequestCompletionBlock)completionBlock;

//Requires Authentication
+(PXRequest *)requestToFollowUser:(NSInteger)userToFollowID completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestToUnFollowUser:(NSInteger)userToUnFollowID completion:(PXRequestCompletionBlock)completionBlock;

#pragma mark - Uploading

//Request Authentication
//We use NSData to keep the library agnostic of NSImage vs. UIImage.
+(PXRequest *)requestToUploadPhotoImage:(NSData *)imageData name:(NSString *)photoName description:(NSString *)photoDescription completion:(PXRequestCompletionBlock)completionBlock;
+(PXRequest *)requestToUploadPhotoImage:(NSData *)imageData name:(NSString *)photoName description:(NSString *)photoDescription category:(NSInteger)photoCategory completion:(PXRequestCompletionBlock)completionBlock;

@end

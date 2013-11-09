//
//  FKDUDefaultDiskCache.h
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com

#import "FKDUDiskCache.h"

@interface FKDUDefaultDiskCache : NSObject <FKDUDiskCache>

@property (nonatomic, assign, readonly) NSUInteger currentSizeOfCache;

+ (FKDUDefaultDiskCache *) sharedDiskCache;

#pragma mark - Clear the cache completely

- (void) emptyTheCache;

#pragma mark - Trimming the cache - do it during app going to background

- (NSString *) trimTheCache;

@end

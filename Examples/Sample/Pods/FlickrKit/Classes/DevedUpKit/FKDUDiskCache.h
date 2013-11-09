//
//  FKDUDiskCache.h
//  FlickrKit
//
//  Created by David Casserly on 28/05/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

//You can use these as convenience and readability instead of passing a number in maxAgeMinutes
typedef enum {
	FKDUMaxAgeNeverCache	= 0,
    FKDUMaxAgeOneMinute		= 1,
    FKDUMaxAgeFiveMinutes	= 5,
	FKDUMaxAgeOneHour		= 60,
    FKDUMaxAgeHalfDay		= 720,
    FKDUMaxAgeOneDay		= 1440,
    FKDUMaxAgeInfinite		= NSIntegerMax
} FKDUMaxAge;

#import <Foundation/Foundation.h>

@protocol FKDUDiskCache <NSObject>

@required

#pragma mark - Data from the cache

- (NSData *) dataForKey:(NSString *)key maxAgeMinutes:(FKDUMaxAge)maxAgeMinutes;

#pragma mark - Remove item (NSData) from cache

- (void) removeDataForKey:(NSString *)key;

#pragma mark - Store Data in the cache

- (void) storeData:(NSData *)data forKey:(NSString *)key;

@end

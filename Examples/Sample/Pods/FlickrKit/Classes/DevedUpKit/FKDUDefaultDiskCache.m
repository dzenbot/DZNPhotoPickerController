//
//  FKDUDefaultDiskCache.m
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com

#import "FKDUDefaultDiskCache.h"

@interface FKDUDefaultDiskCache ()
@property (nonatomic, assign) NSUInteger cacheSize;
@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, assign) NSInteger maxDiskCacheSize;
@end

@implementation FKDUDefaultDiskCache

+ (NSString *) cachesDirectory {
    static NSString *cachesFolder = nil;
    if (!cachesFolder) {
        cachesFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    }
	return cachesFolder;
}

+ (FKDUDefaultDiskCache *) sharedDiskCache {
    static dispatch_once_t onceToken;
    static FKDUDefaultDiskCache * __sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        __sharedManager = [[self alloc] init];
    });
    
    return __sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.maxDiskCacheSize = 100000000; //That's 100 MB
    }
    return self;
}

- (NSString *) cacheDir {
	if (self.cacheDirectory == nil) {
		NSString *cacheDir = [FKDUDefaultDiskCache cachesDirectory];
		self.cacheDirectory = [[NSString alloc] initWithString:[cacheDir stringByAppendingPathComponent:@"FlickrKitDiskCache"]];

        /* check for existence of cache directory */
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.cacheDirectory]) {

            /* create a new cache directory */
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory
                                           withIntermediateDirectories:NO
                                                            attributes:nil 
                                                                 error:nil]) {
                NSLog(@"Error creating cache directory");

                self.cacheDirectory = nil;
            }
        }
    }
	return self.cacheDirectory;
}


#pragma mark - Data from the cache

- (BOOL) isDate:(NSDate *)date moreThanMinutesAgo:(NSInteger)minutes {
    NSTimeInterval intervalFromNow = fabs([date timeIntervalSinceNow]);
    if(intervalFromNow > (minutes * 60)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSData *) dataForKey:(NSString *)key maxAgeMinutes:(FKDUMaxAge)maxAgeMinutes {
    if (0 == maxAgeMinutes) {
        return nil;
    }
    
	NSString *localPath = [[self cacheDir] stringByAppendingPathComponent:key];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
		NSError *error = nil;
		NSDictionary *properties = [[NSFileManager defaultManager]
									attributesOfItemAtPath:localPath
									error:&error];
		NSDate *modDate = properties[NSFileModificationDate];
		if (!error) {
			//Check the modified date falls within the max age
			BOOL expired = [self isDate:modDate moreThanMinutesAgo:maxAgeMinutes];
			if (expired) {
				return nil;
			} else {
				return [[NSFileManager defaultManager] contentsAtPath:localPath];
			}
        }		
	}
	return nil;
}

#pragma mark - Store Data in the cache

- (void) storeData:(NSData *)data forKey:(NSString *)key {
	if (key != nil && data != nil) {

		NSString *localPath = [[self cacheDir] stringByAppendingPathComponent:key];
		
		[[NSFileManager defaultManager] createFileAtPath:localPath 
												contents:data 
											  attributes:nil];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
			NSLog(@"ERROR: Could not create file at path: %@", localPath);
		} else {
			self.cacheSize += [data length];
		}
	}
}

#pragma mark - Remove item (NSData) from cache

- (void) removeDataForKey:(NSString *)key {
    NSString *localPath = [[self cacheDir] stringByAppendingPathComponent:key];
    [[NSFileManager defaultManager] removeItemAtPath:localPath
											   error:nil];
}

#pragma mark - Caculating the size of the cache

- (NSUInteger) currentSizeOfCache {
	NSString *cacheDir = [self cacheDir];
	if (self.cacheSize <= 0 && cacheDir != nil) {
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDir error:nil];
		NSString *file;
		NSDictionary *attrs;
		NSNumber *fileSize;
		NSUInteger totalSize = 0;
		
		for (file in dirContents) {
			NSError *error = nil;
			attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[cacheDir stringByAppendingPathComponent:file] error:&error];
			
			fileSize = attrs[NSFileSize];
			totalSize += [fileSize integerValue];
		}
		
		self.cacheSize = totalSize;
		NSLog(@"cache size is: %d", _cacheSize);
	}
	return self.cacheSize;
}

NSInteger FKDUdateModifiedSort(id file1, id file2, void *reverse);
NSInteger FKDUdateModifiedSort(id file1, id file2, void *reverse) {
	NSDictionary *attrs1 = [[NSFileManager defaultManager] attributesOfItemAtPath:file1 error:nil];
	NSDictionary *attrs2 = [[NSFileManager defaultManager] attributesOfItemAtPath:file2 error:nil];
	
	if ((NSInteger *)reverse == NO) {
		return [attrs2[NSFileModificationDate] compare:attrs1[NSFileModificationDate]];
	}
	
	return [attrs1[NSFileModificationDate] compare:attrs2[NSFileModificationDate]];
}

#pragma mark - Empty the cache

- (void) emptyTheCache {
    NSError *error = nil;
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDir] error:&error];
    for (NSString *file in dirContents) {
        NSString *path = [[self cacheDir] stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    self.cacheSize = 0;
}

#pragma mark - Trimming the cache - do it during app going to background

- (NSString *) trimTheCache {
    NSAssert(![NSThread currentThread].isMainThread, @"should be in background");
	NSUInteger targetBytes = self.maxDiskCacheSize * 0.75;
	NSLog(@"Checking disk cache size. Limit %i bytes", targetBytes);
	NSString *size = [NSString stringWithFormat:@"%i", [self currentSizeOfCache]];
	
	if ([self currentSizeOfCache] > targetBytes) {
		NSLog(@"Time to clean the cache! size is: %@, %d", [self cacheDir], [self currentSizeOfCache]);
		NSError *error = nil;
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDir] error:&error];
		if (!error) {
			NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
			for (NSString *file in dirContents) {
				[filteredArray addObject:[[self cacheDir] stringByAppendingPathComponent:file]];
			}
			
			int reverse = YES;
			NSMutableArray *sortedDirContents = [NSMutableArray arrayWithArray:[filteredArray sortedArrayUsingFunction:FKDUdateModifiedSort context:&reverse]];
			while (_cacheSize > targetBytes && [sortedDirContents count] > 0) {
				NSLog(@"removing ");
				self.cacheSize -= [[[NSFileManager defaultManager] attributesOfItemAtPath:[sortedDirContents lastObject] error:nil][NSFileSize] integerValue];
				[[NSFileManager defaultManager] removeItemAtPath:[sortedDirContents lastObject] error:nil];
				[sortedDirContents removeLastObject];
			}
			NSLog(@"Remaining cache size: %d, target size: %d", self.cacheSize, targetBytes);
		}
	}
	NSLog(@"Finished checking disk cache");    
    return size;
}

@end

//
//  FKDUReachability.h
//  FlickrKit
//
//  Created by David Casserly on 30/05/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import <Foundation/Foundation.h>

@interface FKDUReachability : NSObject

+ (BOOL) isConnected;
+ (BOOL) isOffline; // just the inverse of isConnected

+ (NSError *) buildOfflineErrorMessage;

@end

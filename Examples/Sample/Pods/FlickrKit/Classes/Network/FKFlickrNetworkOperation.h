//
//  FKNetworkOperation.h
//  FlickrKit
//
//  Created by David Casserly on 06/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDataTypes.h"
#import "FKDUConcurrentOperation.h"
#import "FKDUDiskCache.h"
#import "FKDUnetworkOperation.h"
#import "FKFlickrAPIMethod.h"

@interface FKFlickrNetworkOperation : FKDUNetworkOperation

- (id) initWithAPIMethod:(NSString *)api arguments:(NSDictionary *)args maxAgeMinutes:(FKDUMaxAge)maxAge diskCache:(id<FKDUDiskCache>)diskCache completion:(FKAPIRequestCompletion)completion;

- (id) initWithAPIMethod:(id<FKFlickrAPIMethod>)method maxAgeMinutes:(FKDUMaxAge)maxAge diskCache:(id<FKDUDiskCache>)diskCache completion:(FKAPIRequestCompletion)completion;

@end

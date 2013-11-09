//
//  DUNetworkController.h
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com

typedef enum {
	HTTPMethodGET = 0,
	HTTPMethodPOST,
	HTTPMethodPUT,
	HTTPMethodDELETE
} HTTPMethod;

@class DUNetworkRequestOperation;

@interface FKDUNetworkController : NSObject

+ (FKDUNetworkController *) sharedController;

- (void) execute:(NSOperation *)operation;

#pragma mark - Network Thread

+ (void) networkRequestThreadEntryPoint:(id)object;
+ (NSThread *) networkRequestThread;

@end

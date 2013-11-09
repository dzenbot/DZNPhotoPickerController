//
//  DUNetworkController.m
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com

#import "FKDUNetworkController.h"

@interface FKDUNetworkController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@end

@implementation FKDUNetworkController

+ (FKDUNetworkController *) sharedController {
	static dispatch_once_t onceToken;
	static FKDUNetworkController *sharedManager = nil;
	
	dispatch_once(&onceToken, ^{
		sharedManager = [[self alloc] init];
	});
	
	return sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void) execute:(NSOperation *)operation {
    [self.operationQueue addOperation:operation];
}

#pragma mark - Network Thread

+ (void) networkRequestThreadEntryPoint:(id)object {
    do {
        @autoreleasepool {
            [[NSThread currentThread] setName:@"DUNetworkThread"];
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

+ (NSThread *) networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

@end

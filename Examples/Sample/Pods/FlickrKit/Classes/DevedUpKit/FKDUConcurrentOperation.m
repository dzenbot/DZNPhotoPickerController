//
//  DUConcurrentOperation.m
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDUConcurrentOperation.h"

@interface FKDUConcurrentOperation ()
@property (nonatomic, assign) BOOL isOperationExecuting;
@property (nonatomic, assign) BOOL isOperationFinished;
@end

@implementation FKDUConcurrentOperation

- (id) init {
    self = [super init];
    if (self) {
        _isOperationExecuting = NO;
        _isOperationFinished = NO;
    }
    return self;
}

- (BOOL) isExecuting {
    return self.isOperationExecuting;
}

- (BOOL) isFinished {
    return self.isOperationFinished;
}

- (BOOL) isConcurrent {
    //This allows it to live beyond it first call so you can do asyn operation within it
    //However you have to manage its lifecycle
    return YES;
}

- (void) start {    
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self finish];
        return; 
    }
    
    //DLog(@"opeartion started");
    [self willChangeValueForKey:@"isExecuting"];
    self.isOperationExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
}

- (void) finish {
    //DLog(@"Ending operation now");    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isOperationExecuting = NO;
    self.isOperationFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

//
//  DUBlocks.m
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
// Based on http://www.mikeash.com/svn/PLBlocksPlayground/BlocksAdditions.m

#import "FKDUBlocks.h"

@implementation NSObject (BlocksAdditions)

- (void) my_callBlock {
    void (^block)(void) = (id)self;
    block();
}

- (void) my_callBlockWithObject:(id)obj {
    void (^block)(id obj) = (id)self;
    block(obj);
}

@end

void FKexecuteBlockOnThread(NSThread *thread, FKBasicBlock block) {
    [[block copy] performSelector:@selector(my_callBlock) onThread:thread withObject:nil waitUntilDone:YES];
}

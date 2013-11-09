//
//  DUBlocks.h
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com

typedef void (^FKBasicBlock)(void);
typedef void (^FKBasicBlockWithError)(NSError *error);

void FKexecuteBlockOnThread(NSThread *thread, FKBasicBlock block);
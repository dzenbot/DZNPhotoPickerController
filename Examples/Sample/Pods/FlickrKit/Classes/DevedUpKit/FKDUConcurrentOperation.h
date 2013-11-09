//
//  DUConcurrentOperation.h
//  FlickrKit
//
//  Created by David Casserly on 05/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

/**
    
    This operation object will live on after you create a asyn network connection.
    i.e. A usual operation would die if you spawn a background thread
 
 */
@interface FKDUConcurrentOperation : NSOperation

- (void) finish;

@end

/*
	Usage... overide finish and start:
 
 - (void) start {
	if ([self isCancelled]) {
		// Must move the operation to the finished state if it is canceled.
		[self finish];
		return;
	}
	[super start];

 
	//do your stuff...
 }
 
 - (void) finish {
	
	//do your stuff...
 
	[super finish];
 }
 
 */

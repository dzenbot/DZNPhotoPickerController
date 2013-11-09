//
//  FKFlickrAPIMethod.h
//  FlickrKit
//
//  Created by David Casserly on 10/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDataTypes.h"

@protocol FKFlickrAPIMethod <NSObject>

/* The name of the method used by flickr */
- (NSString *) name;

/* All the args that you have injected into the object into a dictionary */
- (NSDictionary *) args;

/* Are the args passed valid? */
- (BOOL) isValid:(NSError **)error;

/* Get a readable description for the error code passed */
- (NSString *) descriptionForError:(NSInteger)error;

/* Does this need a login? */
- (BOOL) needsLogin;

/* Do you need to sign this request */
- (BOOL) needsSigning;

/* Permissions needed for this request */
- (FKPermission) requiredPerms;

@end

//
//  PXAuthHelper.h
//  500px-iOS-api
//
//  Created by Ash Furrow on 2012-08-05.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PXAPIHelper.h"

@interface PXAPIHelper (Auth)

-(NSDictionary *)authenticate500pxUserName:(NSString *)username password:(NSString *)password;

@end

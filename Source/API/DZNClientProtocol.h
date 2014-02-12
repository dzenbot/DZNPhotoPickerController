//
//  DZNClientProtocol.h
//  Sample
//
//  Created by Ignacio on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const DZNHTTPClientConsumerKey;
UIKIT_EXTERN NSString *const DZNHTTPClientConsumerSecret;

UIKIT_EXTERN NSString *NSStringHashFromServiceType(DZNPhotoPickerControllerService type, NSString *key);

@protocol DZNClientProtocol <NSObject>

@end

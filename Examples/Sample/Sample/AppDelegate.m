//
//  AppDelegate.m
//  Sample
//
//  Created by Ignacio Romero Zurbuchen on 10/16/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "DZNPhotoMetadata.h"
#import "DZNPhotoPickerControllerConstants.h"
#import "TestUtility.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DZNPhotoPickerControllerServices service = DZNPhotoPickerControllerServiceBingImages;

    NSDictionary *JSON = [TestUtility JSONForService:service];
    DZNPhotoMetadata *metadata = [[DZNPhotoMetadata alloc] initWithObject:JSON service:service];
    
    NSLog(@"metadata : %@", metadata.description);
    
    return YES;
}

@end

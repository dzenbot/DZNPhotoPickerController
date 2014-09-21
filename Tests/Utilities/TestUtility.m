//
//  TestUtility.m
//  Sample
//
//  Created by Ignacio Romero Z. on 9/21/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "TestUtility.h"

@implementation TestUtility

+ (NSDictionary *)JSONForService:(DZNPhotoPickerControllerServices)service
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSAssert(testBundle, @"Bundle can't be nil at path: %@", testBundle);
    
    NSString *filename = [[NSStringFromService(service) lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"filename : %@", filename);
    
    NSString *path = [testBundle pathForResource:filename ofType:@"json"];
    NSAssert(path, @"File path can't be nil with path:", path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSAssert(data, @"Data path can't be nil");
    
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions|NSJSONWritingPrettyPrinted error:nil];
    NSAssert(object, @"The JSON object can't be nil : %@ (%@)", object, [NSStringFromService(service) lowercaseString]);
    
    return object;
}

@end

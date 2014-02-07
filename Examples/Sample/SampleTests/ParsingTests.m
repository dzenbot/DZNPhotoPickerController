//  ParsingTests.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 7/02/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.

#import <XCTest/XCTest.h>
#import "DZNPhotoPickerConstants.h"
#import "DZNPhotoPickerController.h"

static NSBundle *_testTargetBundle;

@interface ParsingTests : XCTestCase
@end

@implementation ParsingTests

- (void)setUp
{
    [super setUp];
    
    NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    _testTargetBundle = [NSBundle bundleWithIdentifier:bundleIdentifier];
    
}

- (void)tearDown
{
    [super tearDown];
}

- (NSDictionary *)JSONObjectForService:(DZNPhotoPickerControllerService)service
{
    XCTAssertNotNil(_testTargetBundle, @"path : %@", _testTargetBundle);

    NSString *path = [_testTargetBundle pathForResource:[NSStringFromServiceType(service) lowercaseString] ofType:@"json"];
    XCTAssertNotNil(path, @"path : %@", path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data, @"data : %@", data);
    
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions|NSJSONWritingPrettyPrinted error:nil];
    XCTAssertNotNil(data, @"object : %@", object);
    
    return object;
}

- (void)test500pxSearch
{
    NSDictionary *object = [self JSONObjectForService:DZNPhotoPickerControllerService500px];
    XCTAssertNotNil(object, @"500px object : %@", object);

    
}

- (void)testFlickrSearch
{
    NSDictionary *object = [self JSONObjectForService:DZNPhotoPickerControllerServiceFlickr];
    XCTAssertNotNil(object, @"Flickr object : %@", object);
    
    
}



@end

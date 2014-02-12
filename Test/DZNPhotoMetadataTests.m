//
//  DZNPhotoMetadataTests.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 7/02/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DZNPhotoMetadata.h"
#import "DZNPhotoPickerController.h"

static NSBundle *_testTargetBundle;

@interface DZNPhotoMetadataTests : XCTestCase

@end

@implementation DZNPhotoMetadataTests

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
    XCTAssertNotNil(_testTargetBundle, @"The target bundle cannot be nil.");
    
    NSString *path = [_testTargetBundle pathForResource:[NSStringFromServiceType(service) lowercaseString] ofType:@"json"];
    XCTAssertNotNil(path, @"The path to the file cannot be nil.");
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data, @"The NSData representation of the JSON content cannot be nil.");
    
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions|NSJSONWritingPrettyPrinted error:nil];
    XCTAssertNotNil(object, @"The JSON object must not be nil.");
    
    return object;
}

- (void)testServicesParsing
{
    [self testParsingForService:DZNPhotoPickerControllerService500px];
    [self testParsingForService:DZNPhotoPickerControllerServiceFlickr];
}

- (void)testParsingForService:(DZNPhotoPickerControllerService)service
{
    service = DZNPhotoPickerControllerService500px;
    
    NSDictionary *object = [self JSONObjectForService:service];
    
    NSArray *result = [DZNPhotoMetadata photosMetadataFromService:service withResponse:@[object]];
    XCTAssertNotNil(result, @"The parsing result cannot be nil.");
    
    DZNPhotoMetadata *metadata = [result firstObject];
    XCTAssertNotNil(metadata, @"metadata cannot be nil.");
    
    XCTAssertFalse((metadata.id && metadata.thumbURL && metadata.sourceURL && metadata.detailURL && metadata.authorName && metadata.authorUsername && metadata.authorProfileURL && metadata.serviceName), @"No attribute from a metadata object should be nil. %@", metadata.id);
}

@end

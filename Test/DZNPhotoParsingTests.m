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

static NSBundle *_testTargetBundle;

@interface DZNPhotoParsingTests : XCTestCase
@end

@implementation DZNPhotoParsingTests

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
    XCTAssertNotNil(_testTargetBundle, @"The target bundle cannot be nil");
    
    NSString *path = [_testTargetBundle pathForResource:[NSStringFromService(service) lowercaseString] ofType:@"json"];
    XCTAssertNotNil(path, @"The path to the file cannot be nil.");
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data, @"The NSData representation of the JSON content cannot be nil");
    
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions|NSJSONWritingPrettyPrinted error:nil];
    XCTAssertNotNil(object, @"The JSON object must not be nil : %@ (%@)", object, [NSStringFromService(service) lowercaseString]);
    
    return object;
}

- (void)testServicesParsing
{
    [self testParsingForService:DZNPhotoPickerControllerService500px];
    [self testParsingForService:DZNPhotoPickerControllerServiceFlickr];
    [self testParsingForService:DZNPhotoPickerControllerServiceInstagram];
    [self testParsingForService:DZNPhotoPickerControllerServiceGoogleImages];
}

- (void)testParsingForService:(DZNPhotoPickerControllerService)service
{
    NSDictionary *object = [self JSONObjectForService:service];
    
    NSArray *result = [DZNPhotoMetadata photoMetadataListFromService:service withResponse:@[object]];
    XCTAssertNotNil(result, @"The parsing result cannot be nil.");
    
    DZNPhotoMetadata *metadata = [result firstObject];
    XCTAssertNotNil(metadata, @"metadata cannot be nil. %@", metadata.description);
    
    XCTAssertTrue((metadata.thumbURL && metadata.sourceURL && metadata.detailURL && metadata.serviceName), @"Basic attributes from a photo metadata object cannnot be nil. %@", metadata.description);
}

@end

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
#import "DZNPhotoPickerControllerConstants.h"

@interface DZNPhotoParsingTests : XCTestCase
@end

@implementation DZNPhotoParsingTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSDictionary *)JSONObjectForService:(DZNPhotoPickerControllerServices)service
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    XCTAssertNotNil(testBundle, @"path : %@", testBundle);

    NSString *path = [testBundle pathForResource:[NSStringFromService(service) lowercaseString] ofType:@"json"];
    XCTAssertNotNil(path, @"The path (%@) to the file cannot be nil.", path);
    
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

- (void)testParsingForService:(DZNPhotoPickerControllerServices)service
{
    NSDictionary *object = [self JSONObjectForService:service];
    
    NSArray *result = [DZNPhotoMetadata metadataListWithResponse:@[object] service:service];
    XCTAssertNotNil(result, @"The parsing result cannot be nil.");
    
    DZNPhotoMetadata *metadata = [result firstObject];
    XCTAssertNotNil(metadata, @"metadata cannot be nil. %@", metadata.description);
    
    XCTAssertTrue((metadata.thumbURL && metadata.sourceURL && metadata.detailURL && metadata.serviceName), @"Basic attributes from a photo metadata object cannnot be nil. %@", metadata.description);
}

@end

//
//  ParsingTests.m
//  Sample
//
//  Created by Ignacio Romero Z. on 9/21/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "DZNPhotoMetadata.h"
#import "DZNPhotoPickerControllerConstants.h"

#import "TestUtility.h"

SPEC_BEGIN(UIKitTests)

describe(@"500px", ^{

    __block DZNPhotoMetadata *metadata;
    __block DZNPhotoPickerControllerServices service = DZNPhotoPickerControllerService500px;
    
    beforeAll(^{
        NSDictionary *JSON = [TestUtility JSONForService:service];
        metadata = [[DZNPhotoMetadata alloc] initWithObject:JSON service:service];
    });
    
    it(@"should crate a valid instance", ^{
        [[metadata shouldNot] beNil];
    });
    
    it(@"should parse data correctly", ^{
        [[metadata.Id should] equal:@60131700];
        [[metadata.serviceName should] equal:@"500px"];
        [[metadata.authorName should] equal:@"Tom  Baetsen"];
        [[metadata.authorUsername should] equal:@"XLiX"];
        [[metadata.authorProfileURL should] equal:[NSURL URLWithString:@"http://500px.com/XLiX"]];
        [[metadata.detailURL should] equal:[NSURL URLWithString:@"http://500px.com/photo/60131700"]];
        [[metadata.thumbURL should] equal:[NSURL URLWithString:@"http://ppcdn.500px.org/60131700/d2a9cf01be1c0d1892c48b513511b7450fbbff86/2.jpg"]];
        [[metadata.sourceURL should] equal:[NSURL URLWithString:@"http://ppcdn.500px.org/60131700/d2a9cf01be1c0d1892c48b513511b7450fbbff86/5.jpg"]];
        [[metadata.width should] equal:@4670];
        [[metadata.height should] equal:@3113];
        [[metadata.contentType should] equal:@"image/jpeg"];
    });
});

describe(@"Flickr", ^{
    
    __block DZNPhotoMetadata *metadata;
    __block DZNPhotoPickerControllerServices service = DZNPhotoPickerControllerServiceFlickr;
    
    beforeAll(^{
        NSDictionary *JSON = [TestUtility JSONForService:service];
        metadata = [[DZNPhotoMetadata alloc] initWithObject:JSON service:service];
    });
    
    it(@"should crate a valid instance", ^{
        [[metadata shouldNot] beNil];
    });
    
    it(@"should parse data correctly", ^{
        [[metadata.Id should] equal:@6457178639];
        [[metadata.serviceName should] equal:@"flickr"];
        [[metadata.authorUsername should] equal:@"26726600@N00"];
        [[metadata.authorProfileURL should] equal:[NSURL URLWithString:@"http://www.flickr.com/photos/26726600@N00"]];
        [[metadata.detailURL should] equal:[NSURL URLWithString:@"http://www.flickr.com/photos/26726600@N00/6457178639"]];
        [[metadata.thumbURL should] equal:[NSURL URLWithString:@"http://farm8.static.flickr.com/7143/6457178639_a7eae115e4_q.jpg"]];
        [[metadata.sourceURL should] equal:[NSURL URLWithString:@"http://farm8.static.flickr.com/7143/6457178639_a7eae115e4_z.jpg"]];
        [[metadata.contentType should] equal:@"image/jpeg"];
    });
});

describe(@"Instagram", ^{
    
    __block DZNPhotoMetadata *metadata;
    __block DZNPhotoPickerControllerServices service = DZNPhotoPickerControllerServiceInstagram;
    
    beforeAll(^{
        NSDictionary *JSON = [TestUtility JSONForService:service];
        metadata = [[DZNPhotoMetadata alloc] initWithObject:JSON service:service];
    });
    
    it(@"should crate a valid instance", ^{
        [[metadata shouldNot] beNil];
    });
    
    it(@"should parse data correctly", ^{
        [[metadata.Id should] equal:@"653015974623558811_634296518"];
        [[metadata.serviceName should] equal:@"instagram"];
        [[metadata.authorName should] equal:@"^VerifiedAccount^"];
        [[metadata.authorUsername should] equal:@"a1_elz"];
        [[metadata.authorProfileURL should] equal:[NSURL URLWithString:@"http://instagram.com/a1_elz"]];
        [[metadata.detailURL should] equal:[NSURL URLWithString:@"http://instagram.com/p/kP-pGwF7yb/"]];
        [[metadata.thumbURL should] equal:[NSURL URLWithString:@"http://distilleryimage8.s3.amazonaws.com/57c1918e929511e39b8f0ebc2702080c_5.jpg"]];
        [[metadata.sourceURL should] equal:[NSURL URLWithString:@"http://distilleryimage8.s3.amazonaws.com/57c1918e929511e39b8f0ebc2702080c_8.jpg"]];
        [[metadata.width should] equal:@640];
        [[metadata.height should] equal:@640];
        [[metadata.contentType should] equal:@"image/jpg"];
    });
});

describe(@"Google Images", ^{
    
    __block DZNPhotoMetadata *metadata;
    __block DZNPhotoPickerControllerServices service = DZNPhotoPickerControllerServiceGoogleImages;
    
    beforeAll(^{
        NSDictionary *JSON = [TestUtility JSONForService:service];
        metadata = [[DZNPhotoMetadata alloc] initWithObject:JSON service:service];
    });
    
    it(@"should crate a valid instance", ^{
        [[metadata shouldNot] beNil];
    });
    
    it(@"should parse data correctly", ^{
        [[metadata.Id should] equal:@([@"13950310593410234633" integerValue])];
        [[metadata.serviceName should] equal:@"google"];
        [[metadata.detailURL should] equal:[NSURL URLWithString:@"http://www.chinatraderonline.com/Toys-and-Games/Promotional-Holiday-Toys/1-12-die-cast-motocycle-182245136.htm"]];
        [[metadata.thumbURL should] equal:[NSURL URLWithString:@"https://encrypted-tbn2.gstatic.com/images?q:tbn:ANd9GcTW6A1z_EtEdxytV6ZlO6g4zJoiRqUjTsPi7Io_nrY3CglXdN2Vm0DYKuRW"]];
        [[metadata.sourceURL should] equal:[NSURL URLWithString:@"http://www.chinatraderonline.com/files3/2011-3/21/1-12-die-cast-motocycle-18220462156.jpg"]];
        [[metadata.width should] equal:@542];
        [[metadata.height should] equal:@440];
        [[metadata.contentType should] equal:@"image/jpeg"];
    });
});

describe(@"Bing Images", ^{
    
    __block DZNPhotoMetadata *metadata;
    __block DZNPhotoPickerControllerServices service = DZNPhotoPickerControllerServiceBingImages;
    
    beforeAll(^{
        NSDictionary *JSON = [TestUtility JSONForService:service];
        metadata = [[DZNPhotoMetadata alloc] initWithObject:JSON service:service];
    });
    
    it(@"should crate a valid instance", ^{
        [[metadata shouldNot] beNil];
    });
    
    it(@"should parse data correctly", ^{
        [[metadata.Id should] equal:@"ddad3ceb-137d-49a9-ae00-77deeeaf1973"];
        [[metadata.serviceName should] equal:@"bing"];
        [[metadata.detailURL should] equal:[NSURL URLWithString:@"http://www.treehugger.com/corporate-responsibility/why-does-california-burn-every-summer.html"]];
        [[metadata.thumbURL should] equal:[NSURL URLWithString:@"http://ts2.mm.bing.net/th?id=HN.608052728067851221&pid=15.1"]];
        [[metadata.sourceURL should] equal:[NSURL URLWithString:@"http://media.treehugger.com/assets/images/2011/10/southern20california20fire-jj-001.jpg"]];
        [[metadata.width should] equal:@468];
        [[metadata.height should] equal:@300];
        [[metadata.contentType should] equal:@"image/jpeg"];
    });
});

SPEC_END
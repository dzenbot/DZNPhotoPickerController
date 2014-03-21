//
//  DZNPhotoServiceConstants.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/14/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoServiceConstants.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

//#import <CommonCrypto/CommonCrypto.h>
//#import <CommonCrypto/CommonDigest.h>

NSString *const DZNPhotoServiceClientConsumerKey = @"DZNPhotoServiceClientConsumerKey";
NSString *const DZNPhotoServiceClientConsumerSecret = @"DZNPhotoServiceClientConsumerSecret";
NSString *const DZNPhotoServiceClientSubscription = @"DZNPhotoServiceClientSubscription";


NSString *NSUserDefaultsUniqueKey(NSUInteger type, NSString *key)
{
    return [NSString stringWithFormat:@"%@_%@", NSStringFromService(type), key];
}

NSURL *baseURLForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return [NSURL URLWithString:@"https://api.500px.com/v1"];
        case DZNPhotoPickerControllerServiceFlickr:             return [NSURL URLWithString:@"http://api.flickr.com/services/rest/"];
        case DZNPhotoPickerControllerServiceInstagram:          return [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        case DZNPhotoPickerControllerServiceGoogleImages:       return [NSURL URLWithString:@"https://www.googleapis.com/customsearch/v1/"];
        case DZNPhotoPickerControllerServiceYahooImages:        return [NSURL URLWithString:@"http://yboss.yahooapis.com/ysearch/"];
        default:                                                return nil;
    }
}

NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:             return @"tags.tag";
        case DZNPhotoPickerControllerServiceInstagram:          return @"data";
        default:                                                return nil;
    }
}

NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerServiceFlickr:             return @"flickr.tags.getRelated";
        case DZNPhotoPickerControllerServiceInstagram:          return @"tags/search";
        default:                                                return nil;
    }
}

NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"photos";
        case DZNPhotoPickerControllerServiceFlickr:             return @"photos.photo";
        case DZNPhotoPickerControllerServiceInstagram:          return @"data";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"items";
        default:                                                return nil;
    }
}

NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"photos/search";
        case DZNPhotoPickerControllerServiceFlickr:             return @"flickr.photos.search";
        case DZNPhotoPickerControllerServiceInstagram:          return @"tags/%@/media/recent";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"";
        case DZNPhotoPickerControllerServiceYahooImages:        return @"images";
        default:                                                return nil;
    }
}

NSString *keyForAPIConsumerKey(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"consumer_key";
        case DZNPhotoPickerControllerServiceFlickr:             return @"api_key";
        case DZNPhotoPickerControllerServiceInstagram:          return @"client_id";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"key";
        case DZNPhotoPickerControllerServiceYahooImages:        return @"oauth_consumer_key";
        default:                                                return nil;
    }
}

NSString *keyForAPIConsumerSecret(DZNPhotoPickerControllerService service)
{
    switch (service) {
            
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"cx";
        default:                                                return nil;
    }
}

NSString *keyForSearchTerm(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"term";
        case DZNPhotoPickerControllerServiceFlickr:             return @"text";
        case DZNPhotoPickerControllerServiceInstagram:          return @"q";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"q";
        case DZNPhotoPickerControllerServiceYahooImages:        return @"q";
        default:                                                return nil;
    }
}

NSString *keyForSearchTag(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:             return @"tag";
        case DZNPhotoPickerControllerServiceInstagram:          return @"q";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"q";
        default:                                                return nil;
    }
}

NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"rpp";
        case DZNPhotoPickerControllerServiceFlickr:             return @"per_page";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"num";
        case DZNPhotoPickerControllerServiceYahooImages:        return @"count";
        default:                                                return nil;
    }
}

NSString *keyForSearchTagContent(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:             return @"_content";
        case DZNPhotoPickerControllerServiceInstagram:          return @"name";
        default:                                                return nil;
    }
}

NSString *keyPathForObjectName(DZNPhotoPickerControllerService service, NSString *objectName)
{
    if ([objectName isEqualToString:[DZNPhotoTag name]]) {
        return tagsResourceKeyPathForService(service);
    }
    else if ([objectName isEqualToString:[DZNPhotoMetadata name]]) {
        return photosResourceKeyPathForService(service);
    }
    return nil;
}


NSString *HMACSHA1(NSString *text, NSString *secret)
{
//    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
//    unsigned char result[20];
//	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
//    
//    char base64Result[32];
//    size_t theResultLength = 32;
//    Base64EncodeData(result, 20, base64Result, &theResultLength);
//    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
//    
//    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
//    
    return @"";
}

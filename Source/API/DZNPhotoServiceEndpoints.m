//
//  DZNPhotoServiceEndpoints.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/14/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoServiceEndpoints.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

@implementation DZNPhotoServiceEndpoints

UIKIT_EXTERN NSURL *baseURLForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return [NSURL URLWithString:@"https://api.500px.com/v1"];
        case DZNPhotoPickerControllerServiceFlickr:     return [NSURL URLWithString:@"http://api.flickr.com/services/rest/"];
        case DZNPhotoPickerControllerServiceInstagram:  return [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"tags.tag";
        case DZNPhotoPickerControllerServiceInstagram:  return @"data";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"photos";
        case DZNPhotoPickerControllerServiceFlickr:     return @"photos.photo";
        case DZNPhotoPickerControllerServiceInstagram:  return @"data";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.tags.getRelated";
        case DZNPhotoPickerControllerServiceInstagram:  return @"tags/search";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"photos/search";
        case DZNPhotoPickerControllerServiceFlickr:     return @"flickr.photos.search";
        case DZNPhotoPickerControllerServiceInstagram:  return @"tags/%@/media/recent";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *keyForAPIConsumer(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"consumer_key";
        case DZNPhotoPickerControllerServiceFlickr:     return @"api_key";
        case DZNPhotoPickerControllerServiceInstagram:  return @"client_id";
UIKIT_EXTERN NSString *apiSecretForAPIConsumer(DZNPhotoPickerControllerService service)
{
    switch (service) {

        case DZNPhotoPickerControllerServiceGoogleImages:  return @"cx";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *keyForSearchTerm(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"term";
        case DZNPhotoPickerControllerServiceFlickr:     return @"text";
        case DZNPhotoPickerControllerServiceInstagram:  return @"q";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *keyForSearchTag(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"tag";
        case DZNPhotoPickerControllerServiceInstagram:  return @"q";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:      return @"rpp";
        case DZNPhotoPickerControllerServiceFlickr:     return @"per_page";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *keyForSearchTagContent(DZNPhotoPickerControllerService service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:     return @"_content";
        case DZNPhotoPickerControllerServiceInstagram:  return @"name";
        default:                                        return nil;
    }
}

UIKIT_EXTERN NSString *keyPathForObjectName(DZNPhotoPickerControllerService service, NSString *objectName)
{
    if ([objectName isEqualToString:[DZNPhotoTag name]]) {
        return tagsResourceKeyPathForService(service);
    }
    else if ([objectName isEqualToString:[DZNPhotoMetadata name]]) {
        return photosResourceKeyPathForService(service);
    }
    return nil;
}

@end

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

NSString *const DZNPhotoServiceClientIndentifier =      @"com.dzn.photoService.client.identifier";
NSString *const DZNPhotoServiceClientConsumerKey =      @"com.dzn.photoService.client.consumer_key";
NSString *const DZNPhotoServiceClientConsumerSecret =   @"com.dzn.photoService.client.consumer_secret";
NSString *const DZNPhotoServiceClientSubscription =     @"com.dzn.photoService.subscription";
NSString *const DZNPhotoServiceCredentialIdentifier =   @"com.dzn.photoService.credential.identifier";
NSString *const DZNPhotoServiceCredentialAccessToken =  @"com.dzn.photoService.credential.access_token";


NSString *NSUserDefaultsUniqueKey(NSUInteger type, NSString *key)
{
    return [NSString stringWithFormat:@"%@.%@_%@", DZNPhotoServiceClientIndentifier, NSStringFromService(type), key];
}

NSURL *baseURLForService(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return [NSURL URLWithString:@"https://api.500px.com/v1"];
        case DZNPhotoPickerControllerServiceFlickr:             return [NSURL URLWithString:@"https://api.flickr.com/services/rest/"];
        case DZNPhotoPickerControllerServiceInstagram:          return [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        case DZNPhotoPickerControllerServiceGoogleImages:       return [NSURL URLWithString:@"https://www.googleapis.com/customsearch/v1/"];
        case DZNPhotoPickerControllerServiceBingImages:         return [NSURL URLWithString:@"https://api.datamarket.azure.com/"];
        case DZNPhotoPickerControllerServiceGiphy:              return [NSURL URLWithString:@"https://api.giphy.com/"];
        default:                                                return nil;
    }
}

NSString *tagsResourceKeyPathForService(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:             return @"tags.tag";
        case DZNPhotoPickerControllerServiceInstagram:          return @"data";
        default:                                                return nil;
    }
}

NSString *tagSearchUrlPathForService(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerServiceFlickr:             return @"flickr.tags.getRelated";
        case DZNPhotoPickerControllerServiceInstagram:          return @"tags/search";
        default:                                                return nil;
    }
}

NSString *photosResourceKeyPathForService(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"photos";
        case DZNPhotoPickerControllerServiceFlickr:             return @"photos.photo";
        case DZNPhotoPickerControllerServiceInstagram:          return @"data";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"items";
        case DZNPhotoPickerControllerServiceBingImages:         return @"d.results";
        case DZNPhotoPickerControllerServiceGiphy:              return @"data";
        default:                                                return nil;
    }
}

NSString *photoSearchUrlPathForService(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"photos/search";
        case DZNPhotoPickerControllerServiceFlickr:             return @"flickr.photos.search";
        case DZNPhotoPickerControllerServiceInstagram:          return @"tags/%@/media/recent";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"";
        case DZNPhotoPickerControllerServiceBingImages:         return @"Bing/Search/Image?$format=json";
        case DZNPhotoPickerControllerServiceGiphy:              return @"v1/gifs/search";
        default:                                                return nil;
    }
}

NSString *keyForAPIConsumerKey(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"consumer_key";
        case DZNPhotoPickerControllerServiceFlickr:             return @"api_key";
        case DZNPhotoPickerControllerServiceInstagram:          return @"client_id";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"key";
        case DZNPhotoPickerControllerServiceGiphy:              return @"api_key";
        default:                                                return nil;
    }
}

NSString *keyForAPIConsumerSecret(DZNPhotoPickerControllerServices service)
{
    switch (service) {
            
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"cx";
        default:                                                return nil;
    }
}

NSString *keyForSearchTerm(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"term";
        case DZNPhotoPickerControllerServiceFlickr:             return @"text";
        case DZNPhotoPickerControllerServiceInstagram:          return @"q";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"q";
        case DZNPhotoPickerControllerServiceBingImages:         return @"Query";
        case DZNPhotoPickerControllerServiceGiphy:              return @"q";
        default:                                                return nil;
    }
}

NSString *keyForSearchTag(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:             return @"tag";
        case DZNPhotoPickerControllerServiceInstagram:          return @"q";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"q";
        default:                                                return nil;
    }
}

NSString *keyForSearchResultPerPage(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:              return @"rpp";
        case DZNPhotoPickerControllerServiceFlickr:             return @"per_page";
        case DZNPhotoPickerControllerServiceInstagram:          return @"count";
        case DZNPhotoPickerControllerServiceGoogleImages:       return @"num";
        case DZNPhotoPickerControllerServiceGiphy:              return @"limit";
        default:                                                return nil;
    }
}

NSString *keyForSearchPage(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        default:                                                return @"page";
    }
}

NSString *keyForSearchTagContent(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:
        case DZNPhotoPickerControllerServiceFlickr:             return @"_content";
        case DZNPhotoPickerControllerServiceInstagram:          return @"name";
        default:                                                return nil;
    }
}

NSString *keyPathForObjectName(DZNPhotoPickerControllerServices service, NSString *objectName)
{
    if ([objectName isEqualToString:[DZNPhotoTag name]]) {
        return tagsResourceKeyPathForService(service);
    }
    else if ([objectName isEqualToString:[DZNPhotoMetadata name]]) {
        return photosResourceKeyPathForService(service);
    }
    return nil;
}

BOOL isConsumerSecretRequiredForService(DZNPhotoPickerControllerServices services)
{
    if (services == DZNPhotoPickerControllerServiceBingImages || services == DZNPhotoPickerControllerServiceGiphy) return NO;
    return YES;
}

BOOL isConsumerKeyInParametersRequiredForService(DZNPhotoPickerControllerServices services)
{
    if (services == DZNPhotoPickerControllerServiceBingImages) return NO;
    return YES;
}

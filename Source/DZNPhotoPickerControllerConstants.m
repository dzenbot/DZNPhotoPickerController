//
//  DZNPhotoPickerControllerConstants.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoPickerControllerConstants.h"

NSString *const DZNPhotoPickerControllerCropMode = @"DZNPhotoPickerControllerCropMode";
NSString *const DZNPhotoPickerControllerPhotoAttributes = @"DZNPhotoPickerControllerPhotoAttributes";

NSString *const DZNPhotoPickerDidFinishPickingNotification = @"DZNPhotoPickerDidFinishPickingNotification";


@implementation DZNPhotoPickerControllerConstants
@end

NSString *NSStringFromService(DZNPhotoPickerControllerService type)
{
    switch (type) {
        case DZNPhotoPickerControllerService500px:          return @"500px";
        case DZNPhotoPickerControllerServiceFlickr:         return @"Flickr";
        case DZNPhotoPickerControllerServiceInstagram:      return @"Instagram";
        case DZNPhotoPickerControllerServiceGoogleImages:   return @"Google";
        case DZNPhotoPickerControllerServiceBingImages:     return @"Bing";
        case DZNPhotoPickerControllerServiceYahooImages:    return @"Yahoo";
        case DZNPhotoPickerControllerServicePanoramio:      return @"Panoramio";
        case DZNPhotoPickerControllerServiceDribbble:       return @"Dribbble";
        default:                                            return nil;
    }
}

DZNPhotoPickerControllerService DZNPhotoServiceFromName(NSString *name)
{
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerService500px)])         return DZNPhotoPickerControllerService500px;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceFlickr)])        return DZNPhotoPickerControllerServiceFlickr;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceInstagram)])     return DZNPhotoPickerControllerServiceInstagram;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceGoogleImages)])  return DZNPhotoPickerControllerServiceGoogleImages;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceBingImages)])    return DZNPhotoPickerControllerServiceBingImages;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceYahooImages)])   return DZNPhotoPickerControllerServiceYahooImages;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServicePanoramio)])     return DZNPhotoPickerControllerServicePanoramio;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceDribbble)])      return DZNPhotoPickerControllerServiceDribbble;
    return -1;
}

NSString *NSStringFromCropMode(DZNPhotoEditViewControllerCropMode mode)
{
    switch (mode) {
        case DZNPhotoEditViewControllerCropModeSquare:      return @"square";
        case DZNPhotoEditViewControllerCropModeCircular:    return @"circular";
        default:                                            return @"none";
    }
}

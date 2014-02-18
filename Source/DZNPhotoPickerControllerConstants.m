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
NSString *const DZNPhotoPickerControllerPhotoMetadata = @"DZNPhotoPickerControllerPhotoMetadata";

NSString *const DZNPhotoPickerDidFinishPickingNotification = @"DZNPhotoPickerDidFinishPickingNotification";


@implementation DZNPhotoPickerControllerConstants
@end

NSString *NSStringFromService(DZNPhotoPickerControllerService service)
{
    switch (service) {
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

DZNPhotoPickerControllerService DZNFirstPhotoServiceFromPhotoServices(DZNPhotoPickerControllerService services)
{
    if ((services & DZNPhotoPickerControllerService500px) > 0) {
        return DZNPhotoPickerControllerService500px;
    }
    if ((services & DZNPhotoPickerControllerServiceFlickr) > 0) {
        return DZNPhotoPickerControllerServiceFlickr;
    }
    if ((services & DZNPhotoPickerControllerServiceInstagram) > 0) {
        return DZNPhotoPickerControllerServiceInstagram;
    }
    if ((services & DZNPhotoPickerControllerServiceGoogleImages) > 0) {
        return DZNPhotoPickerControllerServiceGoogleImages;
    }
    if ((services & DZNPhotoPickerControllerServiceBingImages) > 0) {
        return DZNPhotoPickerControllerServiceBingImages;
    }
    if ((services & DZNPhotoPickerControllerServiceYahooImages) > 0) {
        return DZNPhotoPickerControllerServiceYahooImages;
    }
    if ((services & DZNPhotoPickerControllerServicePanoramio) > 0) {
        return DZNPhotoPickerControllerServicePanoramio;
    }
    if ((services & DZNPhotoPickerControllerServiceDribbble) > 0) {
        return DZNPhotoPickerControllerServiceDribbble;
    }
    return 0;
}

NSArray *NSArrayFromServices(DZNPhotoPickerControllerService services)
{
    NSMutableArray *titles = [NSMutableArray array];
    
    if ((services & DZNPhotoPickerControllerService500px) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerService500px)];
    }
    if ((services & DZNPhotoPickerControllerServiceFlickr) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceFlickr)];
    }
    if ((services & DZNPhotoPickerControllerServiceInstagram) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceInstagram)];
    }
    if ((services & DZNPhotoPickerControllerServiceGoogleImages) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceGoogleImages)];
    }
    if ((services & DZNPhotoPickerControllerServiceBingImages) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceBingImages)];
    }
    if ((services & DZNPhotoPickerControllerServiceYahooImages) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceYahooImages)];
    }
    if ((services & DZNPhotoPickerControllerServicePanoramio) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServicePanoramio)];
    }
    if ((services & DZNPhotoPickerControllerServiceDribbble) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceDribbble)];
    }
    
    return [NSArray arrayWithArray:titles];
}

NSString *NSStringFromCropMode(DZNPhotoEditViewControllerCropMode mode)
{
    switch (mode) {
        case DZNPhotoEditViewControllerCropModeSquare:      return @"square";
        case DZNPhotoEditViewControllerCropModeCircular:    return @"circular";
        default:                                            return @"none";
    }
}

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

NSString *const DZNPhotoPickerControllerCropMode =              @"com.dzn.photoPicker.cropMode";
NSString *const DZNPhotoPickerControllerCropZoomScale =         @"com.dzn.photoPicker.cropZoomScale";
NSString *const DZNPhotoPickerControllerPhotoMetadata =         @"com.dzn.photoPicker.photoMetadata";

NSString *const DZNPhotoPickerDidFinishPickingNotification =    @"com.dzn.photoPicker.didFinishPickingNotification";
NSString *const DZNPhotoPickerDidFailPickingNotification =      @"com.dzn.photoPicker.didFinishPickingWithErrorNotification";

NSString *NSStringFromService(DZNPhotoPickerControllerServices service)
{
    switch (service) {
        case DZNPhotoPickerControllerService500px:          return @"500px";
        case DZNPhotoPickerControllerServiceFlickr:         return @"Flickr";
        case DZNPhotoPickerControllerServiceInstagram:      return @"Instagram";
        case DZNPhotoPickerControllerServiceGoogleImages:   return @"Google";
        case DZNPhotoPickerControllerServiceBingImages:     return @"Bing";
        case DZNPhotoPickerControllerServiceGiphy:          return @"Giphy";
        default:                                            return nil;
    }
}

DZNPhotoPickerControllerServices DZNPhotoServiceFromName(NSString *name)
{
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerService500px)])           return DZNPhotoPickerControllerService500px;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceFlickr)])          return DZNPhotoPickerControllerServiceFlickr;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceInstagram)])       return DZNPhotoPickerControllerServiceInstagram;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceGoogleImages)])    return DZNPhotoPickerControllerServiceGoogleImages;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceBingImages)])      return DZNPhotoPickerControllerServiceBingImages;
    if ([name isEqualToString:NSStringFromService(DZNPhotoPickerControllerServiceGiphy)])           return DZNPhotoPickerControllerServiceGiphy;
    return -1;
}

DZNPhotoPickerControllerServices DZNFirstPhotoServiceFromPhotoServices(DZNPhotoPickerControllerServices services)
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
    if ((services & DZNPhotoPickerControllerServiceGiphy) > 0) {
        return DZNPhotoPickerControllerServiceGiphy;
    }
    return -1;
}

NSArray *NSArrayFromServices(DZNPhotoPickerControllerServices services)
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
    if ((services & DZNPhotoPickerControllerServiceGiphy) > 0) {
        [titles addObject:NSStringFromService(DZNPhotoPickerControllerServiceGiphy)];
    }
    return [NSArray arrayWithArray:titles];
}

//
//  DZNPhotoDescription.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoDescription.h"

#import <FlickrKit/FlickrKit.h>

@implementation DZNPhotoDescription

+ (instancetype)photoDescriptionWithTitle:(NSString *)title authorName:(NSString *)authorName thumbURL:(NSURL *)thumbURL fullURL:(NSURL *)fullURL sourceName:(NSString *)sourceName
{
    DZNPhotoDescription *photo = [DZNPhotoDescription new];
    photo.title = title;
    photo.authorName = authorName;
    photo.thumbURL = thumbURL;
    photo.fullURL = fullURL;
    photo.sourceName = sourceName;
    return photo;
}

+ (NSArray *)photoDescriptionsFromService:(DZNPhotoPickerControllerService)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    if ((service & DZNPhotoPickerControllerService500px) > 0) {
        for (NSDictionary *object in reponse) {
            
            DZNPhotoDescription *description = [DZNPhotoDescription photoDescriptionWithTitle:[object valueForKey:@"username"]
                                                                                   authorName:[NSString stringWithFormat:@"%@ %@",[object valueForKeyPath:@"user.firstname"],[object valueForKeyPath:@"user.lastname"]]
                                                                                     thumbURL:[NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:0] valueForKey:@"url"]]
                                                                                      fullURL:[NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:1] valueForKey:@"url"]]
                                                                                   sourceName:[NSStringFromServiceType(service) lowercaseString]];
            
            [result addObject:description];
        }
    }
    else if ((service & DZNPhotoPickerControllerServiceFlickr) > 0) {
        for (NSDictionary *object in reponse) {
            
            DZNPhotoDescription *description = [DZNPhotoDescription photoDescriptionWithTitle:[object valueForKey:@"title"]
                                                                                   authorName:[object valueForKey:@"owner"]
                                                                                     thumbURL:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLargeSquare150 fromPhotoDictionary:object]
                                                                                      fullURL:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:object]
                                                                                   sourceName:[NSStringFromServiceType(service) lowercaseString]];
            
            [result addObject:description];
        }
    }
    
    return result;
}

@end

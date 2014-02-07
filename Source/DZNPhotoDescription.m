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
#import "DZNPhotoPickerController.h"

#import <FlickrKit/FlickrKit.h>

@implementation DZNPhotoDescription

/*
 Allocates a new instance of DZNPhotoDescription, initialized with a valid service name.
 */
+ (instancetype)photoDescriptionFromService:(DZNPhotoPickerControllerService)service
{
    if (service != 0) {
        DZNPhotoDescription *description = [DZNPhotoDescription new];
        description.serviceName = [NSStringFromServiceType(service) lowercaseString];
        return description;
    }
    return nil;
}

+ (NSArray *)photoDescriptionsFromService:(DZNPhotoPickerControllerService)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        
        DZNPhotoDescription *description = [DZNPhotoDescription photoDescriptionFromService:service];
        
        if ((service & DZNPhotoPickerControllerService500px) > 0) {
            
            description.id = [object valueForKey:@"id"];
            description.title = [object valueForKey:@"description"];
            description.thumbURL = [NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:0] valueForKey:@"url"]];
            description.fullURL = [NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:1] valueForKey:@"url"]];
            description.fullName = [object valueForKeyPath:@"user.fullname"];
            description.userName = [object valueForKeyPath:@"user.username"];
            description.profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/%@", description.userName]];
        }
        else if ((service & DZNPhotoPickerControllerServiceFlickr) > 0) {
            
            description.id = [object valueForKey:@"id"];
            description.title = [object valueForKey:@"title"];
            description.thumbURL = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLargeSquare150 fromPhotoDictionary:object];
            description.fullURL = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:object];
            description.fullName = nil;
            description.userName = [object valueForKey:@"owner"];
            description.profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@", description.userName]];
        }
        
        [result addObject:description];
    }
    
    return result;
}

@end

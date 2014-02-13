//
//  DZNPhotoMetadata.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoMetadata.h"

#import <FlickrKit/FlickrKit.h>

@implementation DZNPhotoMetadata

+ (instancetype)photosMetadataFromService:(DZNPhotoPickerControllerService)service
{
    if (service != 0) {
        DZNPhotoMetadata *metadata = [DZNPhotoMetadata new];
        metadata.serviceName = [NSStringFromServiceType(service) lowercaseString];
        return metadata;
    }
    return nil;
}

+ (NSArray *)photosMetadataFromService:(DZNPhotoPickerControllerService)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        
        DZNPhotoMetadata *metadata = [DZNPhotoMetadata photosMetadataFromService:service];
        
        if ((service & DZNPhotoPickerControllerService500px) > 0) {
            
            metadata.id = [object valueForKey:@"id"];
            metadata.authorName = [[object valueForKeyPath:@"user.fullname"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            metadata.authorUsername = [object valueForKeyPath:@"user.username"];
            metadata.authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/%@", metadata.authorUsername]];
            metadata.detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/photo/%@", metadata.id]];
            metadata.thumbURL = [NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:0] valueForKey:@"url"]];
            metadata.sourceURL = [NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:1] valueForKey:@"url"]];
        }
        else if ((service & DZNPhotoPickerControllerServiceFlickr) > 0) {
            
            metadata.id = [object valueForKey:@"id"];
            metadata.authorName = nil;
            metadata.authorUsername = [object valueForKey:@"owner"];
            metadata.authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@", metadata.authorUsername]];
            metadata.detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@", metadata.authorUsername, metadata.id]];

            NSMutableString *url = [NSMutableString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@", [[object valueForKey:@"farm"] stringValue], [object valueForKey:@"server"], [object valueForKey:@"id"], [object valueForKey:@"secret"]];
            metadata.thumbURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_q.jpg", url]];
            metadata.sourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_b.jpg", url]];
        }
        
        [result addObject:metadata];
    }
    
    return result;
}

@end

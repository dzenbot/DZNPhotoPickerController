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

@implementation DZNPhotoMetadata

+ (NSString *)name
{
    return NSStringFromClass([DZNPhotoMetadata class]);
}

+ (instancetype)photoMetadataFromService:(DZNPhotoPickerControllerServices)service
{
    if (service != 0) {
        DZNPhotoMetadata *metadata = [DZNPhotoMetadata new];
        metadata.serviceName = [NSStringFromService(service) lowercaseString];
        return metadata;
    }
    return nil;
}

+ (NSArray *)photoMetadataListFromService:(DZNPhotoPickerControllerServices)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        
        DZNPhotoMetadata *metadata = [DZNPhotoMetadata photoMetadataFromService:service];
        
        if ((service & DZNPhotoPickerControllerService500px) > 0)
        {
            metadata.id = [object valueForKey:@"id"];
            metadata.authorName = [[object valueForKeyPath:@"user.fullname"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            metadata.authorUsername = [object valueForKeyPath:@"user.username"];
            metadata.authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/%@", metadata.authorUsername]];
            metadata.detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/photo/%@", metadata.Id]];
            
            metadata.thumbURL = [NSURL URLWithString:[[[object objectForKey:@"images"] objectAtIndex:0] objectForKey:@"url"]];
            metadata.sourceURL = [NSURL URLWithString:[[[object objectForKey:@"images"] objectAtIndex:1] objectForKey:@"url"]];
        }
        else if ((service & DZNPhotoPickerControllerServiceFlickr) > 0)
        {
            metadata.id = [object objectForKey:@"id"];
            metadata.authorName = nil;
            metadata.authorUsername = [object objectForKey:@"owner"];
            metadata.authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@", metadata.authorUsername]];
            metadata.detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@", metadata.authorUsername, metadata.Id]];

            NSMutableString *url = [NSMutableString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@", [[object objectForKey:@"farm"] stringValue], [object objectForKey:@"server"], [object objectForKey:@"id"], [object objectForKey:@"secret"]];
            metadata.thumbURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_q.jpg", url]];
            metadata.sourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_b.jpg", url]];
        }
        else if ((service & DZNPhotoPickerControllerServiceInstagram) > 0)
        {
            metadata.id = [object objectForKey:@"id"];
            metadata.authorName = [object valueForKeyPath:@"user.full_name"];
            metadata.authorUsername = [object valueForKeyPath:@"user.username"];
            metadata.authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://instagram.com/%@", metadata.authorUsername]];
            metadata.detailURL = [NSURL URLWithString:[object objectForKey:@"link"]];
            
            metadata.thumbURL = [NSURL URLWithString:[object valueForKeyPath:@"images.thumbnail.url"]];
            metadata.sourceURL = [NSURL URLWithString:[object valueForKeyPath:@"images.standard_resolution.url"]];
        }
        else if ((service & DZNPhotoPickerControllerServiceGoogleImages) > 0)
        {
            metadata.detailURL = [NSURL URLWithString:[object valueForKeyPath:@"image.contextLink"]];
            metadata.thumbURL = [NSURL URLWithString:[object valueForKeyPath:@"image.thumbnailLink"]];
            metadata.sourceURL = [NSURL URLWithString:[object valueForKeyPath:@"link"]];
        }
        
        [result addObject:metadata];
    }
    
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"serviceName = %@; id = %@; authorName = %@; authorUsername = %@; authorProfileURL = %@; detailURL = %@; thumbURL = %@; sourceURL = %@;", self.serviceName, self.Id, self.authorName, self.authorUsername, self.authorProfileURL, self.detailURL, self.thumbURL, self.sourceURL];
}


#pragma mark - View lifeterm

- (void)dealloc
{
    _Id = nil;
    _thumbURL = nil;
    _sourceURL = nil;
    _detailURL = nil;
    _authorName = nil;
    _authorUsername = nil;
    _authorProfileURL = nil;
    _serviceName = nil;
}

@end

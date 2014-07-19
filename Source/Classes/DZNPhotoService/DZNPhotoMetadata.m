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

- (instancetype)initWithObject:(NSDictionary *)object service:(DZNPhotoPickerControllerServices)service
{
    self = [super init];
    if (self && object) {
        
        _serviceName = [NSStringFromService(service) lowercaseString];
        
        if ((service & DZNPhotoPickerControllerService500px) > 0)
        {
            _Id = [object objectForKey:@"id"];
            _authorName = [[object valueForKeyPath:@"user.fullname"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            _authorUsername = [object valueForKeyPath:@"user.username"];
            _authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/%@", _authorUsername]];
            _detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://500px.com/photo/%@", _Id]];
            _thumbURL = [NSURL URLWithString:[[[object objectForKey:@"images"] objectAtIndex:0] objectForKey:@"url"]];
            _sourceURL = [NSURL URLWithString:[[[object objectForKey:@"images"] objectAtIndex:1] objectForKey:@"url"]];
            _width = [object objectForKey:@"width"];
            _height = [object objectForKey:@"height"];
            
            NSString *format = [object objectForKey:@"image_format"];
            if (format && format.length > 0) {
                _contentType = [NSString stringWithFormat:@"image/%@",format];
            }
        }
        else if ((service & DZNPhotoPickerControllerServiceFlickr) > 0)
        {
            _Id = [object objectForKey:@"id"];
            _authorName = nil;
            _authorUsername = [object objectForKey:@"owner"];
            _authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@", _authorUsername]];
            _detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@", _authorUsername, _Id]];
            
            NSMutableString *url = [NSMutableString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@", [[object objectForKey:@"farm"] stringValue], [object objectForKey:@"server"], [object objectForKey:@"id"], [object objectForKey:@"secret"]];
            _thumbURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_q.jpg", url]];
            _sourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_z.jpg", url]];
            _contentType = @"image/jpeg";
        }
        else if ((service & DZNPhotoPickerControllerServiceInstagram) > 0)
        {
            _Id = [object objectForKey:@"id"];
            _authorName = [object valueForKeyPath:@"user.full_name"];
            _authorUsername = [object valueForKeyPath:@"user.username"];
            _authorProfileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://instagram.com/%@", _authorUsername]];
            _detailURL = [NSURL URLWithString:[object objectForKey:@"link"]];
            _thumbURL = [NSURL URLWithString:[object valueForKeyPath:@"images.thumbnail.url"]];
            _sourceURL = [NSURL URLWithString:[object valueForKeyPath:@"images.standard_resolution.url"]];
            _width = [object valueForKeyPath:@"images.standard_resolution.width"];
            _height = [object valueForKeyPath:@"images.standard_resolution.height"];
            
            NSString *format = [[_sourceURL lastPathComponent] pathExtension];
            if (format && format.length > 0) {
                _contentType = [NSString stringWithFormat:@"image/%@",format];
            }
        }
        else if ((service & DZNPhotoPickerControllerServiceGoogleImages) > 0)
        {
            _Id = @([[object valueForKeyPath:@"link"] hash]);
            _detailURL = [NSURL URLWithString:[object valueForKeyPath:@"image.contextLink"]];
            _thumbURL = [NSURL URLWithString:[object valueForKeyPath:@"image.thumbnailLink"]];
            _sourceURL = [NSURL URLWithString:[object valueForKeyPath:@"link"]];
            _width = [object valueForKeyPath:@"image.width"];
            _height = [object valueForKeyPath:@"image.height"];
            _contentType = [object objectForKey:@"mime"];
        }
        else if ((service & DZNPhotoPickerControllerServiceBingImages) > 0)
        {
            _Id = [object objectForKey:@"ID"];
            _detailURL = [NSURL URLWithString:[object valueForKeyPath:@"SourceUrl"]];
            _thumbURL = [NSURL URLWithString:[object valueForKeyPath:@"Thumbnail.MediaUrl"]];
            _sourceURL = [NSURL URLWithString:[object valueForKeyPath:@"MediaUrl"]];
            _width = [object objectForKey:@"Width"];
            _height = [object objectForKey:@"Height"];
            _contentType = [object objectForKey:@"ContentType"];
        }
    }
    return self;
}

+ (NSArray *)metadataListWithResponse:(NSArray *)reponse service:(DZNPhotoPickerControllerServices)service
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        DZNPhotoMetadata *metadata = [[DZNPhotoMetadata alloc] initWithObject:object service:service];
        [result addObject:metadata];
    }
    
    return result;
}

+ (NSString *)name
{
    return NSStringFromClass([DZNPhotoMetadata class]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"serviceName = %@; id = %@; authorName = %@; authorUsername = %@; authorProfileURL = %@; detailURL = %@; thumbURL = %@; sourceURL = %@; _width : %@; height = %@; contentType = %@", _serviceName, _Id, _authorName, _authorUsername, _authorProfileURL, _detailURL, _thumbURL, _sourceURL, _width, _height, _contentType];
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

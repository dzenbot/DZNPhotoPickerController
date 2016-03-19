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

@interface DZNPhotoMetadata ()
@property (readwrite, nonatomic) id Id;
@property (readwrite, nonatomic) NSURL *thumbURL;
@property (readwrite, nonatomic) NSURL *sourceURL;
@property (readwrite, nonatomic) NSURL *detailURL;
@property (readwrite, nonatomic) NSString *authorName;
@property (readwrite, nonatomic) NSString *authorUsername;
@property (readwrite, nonatomic) NSURL *authorProfileURL;
@property (readwrite, nonatomic) NSString *serviceName;
@property (readwrite, nonatomic) NSString *contentType;
@property (readwrite, nonatomic) NSNumber *height;
@property (readwrite, nonatomic) NSNumber *width;

@end

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
            _width = @([[object objectForKey:@"Width"] integerValue]);
            _height = @([[object objectForKey:@"Height"] integerValue]);
            _contentType = [object objectForKey:@"ContentType"];
        }
        else if ((service & DZNPhotoPickerControllerServiceGiphy) > 0)
        {
            _Id = [object objectForKey:@"id"];

            NSString *sourceUrl = [object valueForKeyPath:@"images.original.url"];
            _sourceURL = [NSURL URLWithString:[sourceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            NSString *thumbUrl = [object valueForKeyPath:@"images.fixed_width_downsampled.url"];
            _thumbURL = [NSURL URLWithString:[thumbUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            _width = [object valueForKeyPath:@"images.original.width"];
            _height = [object valueForKeyPath:@"images.origninal.height"];

            if (_sourceURL) {
                _contentType = [NSString stringWithFormat:@"image/%@",[_sourceURL pathExtension]];
            }
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
    return [NSString stringWithFormat:@"{\nserviceName = %@ \nid = %@ \nauthorName = %@ \nauthorUsername = %@ \nauthorProfileURL = %@ \ndetailURL = %@ \nthumbURL = %@ \nsourceURL = %@ \nwidth : %@ \nheight = %@ \ncontentType = %@\n}", _serviceName, _Id, _authorName, _authorUsername, _authorProfileURL, _detailURL, _thumbURL, _sourceURL, _width, _height, _contentType];
}


#pragma mark - Notification

- (void)postMetadataUpdate:(NSDictionary *)userInfo
{
    NSLog(@"postMetadataUpdate : %@", userInfo);
    
    NSMutableDictionary *_userInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    
    NSDictionary *payload = [self payload];
    
    if (payload.allKeys.count > 0) {
        [_userInfo setObject:payload forKey:DZNPhotoPickerControllerPhotoMetadata];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DZNPhotoPickerDidFinishPickingNotification object:nil userInfo:_userInfo];
}

- (NSDictionary *)payload
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    if (self.serviceName) [attributes setObject:self.serviceName forKey:@"source_name"];
    if (self.Id) [attributes setObject:self.Id forKey:@"source_id"];
    if (self.detailURL) [attributes setObject:self.detailURL forKey:@"source_detail_url"];
    if (self.sourceURL) [attributes setObject:self.sourceURL forKey:@"source_url"];
    if (self.authorName) [attributes setObject:self.authorName forKey:@"author_name"];
    if (self.authorUsername) [attributes setObject:self.authorUsername forKey:@"author_username"];
    if (self.authorProfileURL) [attributes setObject:self.authorProfileURL forKey:@"author_profile_url"];
    if (self.contentType) [attributes setObject:self.contentType forKey:@"content_type"];
    
    return attributes;
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    self.Id = [decoder decodeObjectForKey:@"Id"];
    self.thumbURL = [decoder decodeObjectForKey:@"thumbURL"];
    self.sourceURL = [decoder decodeObjectForKey:@"sourceURL"];
    self.detailURL = [decoder decodeObjectForKey:@"detailURL"];
    self.authorName = [decoder decodeObjectForKey:@"authorName"];
    self.authorUsername = [decoder decodeObjectForKey:@"authorUsername"];
    self.authorProfileURL = [decoder decodeObjectForKey:@"authorProfileURL"];
    self.serviceName = [decoder decodeObjectForKey:@"serviceName"];
    self.contentType = [decoder decodeObjectForKey:@"contentType"];
    self.height = [decoder decodeObjectForKey:@"height"];
    self.width = [decoder decodeObjectForKey:@"width"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.Id forKey:@"Id"];
    [encoder encodeObject:self.thumbURL forKey:@"thumbURL"];
    [encoder encodeObject:self.sourceURL forKey:@"sourceURL"];
    [encoder encodeObject:self.detailURL forKey:@"detailURL"];
    [encoder encodeObject:self.authorName forKey:@"authorName"];
    [encoder encodeObject:self.authorUsername forKey:@"authorUsername"];
    [encoder encodeObject:self.authorProfileURL forKey:@"authorProfileURL"];
    [encoder encodeObject:self.serviceName forKey:@"serviceName"];
    [encoder encodeObject:self.contentType forKey:@"contentType"];
    [encoder encodeObject:self.height forKey:@"height"];
    [encoder encodeObject:self.width forKey:@"width"];
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

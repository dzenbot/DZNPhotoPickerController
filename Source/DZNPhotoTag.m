//
//  DZNPhotoTag.m
//  Sample
//
//  Created by Ignacio on 2/13/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNPhotoTag.h"

@implementation DZNPhotoTag

+ (NSString *)name
{
    return NSStringFromClass([DZNPhotoTag class]);
}

+ (instancetype)photoTagFromService:(DZNPhotoPickerControllerService)service
{
    if (service != 0) {
        DZNPhotoTag *tag = [DZNPhotoTag new];
        tag.serviceName = [NSStringFromServiceType(service) lowercaseString];
        return tag;
    }
    return nil;
}

+ (NSArray *)photoTagListFromService:(DZNPhotoPickerControllerService)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        
        DZNPhotoTag *tag = [DZNPhotoTag photoTagFromService:service];
        
        if ((service & DZNPhotoPickerControllerServiceFlickr) > 0) {
            tag.content = [object objectForKey:@"_content"];
        }
        else if ((service & DZNPhotoPickerControllerServiceInstagram) > 0) {
            tag.content = [object objectForKey:@"name"];
        }
        
        [result addObject:tag];
    }

    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"serviceName = %@; content = %@;", self.serviceName, self.content];
}

@end

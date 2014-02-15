//
//  DZNPhotoTag.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/13/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoTag.h"
#import "DZNPhotoServiceEndpoints.h"

@implementation DZNPhotoTag

+ (NSString *)name
{
    return NSStringFromClass([DZNPhotoTag class]);
}

+ (instancetype)photoTagFromService:(DZNPhotoPickerControllerService)service
{
    if (service != 0) {
        DZNPhotoTag *tag = [DZNPhotoTag new];
        tag.serviceName = [NSStringFromService(service) lowercaseString];
        return tag;
    }
    return nil;
}

+ (NSArray *)photoTagListFromService:(DZNPhotoPickerControllerService)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        
        DZNPhotoTag *tag = [DZNPhotoTag photoTagFromService:service];
        tag.content = [object objectForKey:keyForSearchTagContent(service)];
        
        [result addObject:tag];
    }

    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"serviceName = %@; content = %@;", self.serviceName, self.content];
}

@end

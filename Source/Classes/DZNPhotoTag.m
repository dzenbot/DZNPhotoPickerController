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
#import "DZNPhotoServiceConstants.h"

@implementation DZNPhotoTag

- (instancetype)initWithTerm:(NSString *)term service:(DZNPhotoPickerControllerServices)service
{
    self = [super init];
    if (self) {
        _term = term;
        _serviceName = [NSStringFromService(service) lowercaseString];
    }
    return self;
}

+ (instancetype)newTagWithTerm:(NSString *)term service:(DZNPhotoPickerControllerServices)service
{
    if ([term isKindOfClass:[NSString class]] && service > 0) {
        DZNPhotoTag *tag = [[DZNPhotoTag alloc] initWithTerm:term service:service];
        return tag;
    }
    return nil;
}

+ (NSArray *)photoTagListFromService:(DZNPhotoPickerControllerServices)service withResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    for (NSDictionary *object in reponse) {
        
        NSString *term = [object objectForKey:keyForSearchTagContent(service)];
        DZNPhotoTag *tag = [DZNPhotoTag newTagWithTerm:term service:service];
        
        [result addObject:tag];
    }
    
    return result;
}

+ (NSString *)name
{
    return NSStringFromClass([DZNPhotoTag class]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"service name = %@; term = %@;", self.serviceName, self.term];
}


#pragma mark - View lifeterm

- (void)dealloc
{
    _term = nil;
    _serviceName = nil;
}

@end

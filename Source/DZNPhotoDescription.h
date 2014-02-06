//
//  DZNPhotoDescription.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "DZNPhotoPickerConstants.h"

/*
 * The data model to encapsulate meta data about a photo, provided by the photo service.
 */
@interface DZNPhotoDescription : NSObject

/* The title assigned by the author. */
@property (nonatomic, copy) NSString *title;
/* The name of the author. */
@property (nonatomic, copy) NSString *authorName;
/* The url of the thumb version. */
@property (nonatomic, copy) NSURL *thumbURL;
/* The url of the full size version. */
@property (nonatomic, copy) NSURL *fullURL;
/* The name of the photo service. */
@property (nonatomic, copy) NSString *sourceName;


/*
 * Parsed and returns a list of photo descriptions from a request response.
 *
 * @param service The source service of the response.
 * @param reponse The response with already parsed JSON.
 *
 * @returns A list of new photo descriptions.
 */
+ (NSArray *)photoDescriptionsFromService:(DZNPhotoPickerControllerService)service
                             withResponse:(NSArray *)reponse;

@end

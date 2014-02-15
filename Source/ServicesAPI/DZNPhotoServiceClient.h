//
//  DZNPhotoServiceClient.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 2/12/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <AFNetworking/AFHTTPClient.h>
#import "DZNPhotoPickerControllerConstants.h"
#import "DZNPhotoServiceClientProtocol.h"

/*
 * The HTTP service client used to interact with multiple RESTful APIs for photo search services.
 */
@interface DZNPhotoServiceClient : AFHTTPClient <DZNPhotoServiceClientProtocol>

/*
 * Initializes a new HTTP service client.
 *
 * @param service The specific photo search service.
 * @param edition The photo search service edition.
 * @return A new instance of an HTTP service client.
 */
- (instancetype)initWithService:(DZNPhotoPickerControllerService)service edition:(DZNPhotoPickerControllerServiceEdition)edition;

@end

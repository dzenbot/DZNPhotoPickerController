//
//  DZPhotoDisplayController.h
//  DZPhotoPickerController
//  https://github.com/dzenbot/DZPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
//#import <SDWebImage/SDWebImageDownloader.h>
#import "SDWebImageDownloader.h"
#import <FlickrKit/FlickrKit.h>
#import <PXAPI.h>
#import "NRGramKit.h"

#define kDZPhotoPickerChooseNotification @"DZPhotoPickerChooseNotification"

static NSString *UIImagePickerControllerAuthorCredits = @"UIImagePickerControllerAuthorCredits";
static NSString *UIImagePickerControllerSourceName = @"UIImagePickerControllerSourceName";

@class DZPhotoPickerController, DZPhotoEditViewController;

/*
 * The controller in charge of searching and displaying thumb images from different image providers.
 */
@interface DZPhotoDisplayController : UICollectionViewController

/* The nearest ancestor in the view controller hierarchy that is a photo picker controller. */
@property (nonatomic, readonly) DZPhotoPickerController *navigationController;
/* The searching string. If setted before presentation, the controller will automatically start searching. */
@property (nonatomic, strong) NSString *searchTerm;
/* The count number of columns of thumbs to be displayed. */
@property (nonatomic) NSInteger columnCount;
/* The count number of rows of thumbs to be diplayed. */
@property (nonatomic) NSInteger rowCount;
/* YES if the controller started a request and loading content. */
@property (nonatomic, getter = isLoading) BOOL loading;

@end

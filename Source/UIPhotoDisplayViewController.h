//
//  UIPhotoDisplayController.h
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import <FlickrKit/FlickrKit.h>
#import <PXAPI.h>

@class UIPhotoPickerController, UIPhotoEditViewController;

/*
 * The controller in charge of searching and displaying thumb images from different image providers.
 */
@interface UIPhotoDisplayViewController : UICollectionViewController

/* The nearest ancestor in the view controller hierarchy that is a photo picker controller. */
@property (nonatomic, readonly) UIPhotoPickerController *navigationController;
/* The searching string. If setted before presentation, the controller will automatically start searching. */
@property (nonatomic, strong) NSString *searchTerm;
/* The count number of columns of thumbs to be displayed. */
@property (nonatomic) NSUInteger columnCount;
/* The count number of rows of thumbs to be diplayed. */
@property (nonatomic) NSUInteger rowCount;
/* YES if the controller started a request and loading content. */
@property (nonatomic, getter = isLoading) BOOL loading;

@end

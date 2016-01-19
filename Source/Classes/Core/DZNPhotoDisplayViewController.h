//
//  DZNPhotoDisplayController.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "DZNPhotoPickerControllerConstants.h"

@class DZNPhotoPickerController;

/** The collection view controller in charge of displaying the resulting thumb images. */
@interface DZNPhotoDisplayViewController : UICollectionViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

/** The nearest ancestor in the view controller hierarchy that is a photo picker controller. */
@property (nonatomic, readonly) DZNPhotoPickerController *navigationController;
/** The view controller's search controller. */
@property (nonatomic, readonly) UISearchController *searchController;
/** The count number of rows of thumbs to be diplayed. */
@property (nonatomic, readonly) NSUInteger rowCount;
/** YES if the controller started a request and loading content. */
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

/**
 Initializes and returns a newly created photo display controller.
 
 @param size The preferred content size, to compute the right amount of rows to be displayed.
 @return A DZNPhotoPickerController instance.
 */
- (instancetype)initWithPreferredContentSize:(CGSize)size;

/**
 Stops any loading HTTP request.
 */
- (void)stopLoadingRequest;

@end

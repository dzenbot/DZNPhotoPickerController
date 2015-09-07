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

/**
 The collection view controller in charge of displaying the resulting thumb images.
 */
@interface DZNPhotoDisplayViewController : UICollectionViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

/** The nearest ancestor in the view controller hierarchy that is a photo picker controller. */
@property (nonatomic, readonly) DZNPhotoPickerController *navigationController;

@property (nonatomic, readonly) UISearchController *searchController;

@property (nonatomic) DZNPhotoPickerControllerServices selectedService;

/** The count number of rows of thumbs to be diplayed. */
@property (nonatomic, readonly) NSUInteger rowCount;
/** YES if the controller started a request and loading content. */
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

- (instancetype)initWithPreferredContentSize:(CGSize)size NS_DESIGNATED_INITIALIZER;

/**
 Stops any loading HTTP request.
 */
- (void)stopLoadingRequest;

@end

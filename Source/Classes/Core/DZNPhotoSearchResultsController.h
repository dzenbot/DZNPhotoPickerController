//
//  DZNPhotoSearchResultsController.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

@class DZNPhotoTag;

/** A view controller used to display auto-completion results. */
@interface DZNPhotoSearchResultsController : UITableViewController

/**
 Returns a DZNPhotoTag at index path.
 
 @param indexPath The index path locating the row in the table view.
 @return A tag object.
 */
- (DZNPhotoTag *)tagAtIndexPath:(NSIndexPath *)indexPath;

/**
 Appends auto-completion tah results.
 
 @param results An array of DZNPhotoTag to be displayed in the list.
 */
- (void)setSearchResults:(NSArray *)result;

@end

//
//  RootViewController.h
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DZNPhotoPickerController.h"

@interface RootViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate,
                                                UIImagePickerControllerDelegate, DZNPhotoPickerControllerDelegate,
                                                UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *button;

- (IBAction)pressButton:(id)sender;

@end

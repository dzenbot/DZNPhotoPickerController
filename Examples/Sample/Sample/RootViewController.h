//
//  RootViewController.h
//  Sample
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DZNPhotoPickerController.h"

@interface RootViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *button;

- (IBAction)pressButton:(id)sender;

@end

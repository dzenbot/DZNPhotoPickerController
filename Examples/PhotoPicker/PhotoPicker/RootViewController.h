//
//  RootViewController.h
//  Sample
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

- (IBAction)importImage:(id)sender;
- (IBAction)editImage:(id)sender;

@end

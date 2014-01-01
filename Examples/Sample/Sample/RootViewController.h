//
//  RootViewController.h
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIPhotoPickerController.h"

@interface RootViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate,
                                                UIImagePickerControllerDelegate, UIPhotoPickerControllerDelegate,
                                                UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

- (IBAction)importImage:(id)sender;

@end

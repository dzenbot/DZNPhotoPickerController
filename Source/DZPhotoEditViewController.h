//
//  DZPhotoEditViewController.h
//  DZPhotoPickerController
//  https://github.com/dzenbot/DZPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
//#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"

#import "DZPhoto.h"

typedef NS_ENUM(NSInteger, DZPhotoEditViewControllerCropMode) {
    DZPhotoEditViewControllerCropModeSquare = 0,
    DZPhotoEditViewControllerCropModeCircular,
    DZPhotoEditViewControllerCropModeCustom
};

/*
 * The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface DZPhotoEditViewController : UIViewController


/* The photo data object. */
@property (nonatomic, weak) DZPhoto *photo;
/* The crop mode currently being used. */
@property (nonatomic, readonly) DZPhotoEditViewControllerCropMode cropMode;
/* The crop size proportions. */
@property (nonatomic) CGSize cropSize;


/*
 *
 */
- (instancetype)initWithCropMode:(DZPhotoEditViewControllerCropMode)mode;

/*
 *
 */
+ (void)didFinishPickingEditedImage:(UIImage *)editedImage
                       withCropRect:(CGRect)cropRect
                  fromOriginalImage:(UIImage *)originalImage
                       referenceURL:(NSURL *)referenceURL
                         authorName:(NSString *)authorName
                         sourceName:(NSString *)sourceName;

@end

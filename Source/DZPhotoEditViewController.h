//
//  DZPhotoEditViewController.h
//  Sample
//
//  Created by Ignacio on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"

#import "DZPhoto.h"

typedef NS_ENUM(NSInteger, DZPhotoEditViewControllerCropMode) {
    DZPhotoEditViewControllerCropModeSquare,
    DZPhotoEditViewControllerCropModeCircular,
    DZPhotoEditViewControllerCropModeCustom
};

/*
 * The controller in charge of displaying the big resolution image with the different cropping modes.
 */
@interface DZPhotoEditViewController : UIViewController <UIScrollViewDelegate>


/* The photo data object. */
@property (nonatomic, weak) DZPhoto *photo;
/* The crope mode currently being used. */
@property (nonatomic, readonly) DZPhotoEditViewControllerCropMode cropMode;
/* */
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

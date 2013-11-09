//
//  DZPhotoDisplayController.m
//  DZPhotoPickerController
//  https://github.com/dzenbot/DZPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZPhotoDisplayController.h"
#import "DZPhotoPickerController.h"
#import "DZPhotoEditViewController.h"

#import "DZPhotoCell.h"
#import "DZPhoto.h"

static NSString *kThumbCellID = @"DZPhotoCell";
static NSString *kThumbHeaderID = @"DZPhotoHeader";
static NSString *kThumbFooterID = @"DZPhotoFooter";

static NSString *_instagramMaxId = nil;
static NSString *_instagramMinId = nil;

@interface DZPhotoDisplayController () <UISearchDisplayDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, readwrite) UISearchBar *searchBar;
@property (nonatomic, readwrite) UIButton *loadButton;
@property (nonatomic, readwrite) UIView *overlayView;
@property (nonatomic, readwrite) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) DZPhotoPickerControllerServiceType selectedService;
@property (nonatomic) DZPhotoPickerControllerServiceType previousService;
@property (nonatomic) int resultPerPage;
@property (nonatomic) int currentPage;

@property (nonatomic, strong) PXRequest *PXRequest;

@end

@implementation DZPhotoDisplayController

- (id)init
{
    self = [super initWithCollectionViewLayout:[DZPhotoDisplayController flowLayout]];
    if (self) {
        
        self.title = NSLocalizedString(@"Internet Photos", nil);
        _selectedService = (1 << 0);
        _previousService = (0 << 0);
        _currentPage = 1;
    }
    return self;
}

- (CGSize)contentSize
{
    CGFloat viewHeight = self.navigationController.view.frame.size.height;
    NSLog(@"viewHeight : %f", viewHeight);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        viewHeight -= statusHeight;
        NSLog(@"statusHeight : %f",statusHeight);
    }
    
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
    viewHeight -= navigationHeight;
    NSLog(@"navigationHeight : %f",navigationHeight);
    
    CGFloat headerSize = [self headerSize].height;
    viewHeight -= headerSize;
    NSLog(@"headerSize : %f",headerSize);
    
    return CGSizeMake(self.navigationController.view.frame.size.width, viewHeight);
}

- (NSUInteger)rowCount
{
    CGSize contentSize = [self contentSize];
    
    CGFloat footerSize = [self footerSize].height;
    contentSize.height -= footerSize;
    NSLog(@"footerSize : %f",footerSize);
    
    NSLog(@"contentSize.height : %f", contentSize.height);
    
    CGFloat cellHeight = [self cellSize].height;
    NSLog(@"cellHeight : %f",cellHeight);
    
    NSUInteger count = (int)(contentSize.height/cellHeight);
    NSLog(@"count : %d", count);

    return count;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.backgroundColor = [UIColor whiteColor];
    self.collectionView.exclusiveTouch = YES;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _columnCount = 4;
    _rowCount = [self rowCount];
    _resultPerPage = _columnCount*_rowCount;
    
    [self.collectionView registerClass:[DZPhotoCell class] forCellWithReuseIdentifier:kThumbCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kThumbHeaderID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kThumbFooterID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_photos) {
        _photos = [NSMutableArray new];

        if (_searchTerm.length > 0) {
            self.searchBar.text = _searchTerm;
            [self searchPhotosWithKeyword:_searchTerm];
        }
        else {
            [self.searchBar becomeFirstResponder];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Getter methods

+ (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 2.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    return flowLayout;
}

- (CGSize)cellSize
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGFloat size = (self.navigationController.view.bounds.size.width/_columnCount) - flowLayout.minimumLineSpacing;
    return CGSizeMake(size, size);
}

- (CGSize)headerSize
{
    return [_searchBar isFirstResponder] ? CGSizeMake(0, 94.0) : CGSizeMake(0, 50.0);
}

- (CGSize)footerSize
{
    return CGSizeMake(0, (self.navigationController.view.frame.size.height > 480.0) ? 60.0 : 50.0);
}

- (DZPhotoPickerController *)navigationController
{
    return (DZPhotoPickerController *)[super navigationController];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.barStyle = UIBarStyleDefault;
        _searchBar.placeholder = NSLocalizedString(@"Search", nil);
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.barTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _searchBar.tintColor = self.view.window.tintColor;
        _searchBar.keyboardType = UIKeyboardAppearanceDark;
        _searchBar.delegate = self;
        
        [self.view addSubview:self.overlayView];
    }
    return _searchBar;
}

- (UIButton *)loadButton
{
    if (!_loadButton)
    {
        _loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loadButton setTitle:NSLocalizedString(@"Load More", nil) forState:UIControlStateNormal];
        [_loadButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_loadButton addTarget:self action:@selector(loadMoreData:) forControlEvents:UIControlEventTouchUpInside];
        [_loadButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_loadButton setBackgroundColor:self.collectionView.backgroundView.backgroundColor];
        
        [_loadButton addSubview:self.activityIndicator];
    }
    return _loadButton;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.hidesWhenStopped = YES;
    }
    _activityIndicator.center = _activityIndicator.superview.center;
    return _activityIndicator;
}


- (UIView *)overlayView
{
    if (!_overlayView)
    {
        CGFloat barHeight = self.navigationController.navigationBar.frame.size.height*2;
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-barHeight)];
        _overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _overlayView.alpha = 0;
        _overlayView.hidden = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_overlayView addGestureRecognizer:tapGesture];
    }
    return _overlayView;
}

- (NSArray *)segmentedControlTitles
{
    NSMutableArray *titles = [NSMutableArray array];
    
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceType500px) > 0) {
        [titles addObject:@"500px"];
    }
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceTypeFlickr) > 0) {
        [titles addObject:@"Flickr"];
    }
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceTypeInstagram) > 0) {
        [titles addObject:@"Instagram"];
    }
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceTypeGoogleImages) > 0) {
        [titles addObject:@"Google"];
    }
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceTypeBingImages) > 0) {
        [titles addObject:@"Bing"];
    }
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceTypeYahooImages) > 0) {
        [titles addObject:@"Yahoo"];
    }
    if ((self.navigationController.serviceType & DZPhotoPickerControllerServiceTypePanoramio) > 0) {
        [titles addObject:@"Panoramio"];
    }
    
//    if (titles.count == 3) return titles;
    return titles;
}

- (NSString *)selectedServiceName
{
    switch (_selectedService) {
        case DZPhotoPickerControllerServiceType500px:
            return @"500px";
            
        case DZPhotoPickerControllerServiceTypeFlickr:
            return @"Flickr";
            
        case DZPhotoPickerControllerServiceTypeInstagram:
            return @"Instagram";
            
        case DZPhotoPickerControllerServiceTypeGoogleImages:
            return @"Google Images";
            
        case DZPhotoPickerControllerServiceTypeBingImages:
            return @"Bing Images";
            
        case DZPhotoPickerControllerServiceTypeYahooImages:
            return @"Yahoo Images";
            
        case DZPhotoPickerControllerServiceTypePanoramio:
            return @"Panoramio";
            
        default:
            return nil;
    }
}

- (NSString *)sourceUrlForImageUrl:(NSString *)url
{
    switch (_selectedService) {
        case DZPhotoPickerControllerServiceType500px:
            return nil;
            
        case DZPhotoPickerControllerServiceTypeFlickr:
        {
            NSArray *components = [url componentsSeparatedByString:@"/"];
            NSString *lastComponent = [components lastObject];
            
            NSArray *ids = [lastComponent componentsSeparatedByString:@"_"];
            
            if (ids.count > 0) {
                NSString *photoId = [ids objectAtIndex:0];
                NSString *profileUrl = [NSString stringWithFormat:@"http://flickr.com/photo.gne?id=%@/", photoId];
                return [NSURL URLWithString:profileUrl];
            }
            else {
                return nil;
            }
        }
            
        case DZPhotoPickerControllerServiceTypeInstagram:
            return nil;
            
        case DZPhotoPickerControllerServiceTypeGoogleImages:
            return nil;
            
        case DZPhotoPickerControllerServiceTypeBingImages:
            return nil;
            
        case DZPhotoPickerControllerServiceTypeYahooImages:
            return nil;
            
        default:
            return nil;
    }
}

- (NSArray *)photosForResponse:(NSArray *)reponse
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:reponse.count];
    
    if ((_selectedService & DZPhotoPickerControllerServiceType500px) > 0) {
        for (NSDictionary *object in reponse) {

            DZPhoto *photo = [DZPhoto newPhotoWithTitle:[object valueForKey:@"username"]
                                             authorName:[NSString stringWithFormat:@"%@ %@",[object valueForKeyPath:@"user.firstname"],[object valueForKeyPath:@"user.lastname"]]
                                               thumbURL:[NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:0] valueForKey:@"url"]]
                                                fullURL:[NSURL URLWithString:[[[object valueForKey:@"images"] objectAtIndex:1] valueForKey:@"url"]]
                                             sourceName:[self selectedServiceName]];
            
            [result addObject:photo];
        }
    }
    else if ((_selectedService & DZPhotoPickerControllerServiceTypeFlickr) > 0) {
        for (NSDictionary *object in reponse) {
            
            DZPhoto *photo = [DZPhoto newPhotoWithTitle:[object valueForKey:@"title"]
                                             authorName:[object valueForKey:@"owner"]
                                               thumbURL:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLargeSquare150 fromPhotoDictionary:object]
                                                fullURL:[[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:object]
                                             sourceName:[self selectedServiceName]];
            
            [result addObject:photo];
        }
    }
    else if ((_selectedService & DZPhotoPickerControllerServiceTypeInstagram) > 0) {
        for (IGMedia *media in reponse) {
            
            DZPhoto *photo = [DZPhoto newPhotoWithTitle:media.caption.text
                                             authorName:media.user.username
                                               thumbURL:[NSURL URLWithString:media.image.thumbnail]
                                                fullURL:[NSURL URLWithString:media.image.standard_resolution]
                                             sourceName:[self selectedServiceName]];
            
            [result addObject:photo];
        }
    }
    
    return result;
}

- (BOOL)shouldShowFooter
{
    return (_photos.count%_resultPerPage == 0) ? YES : NO;
}


#pragma mark - Setter methods

- (void)resetPhotos
{
    [self setPhotos:nil];
    _photos = [NSMutableArray new];
    
    _currentPage = 1;
    
    [self.collectionView reloadData];
}


#pragma mark - DZPhotoDisplayController methods

- (void)handleResponse:(NSArray *)response
{
    [self handleActivityIndicators:NO];
    
    [_photos addObjectsFromArray:[self photosForResponse:response]];
    [self.collectionView reloadData];
}

- (void)handleError:(NSError *)error
{
    [self handleActivityIndicators:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

- (void)handleActivityIndicators:(BOOL)visible
{
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible == visible) {
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    
    if (visible) {
        [self.activityIndicator startAnimating];
        [_loadButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
    else {
        [self.activityIndicator stopAnimating];
        [_loadButton setTitleColor:self.view.window.tintColor forState:UIControlStateNormal];
    }
    
    _loading = visible;
}

- (void)handleSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.navigationController.allowsEditing) {
        
        DZPhotoEditViewController *photoEditViewController = [[DZPhotoEditViewController alloc] initWithCropMode:self.navigationController.editingMode];
        photoEditViewController.photo = [_photos objectAtIndex:indexPath.row];
        photoEditViewController.cropSize = self.navigationController.customCropSize;
        
        [self.navigationController pushViewController:photoEditViewController animated:YES];
    }
    else {
        DZPhoto *photo = [_photos objectAtIndex:indexPath.row];
        
        [self handleActivityIndicators:YES];

        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:photo.fullURL
                                                              options:SDWebImageCacheMemoryOnly|SDWebImageLowPriority|SDWebImageRetryFailed
                                                             progress:NULL
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                                if (!error) {
                                                                    [DZPhotoEditViewController didFinishPickingEditedImage:nil
                                                                                                              withCropRect:CGRectZero
                                                                                                         fromOriginalImage:image
                                                                                                              referenceURL:photo.fullURL
                                                                                                                authorName:photo.authorName
                                                                                                                sourceName:photo.sourceName];
                                                                }
                                                                else {
                                                                    [self handleError:error];
                                                                }
                                                                
                                                                [self handleActivityIndicators:NO];
                                                            }];
    }
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)searchPhotosWithKeyword:(NSString *)keyword
{
    [self handleActivityIndicators:YES];
    _searchTerm = keyword;
    
    if ((_selectedService & DZPhotoPickerControllerServiceType500px) > 0) {
        
        NSString *term = [_searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        _PXRequest = [PXRequest requestForSearchTerm:term page:_currentPage resultsPerPage:_resultPerPage
                             photoSizes:PXPhotoModelSizeSmallThumbnail | PXPhotoModelSizeExtraLarge
                                 except:PXPhotoModelCategoryUncategorized
                             completion:^(NSDictionary *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response) [self handleResponse:[response valueForKey:@"photos"]];
                else [self handleError:error];
            });
        }];
    }
    else if ((_selectedService & DZPhotoPickerControllerServiceTypeFlickr) > 0) {
        
        FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
        search.text = _searchTerm; //[keyword stringByReplacingOccurrencesOfString:@" " withString:@" OR "];
        search.content_type = @"1";
        search.safe_search = @"1";
        search.media = @"photos";
        search.in_gallery = @"true";
        search.per_page = [NSString stringWithFormat:@"%d",_resultPerPage];
        search.page = [NSString stringWithFormat:@"%d",_currentPage];

        [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response) [self handleResponse:[response valueForKeyPath:@"photos.photo"]];
                else [self handleError:error];
            });
        }];
    }
    else if ((_selectedService & DZPhotoPickerControllerServiceTypeInstagram) > 0) {
        
        NSString *term = [_searchTerm stringByReplacingOccurrencesOfString:@" " withString:@","];
        
        [NRGramKit getMediaRecentInTagWithName:term count:_resultPerPage maxTagId:_instagramMaxId minTagId:_instagramMinId
                                  withCallback:^(NSArray *medias, IGPagination *pagination){
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (medias) [self handleResponse:medias];
                                          if (pagination) {
                                              _instagramMaxId = pagination.nextMaxId;
                                              _instagramMinId = pagination.nextMinId;
                                          }
                                      });
                                  }];
    }
}

- (void)stopAnyRequest
{
    [self handleActivityIndicators:NO];
    
    if ((_selectedService & DZPhotoPickerControllerServiceType500px) > 0) {
        
        if (_PXRequest) {
            [_PXRequest cancel];
            _PXRequest = nil;
        }
    }
    else if ((_selectedService & DZPhotoPickerControllerServiceTypeFlickr) > 0) {
        
//        [FlickrKit sharedFlickrKit]
    }
    else if ((_selectedService & DZPhotoPickerControllerServiceTypeInstagram) > 0) {
        
//        NRGramKit
    }
    
    for (DZPhotoCell *cell in [self.collectionView visibleCells]) {
        [cell.imageView cancelCurrentImageLoad];
    }
}

- (void)loadMoreData:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.enabled = NO;
    
    _currentPage++;
    [self searchPhotosWithKeyword:_searchTerm];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kThumbCellID forIndexPath:indexPath];
    cell.photoDisplayController = self;
    cell.tag = indexPath.row;
    
    DZPhoto *photo = [_photos objectAtIndex:indexPath.row];
    
    [cell.imageView cancelCurrentImageLoad];
    [cell.imageView setImageWithURL:photo.thumbURL placeholderImage:nil
                              options:SDWebImageProgressiveDownload|SDWebImageRetryFailed completed:NULL];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kThumbHeaderID forIndexPath:indexPath];
        
        if (header.subviews.count == 0) {
            CGRect rect = header.frame;
            rect.size.height = 44.0;
            
            [header addSubview:self.searchBar];
            _searchBar.frame = rect;
            _searchBar.scopeButtonTitles = [self segmentedControlTitles];
            _searchBar.selectedScopeButtonIndex = _selectedService-1;
        }
        
        return header;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kThumbFooterID forIndexPath:indexPath];
        
        if ([self shouldShowFooter]) {
            if (footer.subviews.count == 0) {
                [footer addSubview:self.loadButton];
            }
            _loadButton.frame = footer.bounds;
            
            if (_photos.count > 0) {
                _loadButton.enabled = YES;
                [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            }
            else {
                _loadButton.enabled = NO;
                [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
                self.activityIndicator.color = [UIColor grayColor];
            }
        }
        else {
            [_loadButton removeFromSuperview];
            [self setLoadButton:nil];
        }
        return footer;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDataDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
        [self performSelector:@selector(handleSelectionAtIndexPath:) withObject:indexPath afterDelay:0.3];
    }
    else [self handleSelectionAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__FUNCTION__);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
//        return NO;
//    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
{

}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return [self headerSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    if (_photos.count == 0) size = [self contentSize];
    else size = [self footerSize];
    
    NSLog(@"footer size : %@", NSStringFromCGSize(size));
    return size;
    
//    if (_photos.count == 0) return self.view.frame.size;
//    else return [self footerSize];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (![NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"])
    {
        DZPhotoCell *cell = (DZPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];

        UIImage *image = cell.imageView.image;
        if (image) [[UIPasteboard generalPasteboard] setImage:image];
    }
}


#pragma mark - UISearchBarDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (_loading) {
        [self stopAnyRequest];
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    _overlayView.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
        [searchBar setShowsScopeBar:YES];
        [searchBar sizeToFit];
        
        [self.collectionViewLayout invalidateLayout];
        _overlayView.alpha = 1.0;
    }];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [UIView animateWithDuration:0.4 animations:^{
        [searchBar setShowsScopeBar:NO];
        [searchBar sizeToFit];
        [self.collectionViewLayout invalidateLayout];

        _overlayView.alpha = 0;
        
    } completion:^(BOOL finished){
        _overlayView.hidden = YES;
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setText:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if (_previousService != _selectedService || _searchTerm != searchBar.text) {
        _previousService = _selectedService;
        [self resetPhotos];

        [self searchPhotosWithKeyword:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    _selectedService = (1 << selectedScope);
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

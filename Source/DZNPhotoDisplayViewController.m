//
//  DZNPhotoDisplayController.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoDisplayViewController.h"
#import "DZNPhotoPickerController.h"
#import "DZNPhotoEditViewController.h"

#import "DZNPhotoDisplayViewCell.h"
#import "DZNPhotoDescription.h"

#define kMinimumBarHeight 44.0

static NSString *kThumbCellID = @"kThumbCellID";
static NSString *kThumbFooterID = @"kThumbFooterID";
static NSString *kTagCellID = @"kTagCellID";

@interface DZNPhotoDisplayViewController () <UISearchDisplayDelegate, UISearchBarDelegate,
                                            UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, readwrite) UIButton *loadButton;
@property (nonatomic, readwrite) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableArray *photoDescriptions;
@property (nonatomic, strong) NSMutableArray *searchTags;
@property (nonatomic, strong) NSArray *segmentedControlTitles;
@property (nonatomic) DZNPhotoPickerControllerService selectedService;
@property (nonatomic) DZNPhotoPickerControllerService previousService;
@property (nonatomic, strong) PXRequest *PXRequest;
@property (nonatomic) NSInteger resultPerPage;
@property (nonatomic) NSInteger currentPage;

@end

@implementation DZNPhotoDisplayViewController

- (id)init
{
    self = [super initWithCollectionViewLayout:[DZNPhotoDisplayViewController flowLayout]];
    if (self) {
        
        self.title = NSLocalizedString(@"Internet Photos", nil);
        _selectedService = DZNPhotoPickerControllerService500px;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    _searchController.searchResultsTableView.tableHeaderView = [UIView new];
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
    _searchController.searchResultsTableView.backgroundView = [UIView new];
    _searchController.searchResultsTableView.backgroundView.backgroundColor = [UIColor whiteColor];
    _searchController.searchResultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _searchController.delegate = self;
    
    [_searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTagCellID];
    
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    self.collectionView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height+8.0, 0, 0, 0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
    
    [self.collectionView registerClass:[DZNPhotoDisplayViewCell class] forCellWithReuseIdentifier:kThumbCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kThumbFooterID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentPage = 1;
    _columnCount = 4;
    _rowCount = [self rowCount];
    _resultPerPage = _columnCount*_rowCount;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_photoDescriptions) {
        _photoDescriptions = [NSMutableArray new];

        if (_searchTerm.length == 0) {
            [self.searchDisplayController setActive:YES];
            [_searchBar becomeFirstResponder];
        }
        else [self searchPhotosWithKeyword:_searchTerm];
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

- (DZNPhotoPickerController *)navigationController
{
    return (DZNPhotoPickerController *)[super navigationController];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[UISearchBar alloc] initWithFrame:[self searchBarFrame]];
        _searchBar.placeholder = NSLocalizedString(@"Search", nil);
        _searchBar.barStyle = UIBarStyleDefault;
        _searchBar.searchBarStyle = UISearchBarStyleProminent;
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.barTintColor = [UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:207.0/255.0 alpha:1.0];
        _searchBar.tintColor = self.view.window.tintColor;
        _searchBar.keyboardType = UIKeyboardAppearanceDark;
        _searchBar.text = _searchTerm;
        _searchBar.delegate = self;
        
        _searchBar.scopeButtonTitles = [self segmentedControlTitles];
        _searchBar.selectedScopeButtonIndex = _selectedService-1;
        
        [self.view addSubview:_searchBar];
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
        [_loadButton addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventTouchUpInside];
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
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _activityIndicator;
}

- (CGSize)cellSize
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat size = (self.navigationController.view.bounds.size.width/_columnCount) - flowLayout.minimumLineSpacing;
    return CGSizeMake(size, size);
}

- (CGSize)footerSize
{
    return CGSizeMake(0, (self.navigationController.view.frame.size.height > 480.0) ? 60.0 : 50.0);
}

/*
 * The collectionView's content size calculation.
 */
- (CGSize)topBarsSize
{
    CGFloat topBarsHeight = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        topBarsHeight += statusHeight;
    }
    
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
    topBarsHeight += navigationHeight;
    
    topBarsHeight += self.searchBar.frame.size.height+8.0;
    
    return CGSizeMake(self.navigationController.view.frame.size.width, topBarsHeight);
}

/*
 * The collectionView's content size calculation.
 */
- (CGSize)contentSize
{
    CGFloat viewHeight = self.navigationController.view.frame.size.height;
    CGFloat topBarsHeight = [self topBarsSize].height;
    return CGSizeMake(self.navigationController.view.frame.size.width, viewHeight-topBarsHeight);
}

/*
 * The search bar appropriate rectangle.
 */
- (CGRect)searchBarFrame
{
    BOOL shouldShift = _searchBar.showsScopeBar;
    
    CGFloat statusHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIApplication sharedApplication].statusBarFrame.size.height : 0.0;
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, kMinimumBarHeight);
    frame.size.height = shouldShift ? kMinimumBarHeight*2 : kMinimumBarHeight;
    frame.origin.y = shouldShift ? statusHeight : 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !shouldShift) {
        frame.origin.y += statusHeight+kMinimumBarHeight;
    }
    
    return frame;
}

/*
 * Dinamically calculate the available row count based on the collectionView's content size and the cell height.
 * This allows to easily modify the collectionView layout, for displaying the image thumbs.
 */
- (NSUInteger)rowCount
{
    CGSize contentSize = [self contentSize];
    
    CGFloat footerSize = [self footerSize].height;
    contentSize.height -= footerSize;
    
    CGFloat cellHeight = [self cellSize].height;
    
    NSUInteger count = (int)(contentSize.height/cellHeight);
    return count;
}

/*
 * Returns the segmented control titles, based on the supported services.
 * Default returns "500px" & "Flickr".
 */
- (NSArray *)segmentedControlTitles
{
    if (!_segmentedControlTitles)
    {
        NSMutableArray *titles = [NSMutableArray array];
        
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerService500px) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerService500px)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServiceFlickr) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServiceFlickr)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServiceGoogleImages) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServiceGoogleImages)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServiceBingImages) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServiceBingImages)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServiceYahooImages) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServiceYahooImages)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServicePanoramio) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServicePanoramio)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServiceInstagram) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServiceInstagram)];
        }
        if ((self.navigationController.supportedServices & DZNPhotoPickerControllerServiceDribbble) > 0) {
            [titles addObject:NSStringFromServiceType(DZNPhotoPickerControllerServiceDribbble)];
        }
        
        _segmentedControlTitles = [NSArray arrayWithArray:titles];
    }
    return _segmentedControlTitles;
}

/*
 * Returns the a complete & valide source url of a specific service url.
 * This applies only for some photo services, that do not expose the source url on their API.
 */
- (NSString *)sourceUrlForImageUrl:(NSString *)url
{
    switch (_selectedService) {
        case DZNPhotoPickerControllerService500px:
            return nil;
            
        case DZNPhotoPickerControllerServiceFlickr:
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
            
        case DZNPhotoPickerControllerServiceGoogleImages:
            return nil;
            
        case DZNPhotoPickerControllerServiceBingImages:
            return nil;
            
        case DZNPhotoPickerControllerServiceYahooImages:
            return nil;
            
        default:
            return nil;
    }
}

/*
 * Checks if an additional footer for loading more content should be displayed.
 */
- (BOOL)shouldShowFooter
{
    return (_photoDescriptions.count%_resultPerPage == 0) ? YES : NO;
}


#pragma mark - Setter methods

/* Sets the search bar text, specially when the UISearchDisplayController when dimissing removes the bar's text by default.
 */
- (void)setSearchBarText:(NSString *)text
{
    self.searchController.searchBar.text = text;
}

/*
 * Sets the current photo search response and refreshs the collection view.
 */
- (void)setPhotoSearchResponse:(NSArray *)response
{
    [self showActivityIndicators:NO];
    
    NSArray *descriptions = [DZNPhotoDescription photoDescriptionsFromService:_selectedService withResponse:response];
    
    [_photoDescriptions addObjectsFromArray:descriptions];
    [self.collectionView reloadData];
    
    CGSize contentSize = self.collectionView.contentSize;
    self.collectionView.contentSize = CGSizeMake(contentSize.width, contentSize.height+[self footerSize].height);
}

/*
 * Sets a tag search response and refreshs the results tableview from the UISearchDisplayController.
 */
- (void)setTagSearchResponse:(NSArray *)response
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!_searchTags) _searchTags = [NSMutableArray new];
    else [_searchTags removeAllObjects];
    
    for (NSDictionary *tag in response) {
        [_searchTags addObject:[tag objectForKey:@"_content"]];
    }
    
    [_searchTags insertObject:_searchBar.text atIndex:0];
    
    [_searchController.searchResultsTableView reloadData];
}

/*
 * Sets the request errors with an alert view.
 */
- (void)setSearchError:(NSError *)error
{
    [self showActivityIndicators:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}


#pragma mark - DZNPhotoDisplayController methods

/*
 * Toggles the status bar & footer activity indicators.
 */
- (void)showActivityIndicators:(BOOL)visible
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    
    if (visible) {
        [self.activityIndicator startAnimating];
        [_loadButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
    else {
        [self.activityIndicator stopAnimating];
    }
    
    _loading = visible;
    self.collectionView.userInteractionEnabled = !visible;
}

/*
 * Handles a thumbnail selection.
 * It either downloads the image directly or shows the edit controller.
 */
- (void)handleSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoDescription *description = [_photoDescriptions objectAtIndex:indexPath.row];
    
    if (self.navigationController.allowsEditing) {
        
        DZNPhotoEditViewController *photoEditViewController = [[DZNPhotoEditViewController alloc] initWithPhotoDescription:description cropMode:self.navigationController.editingMode];
        [self.navigationController pushViewController:photoEditViewController animated:YES];
    }
    else {
        
        [self showActivityIndicators:YES];

        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:description.fullURL
                                                              options:SDWebImageCacheMemoryOnly|SDWebImageRetryFailed
                                                             progress:NULL
                                             completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                 
                                                 if (image) {
                                                     [DZNPhotoEditViewController didFinishPickingOriginalImage:image editedImage:nil cropRect:CGRectZero
                                                                                                      cropMode:DZNPhotoEditViewControllerCropModeNone
                                                                                                  referenceURL:description.fullURL
                                                                                                    authorName:description.authorName
                                                                                                    sourceName:description.sourceName];
                                                 }
                                                 else {
                                                     [self setSearchError:error];
                                                 }
                                                 
                                                 [self showActivityIndicators:NO];
                                             }];
    }
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

/*
 * Checks if the search string is long enough to perfom a tag search.
 */
- (BOOL)canSearchTag:(NSString *)searchString
{
    if ([_searchController.searchBar isFirstResponder] && searchString.length > 2) {
        [self searchTagsWithKeyword:searchString];
        return YES;
    }
    else {
        [_searchTags removeAllObjects];
        [_searchController.searchResultsTableView reloadData];
        return NO;
    }
}

/*
 * Triggers a tag search when typing more than 2 characters in the search bar.
 * This allows auto-completion and related tags to what the user wants to search.
 */
- (void)searchTagsWithKeyword:(NSString *)keyword
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    FKFlickrTagsGetRelated *search = [[FKFlickrTagsGetRelated alloc] init];
    search.tag = keyword;
    
    [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
                if (error) [self setSearchError:error];
                else [self setTagSearchResponse:[response valueForKeyPath:@"tags.tag"]];
            });
    }];
}

/*
 * Checks if the search string is valid and conditions are ok, for performing a photo search.
 */
- (void)shouldSearchPhotos:(NSString *)keyword
{
    if ((_previousService != _selectedService || _searchTerm != keyword) && keyword.length > 1) {
        
        _previousService = _selectedService;
        [self resetPhotos];
        
        [self searchPhotosWithKeyword:keyword];
    }
    
    [self setSearchBarText:keyword];
}

/*
 * Triggers a photo search of the selected photo service.
 * Each photo service API requieres different params.
 */
- (void)searchPhotosWithKeyword:(NSString *)keyword
{
    [self showActivityIndicators:YES];
    _searchTerm = keyword;
    
    NSLog(@"Searching \"%@\" (page %d) on %@", keyword, _currentPage, NSStringFromServiceType(_selectedService));
    
    if ((_selectedService & DZNPhotoPickerControllerService500px) > 0) {
        
        NSString *term = [_searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        _PXRequest = [PXRequest requestForSearchTerm:term page:_currentPage resultsPerPage:_resultPerPage
                             photoSizes:PXPhotoModelSizeSmallThumbnail|PXPhotoModelSizeExtraLarge
                                 except:PXPhotoModelCategoryUncategorized
                             completion:^(NSDictionary *response, NSError *error) {
                                 
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) [self setSearchError:error];
                else [self setPhotoSearchResponse:[response valueForKey:@"photos"]];
            });
                                 
        }];
    }
    else if ((_selectedService & DZNPhotoPickerControllerServiceFlickr) > 0) {
        
        FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
        search.text = _searchTerm; //[keyword stringByReplacingOccurrencesOfString:@" " withString:@" OR "];
        search.content_type = @"1";
        search.safe_search = @"1";
        search.media = @"photos";
        search.in_gallery = @"true";
        search.per_page = [NSString stringWithFormat:@"%ld",(long)_resultPerPage];
        search.page = [NSString stringWithFormat:@"%ld",(long)_currentPage];

        [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) [self setSearchError:error];
                else [self setPhotoSearchResponse:[response valueForKeyPath:@"photos.photo"]];
            });
            
        }];
    }
}

/*
 * Stops the loading search request of the selected photo service.
 */
- (void)stopLoadingRequest
{
    if (!self.loading) {
        return;
    }
    
    [self showActivityIndicators:NO];
    
    if ((_selectedService & DZNPhotoPickerControllerService500px) > 0) {
        
        if (_PXRequest) {
            [_PXRequest cancel];
            _PXRequest = nil;
        }
    }
    else if ((_selectedService & DZNPhotoPickerControllerServiceFlickr) > 0) {
        
    }
    
    for (DZNPhotoDisplayViewCell *cell in [self.collectionView visibleCells]) {
        [cell.imageView cancelCurrentImageLoad];
    }
}

/*
 * Triggers a photo search for the next page.
 */
- (void)downloadData
{
    _loadButton.enabled = NO;
    
    _currentPage++;
    [self searchPhotosWithKeyword:_searchTerm];
}

/*
 * Removes all photo description from the array and cleans the collection view from photo thumbnails.
 */
- (void)resetPhotos
{
    [_photoDescriptions removeAllObjects];
    _currentPage = 1;
    
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoDescriptions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoDisplayViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kThumbCellID forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    DZNPhotoDescription *description = [_photoDescriptions objectAtIndex:indexPath.row];
    
    [cell.imageView cancelCurrentImageLoad];
    [cell.imageView setImageWithURL:description.thumbURL placeholderImage:nil
                              options:SDWebImageCacheMemoryOnly completed:NULL];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kThumbFooterID forIndexPath:indexPath];
        
        if ([self shouldShowFooter]) {
            
            if (!_loadButton && footer.subviews.count == 0) {
                [footer addSubview:self.loadButton];
            }
            
            _loadButton.frame = footer.bounds;
            
            if (_photoDescriptions.count > 0) {
                _loadButton.enabled = YES;
                [_loadButton setTitleColor:self.view.window.tintColor forState:UIControlStateNormal];

                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [self.activityIndicator stopAnimating];
            }
            else {
                _loadButton.enabled = NO;
                [_loadButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];

                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
                self.activityIndicator.color = [UIColor grayColor];
            }
        }
        else {
            [self.activityIndicator stopAnimating];
            
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
    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];

    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
        [self performSelector:@selector(handleSelectionAtIndexPath:) withObject:indexPath afterDelay:0.3];
    }
    else [self handleSelectionAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
{

}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (_photoDescriptions.count == 0) {
        return [self contentSize];
    }
    else return [self footerSize];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoDisplayViewCell *cell = (DZNPhotoDisplayViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.imageView.image) {
        return YES;
    }
    else return NO;
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
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        
        DZNPhotoDisplayViewCell *cell = (DZNPhotoDisplayViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

        UIImage *image = cell.imageView.image;
        if (image) [[UIPasteboard generalPasteboard] setImage:image];
    }
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTagCellID];
    
    if (indexPath.row <= _searchTags.count-1) {
        
        NSString *tagString = [_searchTags objectAtIndex:indexPath.row];
        cell.textLabel.text = tagString;
    }
    else {
        cell.textLabel.text = @"Empty";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMinimumBarHeight;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tagString = [_searchTags objectAtIndex:indexPath.row];
    [self shouldSearchPhotos:tagString];
    
    [self.searchDisplayController setActive:NO animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UISearchDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    if (_loading) {
//        [self stopLoadingRequest];
//    }
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarShouldShift:(BOOL)shift
{
    _searchBar.showsScopeBar = shift;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.searchBar setFrame:[self searchBarFrame]];
                         [self.searchController setActive:shift];
                     }
                     completion:NULL];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *str = searchBar.text;
    [self shouldSearchPhotos:str];
    
    [self searchBarShouldShift:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    _selectedService = (1 << selectedScope);
}


#pragma mark - UISearchDisplayDelegate methods
#pragma mark Search State Change

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self searchBarShouldShift:YES];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self searchBarShouldShift:NO];
    
    [_searchTags removeAllObjects];
    [controller.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
}

#pragma mark Loading and Unloading the Table View

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    
}

#pragma mark Showing and Hiding the Table View

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return [self canSearchTag:searchString];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
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
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

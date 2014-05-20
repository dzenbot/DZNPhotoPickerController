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
#import "DZNPhotoServiceFactory.h"

#import "DZNPhotoDisplayViewCell.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

#import "SDWebImageManager.h"

static NSString *kDZNPhotoCellViewIdentifier = @"kDZNPhotoCellViewIdentifier";
static NSString *kDZNPhotoFooterViewIdentifier = @"kDZNPhotoFooterViewIdentifier";
static NSString *kDZNTagCellViewIdentifier = @"kDZNTagCellViewIdentifier";
static CGFloat kDZNPhotoDisplayMinimumBarHeight = 44.0;

@interface DZNPhotoDisplayViewController () <UISearchDisplayDelegate, UISearchBarDelegate,
                                            UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) UISearchDisplayController *searchController;
@property (nonatomic, readonly) UIButton *loadButton;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableArray *metadataList;
@property (nonatomic, strong) NSMutableArray *tagList;
@property (nonatomic, strong) NSArray *segmentedControlTitles;
@property (nonatomic) DZNPhotoPickerControllerServices selectedService;
@property (nonatomic) DZNPhotoPickerControllerServices previousService;
@property (nonatomic) NSInteger resultPerPage;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, readonly) UILabel *titleSetLabel;
@property (nonatomic, readonly) UILabel *detailSetLabel;

@property (nonatomic, readonly) NSTimer *searchTimer;

@end

@implementation DZNPhotoDisplayViewController
@synthesize searchBar = _searchBar;
@synthesize searchController = _searchController;
@synthesize loadButton = _loadButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize titleSetLabel = _titleSetLabel;
@synthesize detailSetLabel = _detailSetLabel;
@synthesize searchTimer = _searchTimer;

- (instancetype)init
{
    return [self initWithCollectionViewLayout:[DZNPhotoDisplayViewController flowLayout]];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = NSLocalizedString(@"Internet Photos", nil);
        
        _currentPage = 1;
        _columnCount = 4;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    _segmentedControlTitles = NSArrayFromServices(self.navigationController.supportedServices);
    NSAssert((_segmentedControlTitles.count < 4), @"DZNPhotoPickerController doesn't support more than 4 photo service providers");
    
    _selectedService = DZNFirstPhotoServiceFromPhotoServices(self.navigationController.supportedServices);
    NSAssert((_selectedService > 0), @"DZNPhotoPickerController requieres at least 1 supported photo service provider");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.backgroundView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    self.collectionView.contentInset = UIEdgeInsetsMake(self.searchBar.frame.size.height+8.0, 0, 0, 0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
    
    [self.collectionView registerClass:[DZNPhotoDisplayViewCell class] forCellWithReuseIdentifier:kDZNPhotoCellViewIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDZNPhotoFooterViewIdentifier];
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDZNTagCellViewIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_metadataList) {

        if (_searchBar.text.length > 0) {
            [self searchPhotosWithKeyword:_searchBar.text];
        }
        else {
            [self.searchDisplayController setActive:YES];
            [_searchBar becomeFirstResponder];
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

/*
 * Returns the custom collection view layout.
 */
+ (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 2.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    return flowLayout;
}

/*
 * Returns the selected service client.
 */
- (id<DZNPhotoServiceClientProtocol>)selectedServiceClient
{
    return [[DZNPhotoServiceFactory defaultFactory] clientForService:self.selectedService];
}

/*
 * Returns the navigation controller casted to DZNPhotoPickerController.
 */
- (DZNPhotoPickerController *)navigationController
{
    return (DZNPhotoPickerController *)[super navigationController];
}

/*
 * Returns the custom search display controller.
 */
- (UISearchDisplayController *)searchController
{
    if (!_searchController)
    {
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
        
        [_searchController setValue:@"" forKey:@"noResultsMessage"];
    }
    return _searchController;
}

/*
 * Returns the custom search bar.
 */
- (UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[UISearchBar alloc] initWithFrame:[self searchBarFrame]];
        _searchBar.placeholder = NSLocalizedString(@"Search", nil);
        _searchBar.barStyle = UIBarStyleDefault;
        _searchBar.searchBarStyle = UISearchBarStyleDefault;
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.barTintColor = [UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:207.0/255.0 alpha:1.0];
        _searchBar.tintColor = self.view.window.tintColor;
        _searchBar.keyboardType = UIKeyboardAppearanceDark;
        _searchBar.text = self.navigationController.initialSearchTerm;
        _searchBar.delegate = self;
        
        if (self.segmentedControlTitles.count > 1) {
            _searchBar.scopeButtonTitles = [self segmentedControlTitles];
        }
        
        _searchBar.selectedScopeButtonIndex = 0;
        
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}


/*
 * Returns the 'Load More' footer button.
 */
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

/*
 * Returns the activity indicator.
 */
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        [_activityIndicator sizeToFit];
    }
    return _activityIndicator;
}

- (UILabel *)titleSetLabel
{
    if (!_titleSetLabel)
    {
        _titleSetLabel = [UILabel new];
        _titleSetLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleSetLabel.text = NSLocalizedString(@"No Photos Found", nil);
        _titleSetLabel.font = [UIFont systemFontOfSize:27.0];
        _titleSetLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _titleSetLabel.textAlignment = NSTextAlignmentCenter;
        _titleSetLabel.numberOfLines = 1;
    }
    return _titleSetLabel;
}

- (UILabel *)detailSetLabel
{
    if (!_detailSetLabel)
    {
        _detailSetLabel = [UILabel new];
        _detailSetLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailSetLabel.text = NSLocalizedString(@"Make sure that all words are spelled correctly.", nil);
        _detailSetLabel.font = [UIFont systemFontOfSize:17.0];
        _detailSetLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _detailSetLabel.textAlignment = NSTextAlignmentCenter;
        _detailSetLabel.numberOfLines = 2;
    }
    return _detailSetLabel;
}

/*
 * Returns the appropriate cell view's size.
 */
- (CGSize)cellSize
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat size = (self.navigationController.view.bounds.size.width/_columnCount) - flowLayout.minimumLineSpacing;
    return CGSizeMake(size, size);
}

/*
 * Returns the appropriate footer view's size.
 */
- (CGSize)footerSize
{
    return CGSizeMake(0, (self.navigationController.view.frame.size.height > 480.0) ? 60.0 : 50.0);
}

/*
 * Returns the collectionView's content size.
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
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width,  kDZNPhotoDisplayMinimumBarHeight);
    frame.size.height = shouldShift ?  kDZNPhotoDisplayMinimumBarHeight*2 :  kDZNPhotoDisplayMinimumBarHeight;
    frame.origin.y = shouldShift ? statusHeight : 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !shouldShift) {
        frame.origin.y += statusHeight+ kDZNPhotoDisplayMinimumBarHeight;
    }
    
    return frame;
}

/*
 * Calculates the available row count based on the collectionView's content size and the cell height.
 * This allows to easily modify the collectionView layout, for displaying the image thumbs.
 */
- (NSInteger)rowCount
{
    CGSize contentSize = [self contentSize];
    
    CGFloat footerSize = [self footerSize].height;
    contentSize.height -= footerSize;
    contentSize.height += self.navigationController.navigationBar.frame.size.height;
    
    CGFloat cellHeight = [self cellSize].height;
    
    NSInteger count = (int)(contentSize.height/cellHeight);
    
    if (self.selectedServiceClient.service == DZNPhotoPickerControllerServiceGoogleImages &&
        self.selectedServiceClient.subscription == DZNPhotoPickerControllerSubscriptionFree) {
        count = count/2;
    }
    
    return count;
}

/*
 * Returns the appropriate number of result per page.
 */
- (NSInteger)resultPerPage
{
    return self.columnCount * self.rowCount;
}

/*
 * Checks if the search string is long enough to perfom a tag search.
 */
- (BOOL)canSearchTag:(NSString *)term
{
    if (!self.navigationController.enableTagSearch) {
        return NO;
    }
    
    if ([self.searchDisplayController.searchBar isFirstResponder] && term.length > 2) {
        
        [self resetSearchTimer];
        
        _searchTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(searchTag:) userInfo:@{@"term": term} repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_searchTimer forMode:NSDefaultRunLoopMode];
        
        return YES;
    }
    else {
        [_tagList removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
        return NO;
    }
}

/*
 * Checks if an additional footer view for loading more content should be displayed.
 */
- (BOOL)canDisplayFooterView
{
    if (_metadataList.count > 0) {
        return (_metadataList.count%self.resultPerPage == 0) ? YES : NO;
    }
    return self.loading;
}


#pragma mark - Setter methods

/* Sets the search bar text, specially when the UISearchDisplayController when dimissing removes the bar's text by default.
 */
- (void)setSearchBarText:(NSString *)text
{
    self.searchDisplayController.searchBar.text = text;
}

/*
 * Sets the current photo search response and refreshs the collection view.
 */
- (void)setPhotoSearchList:(NSArray *)list
{
    [self setActivityIndicatorsVisible:NO];
    
    if (!_metadataList) _metadataList = [NSMutableArray new];
    
    [_metadataList addObjectsFromArray:list];
    [self.collectionView reloadData];
    
    BOOL show = (_metadataList.count == 0) ? YES : NO;
    [self setEmptyDataSetVisible:show];
    
    CGSize contentSize = self.collectionView.contentSize;
    self.collectionView.contentSize = CGSizeMake(contentSize.width, contentSize.height+[self footerSize].height);
}

/*
 * Sets a tag search response and refreshs the results tableview from the UISearchDisplayController.
 */
- (void)setTagSearchList:(NSArray *)list
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!_tagList) _tagList = [NSMutableArray new];
    else [_tagList removeAllObjects];
    
    [_tagList addObjectsFromArray:list];
    
    if (_tagList.count == 1) {
        [_tagList removeAllObjects];
        
        DZNPhotoTag *tag = [DZNPhotoTag newTagWithTerm:_searchBar.text service:_selectedService];
        [_tagList addObject:tag];
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)setEmptyDataSetVisible:(BOOL)visible
{
    if (visible) {
        [self.view addSubview:self.titleSetLabel];
        [self.view addSubview:self.detailSetLabel];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_searchBar, _titleSetLabel, _detailSetLabel);
        
        CGFloat bottomMargin = (((self.view.frame.size.height-[self topBarsSize].height-8.0)/2)-40.0);
        CGFloat topMargin = bottomMargin+[self topBarsSize].height;
        NSDictionary *metrics = @{@"topMargin": @(topMargin), @"bottomMargin": @(bottomMargin)};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[_titleSetLabel][_detailSetLabel(==_titleSetLabel)]-bottomMargin-|" options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleSetLabel]-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_detailSetLabel]-|" options:0 metrics:nil views:views]];
    }
    else if (_titleSetLabel && _detailSetLabel) {
        [_titleSetLabel removeFromSuperview];
        _titleSetLabel = nil;
        
        [_detailSetLabel removeFromSuperview];
        _detailSetLabel = nil;
    }
}

/*
 * Toggles the activity indicators on the status bar & footer view.
 */
- (void)setActivityIndicatorsVisible:(BOOL)visible
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
 * Sets the request errors with an alert view.
 */
- (void)setLoadingError:(NSError *)error
{
    switch (error.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorUnknown:
        case NSURLErrorCancelled:
            return;
    }
    
    [self setActivityIndicatorsVisible:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

/*
 * Invalidates and nullifys the search timer.
 */
- (void)resetSearchTimer
{
    if (_searchTimer) {
        [_searchTimer invalidate];
        _searchTimer = nil;
    }
}

/*
 * Removes all photo metadata from the array and cleans the collection view from photo thumbnails.
 */
- (void)resetPhotos
{
    [_metadataList removeAllObjects];
    _currentPage = 1;
    
    [self.collectionView reloadData];
}


#pragma mark - DZNPhotoDisplayController methods

/*
 * Handles the thumbnail selection.
 *
 * Depending on configuration, the selection might result in one of the following action:
 * - Return only the photo metadata and dismiss the controller
 * - Push into the edit controller for cropping
 * - Download the full size photo and dismiss the controller
 */
- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoMetadata *metadata = [_metadataList objectAtIndex:indexPath.row];
    
    if (!self.navigationController.enablePhotoDownload) {
        
        [DZNPhotoEditorViewController didFinishPickingOriginalImage:nil
                                                        editedImage:nil
                                                           cropRect:CGRectZero
                                                          zoomScale:1.0
                                                           cropMode:DZNPhotoEditorViewControllerCropModeNone
                                                      photoMetadata:metadata];
    }
    else if (self.navigationController.allowsEditing) {
        
        DZNPhotoEditorViewController *controller = [[DZNPhotoEditorViewController alloc] initWithMetadata:metadata cropMode:self.navigationController.cropMode cropSize:self.navigationController.cropSize];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        
        [self setActivityIndicatorsVisible:YES];

        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:metadata.sourceURL
                                                              options:SDWebImageCacheMemoryOnly|SDWebImageRetryFailed
                                                             progress:NULL
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                                if (image) {
                                                                    [DZNPhotoEditorViewController didFinishPickingOriginalImage:image
                                                                                                                    editedImage:nil
                                                                                                                       cropRect:CGRectZero
                                                                                                                      zoomScale:1.0
                                                                                                                       cropMode:DZNPhotoEditorViewControllerCropModeNone
                                                                                                                  photoMetadata:metadata];
                                                                    
                                                                }
                                                                else {
                                                                    [self setLoadingError:error];
                                                                }
                                                                
                                                                [self setActivityIndicatorsVisible:NO];
                                                            }];
    }
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

/*
 * Triggers a tag search when typing more than 2 characters in the search bar.
 * This allows auto-completion and related tags to what the user wants to search.
 */
- (void)searchTag:(NSTimer *)timer
{
    NSString *term = [timer.userInfo objectForKey:@"term"];
    [self resetSearchTimer];
    
    id <DZNPhotoServiceClientProtocol> client = [[DZNPhotoServiceFactory defaultFactory] clientForService:DZNPhotoPickerControllerServiceFlickr];
    
    if (!client) {
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [client searchTagsWithKeyword:term
                       completion:^(NSArray *list, NSError *error) {
                           if (error) [self setLoadingError:error];
                           else [self setTagSearchList:list];
                       }];
}

/*
 * Checks if the search string is valid and conditions are ok, for performing a photo search.
 */
- (void)shouldSearchPhotos:(NSString *)keyword
{
    if ((_previousService != _selectedService || _searchBar.text != keyword) && keyword.length > 1) {
        
        _previousService = _selectedService;
        [self resetPhotos];
        [self searchPhotosWithKeyword:keyword];
    }
}

/*
 * Triggers a photo search of the selected photo service.
 * Each photo service API requieres different params.
 */
- (void)searchPhotosWithKeyword:(NSString *)keyword
{
    [self setActivityIndicatorsVisible:YES];
    [self setEmptyDataSetVisible:NO];
    
    _searchBar.text = keyword;

    [self.selectedServiceClient searchPhotosWithKeyword:keyword
                                                   page:_currentPage
                                          resultPerPage:self.resultPerPage
                                             completion:^(NSArray *list, NSError *error) {
                                                 if (error) [self setLoadingError:error];
                                                 else [self setPhotoSearchList:list];
                                             }];
}

/*
 * Stops the loading search request of the selected photo service.
 */
- (void)stopLoadingRequest
{
    if (self.loading) {
        
        [self setActivityIndicatorsVisible:NO];
        [self.selectedServiceClient cancelRequest];
    }
}

/*
 * Triggers a photo search for the next page.
 */
- (void)downloadData
{
    _loadButton.enabled = NO;
    
    _currentPage++;
    [self searchPhotosWithKeyword:_searchBar.text];
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _metadataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoDisplayViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDZNPhotoCellViewIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    if (_metadataList.count > 0) {
        DZNPhotoMetadata *metadata = [_metadataList objectAtIndex:indexPath.row];
        [cell setThumbURL:metadata.thumbURL];
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDZNPhotoFooterViewIdentifier forIndexPath:indexPath];
        
        if ([self canDisplayFooterView]) {
            
            if (!_loadButton && footer.subviews.count == 0) {
                [footer addSubview:self.loadButton];
            }
            
            _loadButton.frame = footer.bounds;
            
            if (_metadataList.count > 0 && !self.loading) {
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
            [_loadButton removeFromSuperview];
            _loadButton = nil;
            
            [_activityIndicator stopAnimating];
            [_activityIndicator removeFromSuperview];
            _activityIndicator = nil;
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
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
        [self performSelector:@selector(selectedItemAtIndexPath:) withObject:indexPath afterDelay:0.3];
    }
    else [self selectedItemAtIndexPath:indexPath];
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
    if (_metadataList.count == 0) {
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
    return _tagList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDZNTagCellViewIdentifier];
    
    DZNPhotoTag *tag = [_tagList objectAtIndex:indexPath.row];
    
    if (_tagList.count == 1) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search for \"%@\"", nil), tag.term];
    }
    else {
        cell.textLabel.text = tag.term;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kDZNPhotoDisplayMinimumBarHeight;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoTag *tag = [_tagList objectAtIndex:indexPath.row];
    
    [self shouldSearchPhotos:tag.term];
    [self.searchDisplayController setActive:NO animated:YES];
    [self setSearchBarText:tag.term];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UISearchDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self stopLoadingRequest];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self stopLoadingRequest];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [_tagList removeAllObjects];
}

- (void)searchBarShouldShift:(BOOL)shift
{
    [self searchBarShouldShift:shift animated:YES];
}

- (void)searchBarShouldShift:(BOOL)shift animated:(BOOL)animated
{
    _searchBar.showsScopeBar = shift;
    NSTimeInterval duration = animated ? 0.25 : 0.0;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.searchBar setFrame:[self searchBarFrame]];
                         [self.searchDisplayController setActive:shift];
                     }
                     completion:NULL];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *text = searchBar.text;
    
    [self shouldSearchPhotos:text];
    [self searchBarShouldShift:NO];
    [self setSearchBarText:text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSString *text = searchBar.text;
    
    [self searchBarShouldShift:NO];
    [self setSearchBarText:text];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSString *name = [searchBar.scopeButtonTitles objectAtIndex:selectedScope];
    _selectedService = DZNPhotoServiceFromName(name);
}


#pragma mark - UISearchDisplayDelegate methods

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
    
    [_tagList removeAllObjects];
    [controller.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{

}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{

}

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
    UITableView *tableView = [self.searchDisplayController searchResultsTableView];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _metadataList = nil;
    _tagList = nil;
    
    _searchBar = nil;
    _searchController = nil;
    _loadButton = nil;
    _activityIndicator = nil;
    _segmentedControlTitles = nil;
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

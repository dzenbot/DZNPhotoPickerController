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
#import "DZNPhotoCollectionViewLayout.h"
#import "DZNPhotoPickerController.h"
#import "DZNPhotoDisplayViewCell.h"

#import "DZNPhotoServiceFactory.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+EmptyDataSet.h"

static NSString *kDZNPhotoCellViewIdentifier = @"com.dzn.photoCellViewIdentifier";
static NSString *kDZNTagCellViewIdentifier = @"com.dzn.tagCellViewIdentifier";
static NSString *kDZNSupplementaryViewIdentifier = @"com.dzn.supplementaryViewIdentifier";

static CGFloat kDZNPhotoDisplayMinimumBarHeight = 44.0;
static NSUInteger kDZNPhotoDisplayMinimumColumnCount = 4.0;

@interface DZNPhotoDisplayViewController () <UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate,
                                                UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating,
                                                DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, readonly) UISearchController *searchController;
@property (nonatomic, readonly) UIButton *loadButton;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableArray *metadataList;
@property (nonatomic, strong) NSMutableArray *tagList;
@property (nonatomic, strong) NSArray *segmentedControlTitles;
@property (nonatomic) DZNPhotoPickerControllerServices selectedService;
@property (nonatomic) DZNPhotoPickerControllerServices previousService;
@property (nonatomic) NSInteger resultPerPage;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, readonly) NSTimer *searchTimer;

@end

@implementation DZNPhotoDisplayViewController
@synthesize searchController = _searchController;
@synthesize loadButton = _loadButton;
@synthesize activityIndicator = _activityIndicator;
@synthesize searchTimer = _searchTimer;


#pragma mark - Initialization

- (instancetype)initWithPreferredContentSize:(CGSize)size
{
    self = [super initWithCollectionViewLayout:[DZNPhotoDisplayViewController layoutFittingSize:size]];
    if (self) {
        [self commontInit];
    }
    return self;
}

- (void)commontInit
{
    self.title = NSLocalizedString(@"Internet Photos", nil);
    self.currentPage = 1;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    _segmentedControlTitles = NSArrayFromServices(self.navigationController.supportedServices);
    NSAssert((_segmentedControlTitles.count < 4), @"DZNPhotoPickerController doesn't support more than 4 photo service providers");
    
    _selectedService = DZNFirstPhotoServiceFromPhotoServices(self.navigationController.supportedServices);
    NSAssert((_selectedService > 0), @"DZNPhotoPickerController requieres at least 1 supported photo service provider");
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.definesPresentationContext = YES;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    
    [self.collectionView registerClass:[DZNPhotoDisplayViewCell class] forCellWithReuseIdentifier:kDZNPhotoCellViewIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDZNSupplementaryViewIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kDZNSupplementaryViewIdentifier];

    
//    [self.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDZNTagCellViewIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_metadataList) {

        if (self.searchBar.text.length > 0) {
            [self searchPhotosWithKeyword:self.searchBar.text];
        }
        else {
            [self.searchController setActive:YES];
            [self.searchBar becomeFirstResponder];
        }
    }
}


#pragma mark - Getter methods

/* Returns the custom collection view layout. */
+ (UICollectionViewFlowLayout *)layoutFittingSize:(CGSize)size
{
    NSUInteger columnCount = kDZNPhotoDisplayMinimumColumnCount;
    CGFloat lineSpacing = 2.0;
    
    DZNPhotoCollectionViewLayout *layout = [DZNPhotoCollectionViewLayout layoutFittingWidth:size.width columnCount:columnCount];
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = lineSpacing;
    
    CGFloat itemWidth = (size.width - (layout.minimumInteritemSpacing * (columnCount-1))) / columnCount;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    CGSize referenceSize = CGSizeMake(size.width, kDZNPhotoDisplayMinimumBarHeight);
    layout.footerReferenceSize = referenceSize;
    
    referenceSize.height += layout.minimumLineSpacing;
    layout.headerReferenceSize = referenceSize;
    
    return layout;
}

/*  Returns the selected service client. */
- (id<DZNPhotoServiceClientProtocol>)selectedServiceClient
{
    return [[DZNPhotoServiceFactory defaultFactory] clientForService:self.selectedService];
}

/* Returns the navigation controller casted to DZNPhotoPickerController. */
- (DZNPhotoPickerController *)navigationController
{
    return (DZNPhotoPickerController *)[super navigationController];
}

/*  Returns the custom search display controller. */
- (UISearchController *)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.dimsBackgroundDuringPresentation = YES;
        _searchController.hidesNavigationBarDuringPresentation = YES;

        UISearchBar *searchBar = _searchController.searchBar;
        searchBar.placeholder = NSLocalizedString(@"Search", nil);
        searchBar.text = self.navigationController.initialSearchTerm;
        searchBar.scopeButtonTitles = [self segmentedControlTitles];
        searchBar.selectedScopeButtonIndex = 0;
        searchBar.clipsToBounds = NO;
        searchBar.delegate = self;

//        _searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
//        _searchController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
//        _searchController.searchResultsTableView.tableHeaderView = [UIView new];
//        _searchController.searchResultsTableView.tableFooterView = [UIView new];
//        _searchController.searchResultsTableView.backgroundView = [UIView new];
//        _searchController.searchResultsTableView.backgroundView.backgroundColor = [UIColor whiteColor];
//        _searchController.searchResultsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
//        _searchController.searchResultsDataSource = self;
//        _searchController.searchResultsDelegate = self;
//        _searchController.delegate = self;
    }
    return _searchController;
}

- (UISearchBar *)searchBar
{
    return self.searchController.searchBar;
}

- (UITableView *)searchResultsTableView
{
    return [(UITableViewController *)self.searchController.searchResultsController tableView];
}

- (UIButton *)loadButton
{
    if (!_loadButton) {
        _loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _loadButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadButton setTitle:NSLocalizedString(@"Load More", nil) forState:UIControlStateNormal];
        [_loadButton addTarget:self action:@selector(loadMorePhotos:) forControlEvents:UIControlEventTouchUpInside];
        [_loadButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_loadButton setBackgroundColor:self.collectionView.backgroundView.backgroundColor];
    }
    return _loadButton;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicator.color = [UIColor grayColor];
    }
    return _activityIndicator;
}

/* Returns the appropriate cell view's size. */
- (CGSize)cellSize
{
    DZNPhotoCollectionViewLayout *layout = (DZNPhotoCollectionViewLayout *)self.collectionView.collectionViewLayout;
    return layout.itemSize;
}

/* Returns the appropriate header and footer view's size. */
- (CGSize)supplementaryViewSize
{
    DZNPhotoCollectionViewLayout *layout = (DZNPhotoCollectionViewLayout *)self.collectionView.collectionViewLayout;
    return layout.headerReferenceSize;
}

/* Returns the collectionView's content size. */
- (CGSize)topBarsSize
{
    CGFloat topBarsHeight = 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGFloat statusHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        topBarsHeight += statusHeight;
    }
    
    topBarsHeight += CGRectGetHeight(self.navigationController.navigationBar.frame);
    topBarsHeight += self.searchBar.frame.size.height;
    
    return CGSizeMake(self.navigationController.view.frame.size.width, topBarsHeight);
}

/* The collectionView's content size calculation. */
- (CGSize)contentSize
{
    CGSize size = self.navigationController.view.frame.size;
    size.height -= [self topBarsSize].height;
    return size;
}

/* The search bar appropriate rectangle. */
- (CGRect)searchBarFrame
{
    BOOL shouldShift = self.searchBar.showsScopeBar;
    
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
 Calculates the available row count based on the collectionView's content size and the cell height.
 This allows to easily modify the collectionView layout, for displaying the image thumbs.
 */
- (NSUInteger)rowCount
{
    CGFloat supplementaryViewHeight = [self supplementaryViewSize].height;
    
    CGSize contentSize = [self contentSize];
    contentSize.height -= supplementaryViewHeight;
    contentSize.height += self.navigationController.navigationBar.frame.size.height;
    
    CGFloat cellHeight = [self cellSize].height;
    
    NSInteger count = (int)(contentSize.height/cellHeight);
    
    if (self.selectedServiceClient.service == DZNPhotoPickerControllerServiceGoogleImages &&
        self.selectedServiceClient.subscription == DZNPhotoPickerControllerSubscriptionFree) {
        count = count/2;
    }
    
    return count;
}

/* Returns the appropriate number of result per page. */
- (NSInteger)resultPerPage
{
    return self.rowCount * kDZNPhotoDisplayMinimumColumnCount;
}

/* Checks if the search string is long enough to perfom a tag search. */
- (BOOL)canSearchTag:(NSString *)term
{
    if (!self.navigationController.allowAutoCompletedSearch) {
        return NO;
    }
    
    if ([self.searchBar isFirstResponder] && term.length > 2) {
        
        [self resetSearchTimer];
        
        _searchTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(searchTag:) userInfo:@{@"term": term} repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_searchTimer forMode:NSDefaultRunLoopMode];
        
        return YES;
    }
    else {
        [_tagList removeAllObjects];
        [self.searchResultsTableView reloadData];
        return NO;
    }
}

/* Checks if an additional footer view for loading more content should be displayed. */
- (BOOL)canDisplayFooterView
{
    if (self.metadataList.count > 0) {
        if (self.metadataList.count%self.resultPerPage == 0 || self.loading) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Setter methods

/* Sets the search bar text, specially when the UISearchDisplayController when dimissing removes the bar's text by default. */
- (void)setSearchBarText:(NSString *)text
{
    self.searchBar.text = text;
}

/* Sets the current photo search response and refreshs the collection view. */
- (void)setPhotoSearchList:(NSArray *)list
{
    [self setActivityIndicatorsVisible:NO];
    
    if (!_metadataList) _metadataList = [NSMutableArray new];
    
    [_metadataList addObjectsFromArray:list];
    
    [self.collectionView reloadData];
}

/* Sets a tag search response and refreshs the results tableview from the UISearchDisplayController. */
- (void)setTagSearchList:(NSArray *)list
{
    if (!_tagList) _tagList = [NSMutableArray new];
    else [_tagList removeAllObjects];
    
    [_tagList addObjectsFromArray:list];
    
    if (_tagList.count == 1) {
        [_tagList removeAllObjects];
        
        DZNPhotoTag *tag = [DZNPhotoTag newTagWithTerm:self.searchBar.text service:_selectedService];
        [_tagList addObject:tag];
    }
    
    [self.searchResultsTableView reloadData];
}

/* Toggles the activity indicators on the status bar & footer view. */
- (void)setActivityIndicatorsVisible:(BOOL)visible
{
    if (visible) {
        [self.activityIndicator startAnimating];
        self.loadButton.hidden = YES;
    }
    else {
        [self.activityIndicator stopAnimating];
        self.loadButton.hidden = NO;
        self.loadButton.enabled = YES;
    }
    
    _loading = visible;
}

/* Sets the request errors with an alert view. */
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

/* Invalidates and nullifys the search timer. */
- (void)resetSearchTimer
{
    if (_searchTimer) {
        [_searchTimer invalidate];
        _searchTimer = nil;
    }
}

/* Removes all photo metadata from the array and cleans the collection view from photo thumbnails. */
- (void)resetPhotos
{
    [_metadataList removeAllObjects];
    self.currentPage = 1;
    
    [self.collectionView reloadData];
}


#pragma mark - DZNPhotoDisplayController methods

/*
 Handles the thumbnail selection.
 
 Depending on configuration, the selection might result in one of the following action:
 - Return only the photo metadata and dismiss the controller
 - Push into the edit controller for cropping
 - Download the full size photo and dismiss the controller
 */
- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoMetadata *metadata = [_metadataList objectAtIndex:indexPath.row];
    
    if (!self.navigationController.enablePhotoDownload) {
        [metadata postMetadataUpdate:nil];
    }
    else if (self.navigationController.allowsEditing) {
        
        DZNPhotoEditorViewController *controller = [[DZNPhotoEditorViewController alloc] init];
        controller.cropMode = self.navigationController.cropMode;
        controller.cropSize = self.navigationController.cropSize;
        
        [self.navigationController pushViewController:controller animated:YES];

        [controller setAcceptBlock:^(DZNPhotoEditorViewController *editor, NSDictionary *userInfo){
            [metadata postMetadataUpdate:userInfo];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [controller setCancelBlock:^(DZNPhotoEditorViewController *editor){
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        controller.rightButton.enabled = NO;
        [controller.activityIndicator startAnimating];
        
        __weak DZNPhotoEditorViewController *weakController = controller;
        
        [controller.imageView sd_setImageWithPreviousCachedImageWithURL:metadata.sourceURL
                                              andPlaceholderImage:nil
                                                          options:SDWebImageCacheMemoryOnly|SDWebImageProgressiveDownload|SDWebImageRetryFailed
                                                         progress:NULL
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            if (!error) {
                                                                weakController.rightButton.enabled = YES;
                                                            }
                                                            else {
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:DZNPhotoPickerDidFailPickingNotification object:nil userInfo:@{@"error": error}];
                                                            }
                                                            
                                                            [weakController.activityIndicator stopAnimating];
                                                        }];
    }
    else {
        [self setActivityIndicatorsVisible:YES];
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:metadata.sourceURL
                                                              options:SDWebImageCacheMemoryOnly|SDWebImageRetryFailed
                                                             progress:NULL
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                                if (image) {
                                                                    
                                                                    NSDictionary *userInfo = @{UIImagePickerControllerOriginalImage: image};
                                                                    [metadata postMetadataUpdate:userInfo];
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
 Triggers a tag search when typing more than 2 characters in the search bar.
 This allows auto-completion and related tags to what the user wants to search.
 */
- (void)searchTag:(NSTimer *)timer
{
    NSString *term = [timer.userInfo objectForKey:@"term"];
    [self resetSearchTimer];
    
    id <DZNPhotoServiceClientProtocol> client = [[DZNPhotoServiceFactory defaultFactory] clientForService:DZNPhotoPickerControllerServiceFlickr];
    
    if (!client) {
        return;
    }
    
    [client searchTagsWithKeyword:term
                       completion:^(NSArray *list, NSError *error) {
                           if (error) [self setLoadingError:error];
                           else [self setTagSearchList:list];
                       }];
}

/* Checks if the search string is valid and conditions are ok, for performing a photo search. */
- (void)shouldSearchPhotos:(NSString *)keyword
{
    if (self.previousService == self.selectedService) {
        return;
    }
    
    if ([self.searchBar.text isEqualToString:keyword] || keyword.length <= 1) {
        return;
    }
    
    self.previousService = self.selectedService;
    
    [self resetPhotos];
    [self searchPhotosWithKeyword:keyword];
}

/*
 Triggers a photo search of the selected photo service.
 Each photo service API requieres different params.
 */
- (void)searchPhotosWithKeyword:(NSString *)keyword
{
    [self setActivityIndicatorsVisible:YES];
    [self.collectionView reloadData];
    
    self.searchBar.text = keyword;

    [self.selectedServiceClient searchPhotosWithKeyword:keyword
                                                   page:self.currentPage
                                          resultPerPage:self.resultPerPage
                                             completion:^(NSArray *list, NSError *error) {
                                                 if (error) [self setLoadingError:error];
                                                 else [self setPhotoSearchList:list];
                                             }];
}

/* Stops the loading search request of the selected photo service. */
- (void)stopLoadingRequest
{
    if (self.loading) {
        [self setActivityIndicatorsVisible:NO];
        [self.selectedServiceClient cancelRequest];
    }
}

/* Triggers a photo search for the next page. */
- (void)loadMorePhotos:(UIButton *)sender
{
    sender.enabled = NO;
    
    self.currentPage++;
    [self searchPhotosWithKeyword:self.searchBar.text];
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
    UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDZNSupplementaryViewIdentifier forIndexPath:indexPath];
    
    [[supplementaryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [supplementaryView removeConstraints:supplementaryView.constraints];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        supplementaryView.clipsToBounds = NO;
        
        if (supplementaryView.subviews.count == 0) {
            [supplementaryView addSubview:self.searchBar];
        }
    }
    else if ([self canDisplayFooterView]) {
        
        UIView *subview = nil;
        
        if (self.isLoading) {
            subview = self.activityIndicator;
        }
        else {
            subview = self.loadButton;
        }
        
        if (subview && !subview.superview) {
            [supplementaryView addSubview:subview];
            
            NSDictionary *views = @{@"subview": subview};
            
            [supplementaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
            [supplementaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
            
            [supplementaryView addConstraint:[NSLayoutConstraint constraintWithItem:supplementaryView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:subview
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            
            [supplementaryView addConstraint:[NSLayoutConstraint constraintWithItem:supplementaryView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:subview
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0.0]];
        }
    }
    return supplementaryView;
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
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoDisplayViewCell *cell = (DZNPhotoDisplayViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.imageView.image) {
        return YES;
    }
    return NO;
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
    NSString *text = @"";
    
    if (indexPath.row < _tagList.count) {
        
        DZNPhotoTag *tag = [_tagList objectAtIndex:indexPath.row];
        
        if (_tagList.count == 1) text = [NSString stringWithFormat:NSLocalizedString(@"Search for \"%@\"", nil), tag.term];
        else text = tag.term;
    }
    
    cell.textLabel.text = text;
    
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
    [self.searchController setActive:NO];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *text = searchBar.text;
    
    [self shouldSearchPhotos:text];
    [self setSearchBarText:text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSString *text = searchBar.text;
    
    [self setSearchBarText:text];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSString *name = [searchBar.scopeButtonTitles objectAtIndex:selectedScope];
    _selectedService = DZNPhotoServiceFromName(name);
}


#pragma mark - UISearchResultsUpdating methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *term = self.searchBar.text;
    
    [self canSearchTag:term];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController
{
    
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    // do something after the search controller is dismissed
}


#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if (!self.loading) {
        NSString *text = NSLocalizedString(@"No Photos Found", nil);
        return [[NSAttributedString alloc] initWithString:text attributes:nil];
    }
    
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (!self.loading) {
        NSString *text = NSLocalizedString(@"Make sure that all words are\nspelled correctly.", nil);
        return [[NSAttributedString alloc] initWithString:text attributes:nil];
    }
    
    return nil;
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.loading) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView startAnimating];
        return activityIndicatorView;
    }
    
    return nil;
}


#pragma mark - DZNEmptyDataSetDelegate Methods

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
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


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _metadataList = nil;
    _tagList = nil;
    
    _searchController = nil;
    _loadButton = nil;
    _activityIndicator = nil;
    _segmentedControlTitles = nil;
    
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
    self.collectionView.emptyDataSetSource = nil;
    self.collectionView.emptyDataSetDelegate = nil;
}

@end

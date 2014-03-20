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

#import "DZNPhotoDisplayViewCell.h"
#import "DZNPhotoMetadata.h"
#import "DZNPhotoTag.h"

#import "DZNPhotoServiceFactory.h"

#define  kDZNPhotoMinimumBarHeight 44.0

static NSString *kThumbCellID = @"kThumbCellID";
static NSString *kThumbFooterID = @"kThumbFooterID";
static NSString *kTagCellID = @"kTagCellID";

@interface DZNPhotoDisplayViewController () <UISearchDisplayDelegate, UISearchBarDelegate,
                                            UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, readwrite) UIButton *loadButton;
@property (nonatomic, readwrite) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableArray *photoMetadatas;
@property (nonatomic, strong) NSMutableArray *photoTags;
@property (nonatomic, strong) NSArray *segmentedControlTitles;
@property (nonatomic) DZNPhotoPickerControllerService selectedService;
@property (nonatomic) DZNPhotoPickerControllerService previousService;
@property (nonatomic) NSInteger resultPerPage;
@property (nonatomic) NSInteger currentPage;

@end

@implementation DZNPhotoDisplayViewController

- (instancetype)init
{
    return [self initWithCollectionViewLayout:[DZNPhotoDisplayViewController flowLayout]];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = NSLocalizedString(@"Internet Photos", nil);
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    _currentPage = 1;
    _columnCount = 4;
    
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
    
    [self.collectionView registerClass:[DZNPhotoDisplayViewCell class] forCellWithReuseIdentifier:kThumbCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kThumbFooterID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_photoMetadatas) {
        _photoMetadatas = [NSMutableArray new];

        if (_searchTerm.length == 0) {
            [self.searchController setActive:YES];
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
        _searchBar.selectedScopeButtonIndex = 0;
        
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
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width,  kDZNPhotoMinimumBarHeight);
    frame.size.height = shouldShift ?  kDZNPhotoMinimumBarHeight*2 :  kDZNPhotoMinimumBarHeight;
    frame.origin.y = shouldShift ? statusHeight : 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !shouldShift) {
        frame.origin.y += statusHeight+ kDZNPhotoMinimumBarHeight;
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
    
    id <DZNPhotoServiceClientProtocol> client =  [[DZNPhotoServiceFactory defaultFactory] clientForService:_selectedService];
    if (client.service == DZNPhotoPickerControllerServiceGoogleImages &&
        client.subscription == DZNPhotoPickerControllerSubscriptionFree) {
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
 * Checks if an additional footer for loading more content should be displayed.
 */
- (BOOL)shouldShowFooter
{
    if (_photoMetadatas.count > 0) {
        return (_photoMetadatas.count%self.resultPerPage == 0) ? YES : NO;
    }
    return NO;
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
- (void)setPhotoSearchList:(NSArray *)list
{
    [self showActivityIndicators:NO];
    
    [_photoMetadatas addObjectsFromArray:list];
    [self.collectionView reloadData];
    
    CGSize contentSize = self.collectionView.contentSize;
    self.collectionView.contentSize = CGSizeMake(contentSize.width, contentSize.height+[self footerSize].height);
}

/*
 * Sets a tag search response and refreshs the results tableview from the UISearchDisplayController.
 */
- (void)setTagSearchList:(NSArray *)list
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!_photoTags) _photoTags = [NSMutableArray new];
    else [_photoTags removeAllObjects];
    
    [_photoTags addObjectsFromArray:list];
    
    if (_photoTags.count < 2) {
        [_photoTags removeAllObjects];
        
        DZNPhotoTag *tag = [DZNPhotoTag photoTagFromService:_selectedService];
        tag.text = _searchBar.text;
        [_photoTags addObject:tag];
    }
    
    [_searchController.searchResultsTableView reloadData];
}

/*
 * Sets the request errors with an alert view.
 */
- (void)setSearchError:(NSError *)error
{
    [self showActivityIndicators:NO];
    
    if (error.code == NSURLErrorCancelled || error.code == NSURLErrorUnknown) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
    
    NSLog(@"error : %@", error);
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
    DZNPhotoMetadata *metadata = [_photoMetadatas objectAtIndex:indexPath.row];
    
    if (self.navigationController.allowsEditing) {
        
        DZNPhotoEditViewController *photoEditViewController = [[DZNPhotoEditViewController alloc] initWithPhotoMetadata:metadata cropMode:self.navigationController.editingMode];
        [self.navigationController pushViewController:photoEditViewController animated:YES];
    }
    else if (!self.navigationController.enablePhotoDownload) {
        
        [DZNPhotoEditViewController didFinishPickingOriginalImage:nil
                                                      editedImage:nil
                                                         cropRect:CGRectZero
                                                         cropMode:DZNPhotoEditViewControllerCropModeNone
                                                    photoMetadata:metadata];
    }
    else {
        
        [self showActivityIndicators:YES];

        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:metadata.sourceURL
                                                              options:SDWebImageCacheMemoryOnly|SDWebImageRetryFailed
                                                             progress:NULL
                                             completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                 
                                                 if (image) {
                                                     [DZNPhotoEditViewController didFinishPickingOriginalImage:image editedImage:nil
                                                                                                      cropRect:CGRectZero
                                                                                                      cropMode:DZNPhotoEditViewControllerCropModeNone
                                                                                                 photoMetadata:metadata];
                
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
- (BOOL)canSearchTag:(NSString *)term
{
    if ([_searchController.searchBar isFirstResponder] && term.length > 2) {
        [self searchTags:term];
        return YES;
    }
    else {
        [_photoTags removeAllObjects];
        [_searchController.searchResultsTableView reloadData];
        return NO;
    }
}

/*
 * Triggers a tag search when typing more than 2 characters in the search bar.
 * This allows auto-completion and related tags to what the user wants to search.
 */
- (void)searchTags:(NSString *)keyword
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    id <DZNPhotoServiceClientProtocol> client =  [[DZNPhotoServiceFactory defaultFactory] clientForService:DZNPhotoPickerControllerServiceFlickr];
    
    [client searchTagsWithKeyword:keyword completion:^(NSArray *list, NSError *error) {
        if (error) [self setSearchError:error];
        else [self setTagSearchList:list];
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
}

/*
 * Triggers a photo search of the selected photo service.
 * Each photo service API requieres different params.
 */
- (void)searchPhotosWithKeyword:(NSString *)keyword
{
    [self showActivityIndicators:YES];
    _searchTerm = keyword;

    id <DZNPhotoServiceClientProtocol> client =  [[DZNPhotoServiceFactory defaultFactory] clientForService:_selectedService];
    
    [client searchPhotosWithKeyword:keyword page:_currentPage resultPerPage:self.resultPerPage completion:^(NSArray *list, NSError *error) {
        if (error) [self setSearchError:error];
        else [self setPhotoSearchList:list];
    }];
}

/*
 * Stops the loading search request of the selected photo service.
 */
- (void)stopLoadingRequest
{
    if (self.loading) {
        
        [self showActivityIndicators:NO];
        
        id <DZNPhotoServiceClientProtocol> client =  [[DZNPhotoServiceFactory defaultFactory] clientForService:_selectedService];
        [client cancelRequest];
    }
    
//    for (DZNPhotoDisplayViewCell *cell in [self.collectionView visibleCells]) {
//        [cell.imageView cancelCurrentImageLoad];
//    }
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
 * Removes all photo metadata from the array and cleans the collection view from photo thumbnails.
 */
- (void)resetPhotos
{
    [_photoMetadatas removeAllObjects];
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
    return _photoMetadatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoDisplayViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kThumbCellID forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    DZNPhotoMetadata *metadata = [_photoMetadatas objectAtIndex:indexPath.row];
    
    [cell.imageView cancelCurrentImageLoad];
    
    [cell.imageView setImageWithURL:metadata.thumbURL placeholderImage:nil
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
            
            if (_photoMetadatas.count > 0) {
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
    if (_photoMetadatas.count == 0) {
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
    return _photoTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTagCellID];
    
    DZNPhotoTag *tag = [_photoTags objectAtIndex:indexPath.row];
    
    if (_photoTags.count == 1) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search for \"%@\"", nil), tag.text];
    }
    else {
        cell.textLabel.text = tag.text;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kDZNPhotoMinimumBarHeight;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DZNPhotoTag *tag = [_photoTags objectAtIndex:indexPath.row];
    
    [self shouldSearchPhotos:tag.text];
    [self.searchController setActive:NO animated:YES];
    [self setSearchBarText:tag.text];
    
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
    [_photoTags removeAllObjects];
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
    
    [_photoTags removeAllObjects];
    [controller.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
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
    UITableView *tableView = [self.searchController searchResultsTableView];
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

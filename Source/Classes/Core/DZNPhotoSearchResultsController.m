//
//  DZNPhotoSearchResultsController.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoSearchResultsController.h"
#import "DZNPhotoTag.h"

#import "UIScrollView+EmptyDataSet.h"

static NSString *kDZNTagCellViewIdentifier = @"com.dzn.tagCellViewIdentifier";

@interface DZNPhotoSearchResultsController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, strong) NSMutableArray *searchResult;
@end

@implementation DZNPhotoSearchResultsController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDZNTagCellViewIdentifier];
}


#pragma mark - Getters methods

- (DZNPhotoTag *)tagAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = indexPath.row;
    
    if (idx < self.searchResult.count) {
        return self.searchResult[idx];
    }
    return nil;
}


#pragma mark - Setters methods

- (void)setSearchResults:(NSArray *)result
{
    if (!_searchResult) _searchResult = [NSMutableArray new];
    else [_searchResult removeAllObjects];
    
    if (result.count > 0) {
        [_searchResult addObjectsFromArray:result];
    }
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDZNTagCellViewIdentifier];
    NSString *text = @"";
    
    if (indexPath.row < self.searchResult.count) {
        
        DZNPhotoTag *tag = [self tagAtIndexPath:indexPath];

        if (self.searchResult.count == 1) text = [NSString stringWithFormat:NSLocalizedString(@"Search for \"%@\"", nil), tag.term];
        else text = tag.term;
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  40.0;
}


#pragma mark - Lifeterm

- (void)dealloc
{
    self.tableView.emptyDataSetDelegate = nil;
    self.tableView.emptyDataSetSource = nil;
}

@end

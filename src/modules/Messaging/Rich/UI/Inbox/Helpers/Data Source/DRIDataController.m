//
//  DRIDataController.m
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRIDataController.h"
#import "DNSystemHelpers.h"
#import "DNLoggingController.h"
#import "DNNetworkController.h"
#import "DNDonkyCore.h"
#import "DRConstants.h"
#import "DRUIThemeConstants.h"
#import "DNDataController.h"
#import "NSManagedObject+DNHelper.h"
#import "DNAssetController.h"
#import "DRIDataControllerHelper.h"
#import "DRLFetchedResultsController.h"

static NSString *const DRICellIdentifier = @"RichInboxCellIdentifier";

@interface DRIDataController ()
@property(nonatomic, strong) DRLFetchedResultsController *richLogicFetchedResultsController;
@property(nonatomic, strong) NSIndexPath *originalIndexPath;
@property(nonatomic, strong) NSMutableArray *openedCells;
@property(nonatomic, getter=wasUpdated) BOOL updated;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) DRUITheme *theme;
@end

@implementation DRIDataController

- (instancetype)initWithTableView:(UITableView *)tableView theme:(DRUITheme *)theme {

    self = [super init];

    if (self) {

        [self setTableView:tableView];

        [self setTheme:theme];

        [self createLocalEventHandlers];

        [self setDrLogicMainController:[[DRLogicMainController alloc] init]];
        
        [self setRichLogicFetchedResultsController:[[DRLFetchedResultsController alloc] initWithTableView:tableView]];
        [[self richLogicFetchedResultsController] setDelegate:self];

    }

    return self;
}

#pragma mark -
#pragma mark - Search Methods:

- (void)searchTableView:(NSString *)searchString {

    [self closeAllCells];

    if (searchString.length) {
        [[self richLogicFetchedResultsController] setFetchedResultsController:nil];
        [[self richLogicFetchedResultsController] setSearching:YES];
        [[self richLogicFetchedResultsController]  setSearchString:searchString];
        [[self tableView] reloadData];
    }
    else {
        [self resetSearch];
    }
}

- (void)resetSearch {
    [[self richLogicFetchedResultsController] setFetchedResultsController:nil];
    [[self richLogicFetchedResultsController] setSearching:NO];
    [[self richLogicFetchedResultsController] setSearchString:nil];
    [[self tableView] reloadData];

    if ([self richMessageCount] > 0 && ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape])) {
        DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:[self originalIndexPath]];
        [self toggleSelectedCell:cell];
    }
}

#pragma mark -
#pragma mark - Public Methods

- (void)checkForNewRichMessages {
    [self closeAllCells];
    [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
        if ([[self delegate] respondsToSelector:@selector(endRefreshingWithSuccess:)]) {
            [[self delegate] endRefreshingWithSuccess:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([[self delegate] respondsToSelector:@selector(endRefreshingWithSuccess:)]) {
            [[self delegate] endRefreshingWithSuccess:NO];
        }
    }];
}

- (void)createLocalEventHandlers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)preferredContentSizeChanged:(id)sender {
    [[self tableView] reloadData];
}

- (void)removeLocalEventHandlers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (NSInteger)richMessageCount {
    return [[[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects] count];
}

- (void)deleteAllSelectedMessages {
    //Remove any cached images:
    __block NSMutableArray *selectedMessages = [[NSMutableArray alloc] init];
    [[[self tableView] indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *message = [[[self richLogicFetchedResultsController] fetchedResultsController] objectAtIndexPath:obj];
        [DNAssetController deleteImageAtTempDir:[message messageID]];
        [selectedMessages addObject:message];
    }];

    [[self drLogicMainController] deleteAllMessages:selectedMessages];

    //We exit the edit mode:
    if ([[self delegate] respondsToSelector:@selector(toggleEditMode)]) {
        [[self delegate] performSelector:@selector(toggleEditMode)];
    }

    [[self tableView] setScrollEnabled:YES];
}

- (void)deleteAllExpiredMessages {
    [[self drLogicMainController] deleteAllExpiredMessages];
    [self updateSelectedIndex:[self originalIndexPath]];
}

- (BOOL)toggleAllSelectedMessages {

    BOOL allSelected =  [[self tableView].indexPathsForSelectedRows count] > 0;

        //We deselect rows:
    [[[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:indexPath];
        if (!allSelected) {
            [[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [cell setSelected:YES];
        }
        else {
            [[self tableView] deselectRowAtIndexPath:indexPath animated:NO];
            [cell setSelected:NO];
        }
    }];

    return !allSelected;
}

- (void)enterEditMode:(BOOL)enterEditMode {

    [self closeAllCells];

    [[[self tableView] indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:obj];
        [cell setSelected:NO];
        [[self tableView] deselectRowAtIndexPath:obj animated:NO];
    }];

    [[[self tableView] visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DRITableViewCell *cell = obj;
        [cell setTableViewEditing:enterEditMode];
        [cell resetLayouts];
    }];

    if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {
        if (!enterEditMode) {
            DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:[self originalIndexPath]];
            if (cell) {
                [cell setSelected:YES];
                [self toggleSelectedCell:cell];
            }
            else {
                [[self tableView] selectRowAtIndexPath:[self originalIndexPath] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else {
            [self clearSelectedIndexPath:[self originalIndexPath]];
        }
    }
}

- (void)deleteRichMessage:(DNRichMessage *)richMessage {
    NSIndexPath *deletedIndex = [[[self richLogicFetchedResultsController] fetchedResultsController] indexPathForObject:richMessage];
    [DNAssetController deleteImageAtTempDir:[richMessage messageID]];
    [[self drLogicMainController] deleteAllMessages:@[richMessage]];
    [[self tableView] setScrollEnabled:YES];
    [self closeAllCells];
    [self updateSelectedIndex:deletedIndex];
}

- (void)selectFirstRow {
    if ([[[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects] count] > 0 && ![[self tableView] indexPathForSelectedRow]) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

        DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:indexPath];

        [self toggleSelectedCell:cell];
    }
}

- (void)unselectCurrentCell {

    NSIndexPath *selectedIndexPath = [[self tableView] indexPathForSelectedRow];

    [[self tableView] deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

- (DNRichMessage *)richMessageAtRow:(NSInteger)indexPathRow {
    return [[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects][indexPathRow];
}

- (NSInteger)indexOfMessage:(DNRichMessage *)richMessage {

    return [[[self richLogicFetchedResultsController] fetchedResultsController] indexPathForObject:richMessage].row;
}

- (void)deleteMessageAtIndex:(NSInteger)index {

    DNRichMessage *message = [[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects][index];
    if (message) {
        [self deleteRichMessage:message];
    }
}

- (void)searchDidStart {
    if ([[self delegate] respondsToSelector:@selector(searchDidStart)]) {
        [[self delegate] searchDidStart];
    }
}

- (void)searchDidEnd {
    if ([[self delegate] respondsToSelector:@selector(searchDidEnd)]) {
        [[self delegate] searchDidEnd];
    }
}

- (void)hideSearchBar {
    [[self tableView] setContentOffset:CGPointMake(0, [self tableView].tableHeaderView.frame.size.height)];
}

- (NSNumber *)unreadRichMessageCount {
    return @([[[self drLogicMainController] allUnreadRichMessages] count]);
}

#pragma mark -
#pragma mark - Table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DNRichMessage *richMessage = [[[self richLogicFetchedResultsController] fetchedResultsController] objectAtIndexPath:indexPath];
    return [DRIDataControllerHelper sizeOfTableViewRowWithMessage:richMessage tableView:tableView theme:self.theme];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DNRichMessage *richMessage = [[[self richLogicFetchedResultsController] fetchedResultsController] objectAtIndexPath:indexPath];

    DRITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DRICellIdentifier forIndexPath:indexPath];

    [cell setTheme:self.theme];
    [cell setRichMessage:richMessage];
    [cell setDelegate:self];
    [cell setTableViewEditing:[tableView isEditing]];
    [cell setEditing:[tableView isEditing] animated:NO];
    [cell closeCell];

    if (([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) && ![tableView isEditing]) {
        [cell setSelected:[self originalIndexPath] == indexPath];
    }

    [cell layoutIfNeeded];
    [cell updateConstraints];
    [cell configureCell];

    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DRITableViewCell *cell = (DRITableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    if ([tableView isEditing]) {
        //We get the rich message:
        if ([[self delegate] respondsToSelector:@selector(messagesSelected:)]) {
            [[self delegate] messagesSelected:[[[self tableView] indexPathsForSelectedRows] count] > 0];
        }
    }

    [cell setSelected:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //We get the rich message:
    DNRichMessage *richMessage = [[[self richLogicFetchedResultsController] fetchedResultsController]objectAtIndexPath:indexPath];

    [self handleRowSelectedState:indexPath richMessage:richMessage];

    if ([tableView isEditing]) {
        return;
    }

    if (richMessage) {
        if ([[self delegate] respondsToSelector:@selector(richInboxMessageSelected:)]) {
            [[self delegate] richInboxMessageSelected:richMessage];
        }
    }
    else {
        DNErrorLog(@"Error retrieving rich message, it no longer exists\nRefreshing table view...");
        [self checkForNewRichMessages];
    }
}

- (void)handleRowSelectedState:(NSIndexPath *)indexPath richMessage:(DNRichMessage *)richMessage {
   [self setOriginalIndexPath:[DRIDataControllerHelper handleRowSelectedState:indexPath 
                                                                  richMessage:richMessage
                                                                    tableView:[self tableView] 
                                                             selectedMessages:[[self tableView] indexPathsForSelectedRows]
                                                                     delegate:[self delegate] 
                                                                   dataSource:self 
                                                           originnalIndexPath:[self originalIndexPath]]];
}

- (void)cell:(DRITableViewCell *)cell wasOpened:(BOOL)wasOpened {

    if (![self openedCells]) {
        [self setOpenedCells:[[NSMutableArray alloc] init]];
    }

    if (wasOpened) {
        if (![[self openedCells] containsObject:cell]) {
            [[self openedCells] addObject:cell];
        }
    }
    else {
        [[self openedCells] removeObject:cell];
    }
}

#pragma mark -
#pragma mark - Internal Methods

- (void)cellButtonWasTapped:(UIButton *)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:[self tableView]];
    CGRect senderFrame = CGRectMake(buttonPosition.x, buttonPosition.y, sender.frame.size.width, sender.frame.size.height);
    NSArray *indexPaths = [[self tableView] indexPathsForRowsInRect:senderFrame];
    if ([indexPaths count] > 0) {
        NSIndexPath *indexPath = [indexPaths firstObject];
        DNRichMessage *richMessage = [[[self richLogicFetchedResultsController] fetchedResultsController] objectAtIndexPath:indexPath];
        //Do some:
        if ([[self delegate] respondsToSelector:@selector(moreButtonTappedForRichMessage:atIndexPath:senderFrame:)]) {
            [[self delegate] moreButtonTappedForRichMessage:richMessage atIndexPath:indexPath senderFrame:senderFrame];
        }
    }
}

- (void)shouldDisableScroll:(BOOL)disable leaveCells:(DRITableViewCell *)cell {

    if (disable){
        [self closeAllCellsExcept:cell];
    }

    [[self tableView] setScrollEnabled:!disable];
}

- (void)closeAllCellsExcept:(DRITableViewCell *)cell {

    NSMutableArray *closedCells = [[NSMutableArray alloc] init];
    [[self openedCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DRITableViewCell *openCell = obj;
        if (openCell != cell) {
            [openCell closeCell];
            [closedCells addObject:openCell];
        }
    }];

    [[self openedCells] removeObjectsInArray:closedCells];

}

- (void)closeAllCells {
   [self closeAllCellsExcept:nil];
}

- (void)attemptToSelectNextRow:(NSIndexPath *)indexPath {

    if (![[[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects] count]) {
        if ([[self delegate] respondsToSelector:@selector(updateUI)]) {
            [[self delegate] updateUI];
        }
        return;
    }

    DRITableViewCell *cell = [DRIDataControllerHelper attemptToSelectNextRow:indexPath fetchedResultsController:[[self richLogicFetchedResultsController] fetchedResultsController] tableView:[self tableView]];

    if (cell && [[self tableView] indexPathForCell:cell] != [self originalIndexPath]) {
        [self toggleSelectedCell:cell];
    }
    else {
        [self clearSelectedIndexPath:indexPath];
    }
}

- (void)clearSelectedIndexPath:(NSIndexPath *)indexPath {
    DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:indexPath];
    [[self tableView] deselectRowAtIndexPath:indexPath animated:NO];
    [cell setSelected:NO];
    if (![[self tableView] isEditing]) {
        [self setOriginalIndexPath:nil];
    }
    if ([[self delegate] respondsToSelector:@selector(richInboxMessageSelected:)]) {
        [[self delegate] richInboxMessageSelected:nil];
    }
}

- (void)toggleSelectedCell:(DRITableViewCell *)cell {
    [self setOriginalIndexPath:[DRIDataControllerHelper toggleSelectedCell:cell
                                      tableView:[self tableView]
                       fetchedResultsController:[[self richLogicFetchedResultsController] fetchedResultsController]
                                     dataSource:self
                                       delegate:[self delegate]
                              originalIndexPath:[self originalIndexPath]]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![[self tableView] isEditing]) {
        [self closeAllCells];
    }
}

- (void)messageExpired:(UITableViewCell *)cell {
    if ([cell isSelected]) {
        [self clearSelectedIndexPath:[self originalIndexPath]];
    }
}

- (void)updateSelectedIndex:(NSIndexPath *) deletedCell {
    if ([[[self tableView] indexPathForSelectedRow] row] > [deletedCell row] && deletedCell) {
        NSIndexPath *newSelected = [NSIndexPath indexPathForRow:[[self originalIndexPath] row] - 1 inSection:0];
        if ([[[[self richLogicFetchedResultsController] fetchedResultsController] fetchedObjects] count] > 0) {
            [self unselectCurrentCell];

            DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:newSelected];
            [self toggleSelectedCell:cell];
        }
    }
}

#pragma mark -
#pragma mark - Fetch Results Delegates:


- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths {
    if ([[self delegate] respondsToSelector:@selector(updateUI)]) {
        [[self delegate] updateUI];
    }

    if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {
        [self setOriginalIndexPath:[NSIndexPath indexPathForRow:[[self originalIndexPath] row] + 1 inSection:0]];
    }

    if ([[self delegate] respondsToSelector:@selector(updateTabBarCount)]) {
        [[self delegate] updateTabBarCount];
    }
}

- (void)deleteRowsAtIndexPath:(NSIndexPath *)indexPath {

    if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {
        //We only do this if there was 1 delete:
        if (indexPath == [self originalIndexPath] && [[[self tableView] indexPathsForSelectedRows] count] <= 1) {
            [self attemptToSelectNextRow:indexPath];
        }
    }

    if ([[self delegate] respondsToSelector:@selector(updateTabBarCount)]) {
        [[self delegate] updateTabBarCount];
    }
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths {
    [self setUpdated:YES];

    if ([[self delegate] respondsToSelector:@selector(updateTabBarCount)]) {
        [[self delegate] updateTabBarCount];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {
        if ((([tableView indexPathForSelectedRow] == indexPath) || ![tableView indexPathForSelectedRow]) && [self wasUpdated]) {
            DRITableViewCell *originalCell = (DRITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [self toggleSelectedCell:originalCell];
            [self setUpdated:NO];
        }
    }
}

#pragma mark -
#pragma mark - Setters:

- (void)setTheme:(DRUITheme *)theme {
    if (_theme != theme) {
        _theme = theme;
        if ([[self theme] colourForKey:kDRUInboxCellSeparatorColour]) {
            [[self tableView] setSeparatorColor:[[self theme] colourForKey:kDRUInboxCellSeparatorColour]];
        }
    }
}

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        _tableView = tableView;
        [[self tableView] setAllowsMultipleSelectionDuringEditing:YES];
        [[self tableView] registerClass:[DRITableViewCell class] forCellReuseIdentifier:DRICellIdentifier];
    }
}

@end
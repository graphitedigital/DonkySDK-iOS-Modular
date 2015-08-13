//
//  DRITableViewController.m
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRITableViewController.h"
#import "UIView+AutoLayout.h"
#import "DNSystemHelpers.h"
#import "DRUIThemeConstants.h"
#import "DCUIThemeController.h"
#import "DCUILocalization+Localization.h"
#import "DRIViewHelper.h"
#import "DRichMessage+Localization.h"
#import "DNRichMessage+DNRichMessageHelper.h"
#import "DCUIActionHelper.h"
#import "DNLoggingController.h"
#import "DNDonkyCore.h"

@interface DRITableViewController ()
@property (nonatomic, strong) DRIMessageViewController *detailViewController;
@property (nonatomic, getter=isShowingOptionsView) BOOL showingOptionsView;
@property(nonatomic, strong) DRIDataController *richInboxDataController;
@property(nonatomic, strong) NSLayoutConstraint *optionsViewConstraint;
@property(nonatomic, strong) DRISearchController *searchController;
@property(nonatomic, getter=hasCloseButton) BOOL closeButton;
@property(nonatomic, strong) DRIOptionsView *optionsView;
@property(nonatomic, strong) UIView *noMessagesView;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic) UIEdgeInsets originalOffset;
@property(nonatomic, strong) DRUITheme *theme;
@property(nonatomic, strong) UIPopoverController *shareItemPopOverController;
@end

@implementation DRITableViewController

#pragma mark -
#pragma mark - Object lifecycle:

- (instancetype)initWithStyle:(UITableViewStyle)style {

    self = [super initWithStyle:style];

    if (self) {

    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
      
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    if ([self splitViewController]) {
        if ([[[[self splitViewController] viewControllers] lastObject] isKindOfClass:[UINavigationController class]]) {
            [self setDetailViewController:(DRIMessageViewController *) [[[[self splitViewController] viewControllers] lastObject] topViewController]];
        }
        else {
            [self setDetailViewController:(DRIMessageViewController *) [[[self splitViewController] viewControllers] lastObject]];
        }
        [[self detailViewController] setDelegate:self];
    }

    //Get the theme:
    [self setTheme:(DRUITheme *) [[DCUIThemeController sharedInstance] themeForName:kDRUIThemeName]];

    [[self view] setBackgroundColor:[[self theme] themeColours][kDRUIInboxCellBackgroundColour]];

    [self setExtendedLayoutIncludesOpaqueBars:NO];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [[DCUIThemeController sharedInstance] addTheme:[self theme]];

    [self setRichInboxDataController:[[DRIDataController alloc] initWithTableView:[self tableView] theme:[self theme]]];
    [[self richInboxDataController] setDelegate:self];

    [[self tableView] setDataSource:[self richInboxDataController]];
    [[self tableView] setDelegate:[self richInboxDataController]];

    [self setSearchController:[[DRISearchController alloc] initWithTableViewDataController:[self richInboxDataController]]];

    //Setup refresh control:
    [self createRefreshController];

    //Set a nil footer so we hide the separator lines:
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [[self tableView] setTableFooterView:footer];
    [[self view] setBackgroundColor:[UIColor whiteColor]];

    [self updateTableViewUI];

    //Create search bar:
    [self setSearchBar:[[UISearchBar alloc] init]];

    if ([[self theme] colourForKey:kDRUIInboxSearchTintColour]) {
        [[self searchBar] setTintColor:[[self theme] colourForKey:kDRUIInboxSearchTintColour]];
    }
    if ([[self theme] colourForKey:kDRUIInboxSearchBarTintColour]) {
        [[self searchBar] setBarTintColor:[[self theme] colourForKey:kDRUIInboxSearchBarTintColour]];
    }

    //Lets add the search display controller:
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[self searchBar] contentsController:self];
    [searchDisplayController setDelegate:[self searchController]];

    [[self tableView] setTableHeaderView:[self searchBar]];

    [[self richInboxDataController] hideSearchBar];
}

- (void)createRefreshController {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh setTintColor:[[self theme] colourForKey:kDRUIInboxRefreshControlTintColour]];
    [refresh addTarget:[self richInboxDataController] action:@selector(checkForNewRichMessages) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateTableViewUI];

    //Set tab bar icon number:
    if ([self tabBarController]) {
        [self updateTabBarCount];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {
        [[self richInboxDataController] selectFirstRow];
    }

    [self setClearsSelectionOnViewWillAppear:!([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape])];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([DNSystemHelpers isDeviceIPad] && [[self tableView] isEditing]) {
        [self enterEditMode];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        if (([DNSystemHelpers isDeviceSixPlus] || [DNSystemHelpers isDeviceIPad]) && [[self tableView] isEditing]) {
            [self enterEditMode];
        }
        else  if ([DNSystemHelpers isDeviceSixPlus] && ![DNSystemHelpers isDeviceSixPlusLandscape]) {
            [[self richInboxDataController] unselectCurrentCell];
        }
        else if ([DNSystemHelpers isDeviceSixPlusLandscape]) {
            [[self richInboxDataController] selectFirstRow];
            [[self detailViewController] addExpandingButton];
        }
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
    }];
}

- (void)dealloc {
    if ([self richInboxDataController]) {
        [[self richInboxDataController] removeLocalEventHandlers];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];
}

- (void)enableLeftBarDoneButton:(BOOL)enable {
    [self setCloseButton:enable];
    [self enableCloseButton];
}

- (void)enableCloseButton {
    if ([self hasCloseButton]) {
        [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView:)]];
    }
    else {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Table view methods:

- (void)enterEditMode {

    [[self tableView] setEditing:![[self tableView] isEditing] animated:YES];

    [[self richInboxDataController] enterEditMode:[[self tableView] isEditing]];

    UIBarButtonItem *leftBarButtonItem = [[self tableView] isEditing] ? [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"select_all_navigation_title")
                                                                                                     style:UIBarButtonItemStyleDone
                                                                                                    target:self
                                                                                                    action:@selector(selectAllRichMessages:)] : nil;

    [[self navigationItem] setLeftBarButtonItem:leftBarButtonItem];

    UIBarButtonItem *rightBarButtonItem = self.tableView.isEditing ? [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                   target:self action:@selector(enterEditMode)] : [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"donky_select_all_icon.png"]
                                                                                                                                                                                                   style:UIBarButtonItemStylePlain
                                                                                                                                                                                                  target:self
                                                                                                                                                                                                  action:@selector(enterEditMode)];

    [[self navigationItem] setRightBarButtonItem:rightBarButtonItem];

    if (![[self tableView] isEditing]) {
       [self setShowingOptionsView:NO];
        [self toggleOptionsView];
        [self createRefreshController];
    }
    else {
        [self setRefreshControl:nil];
    }

    [[self searchBar] setUserInteractionEnabled:!self.searchBar.isUserInteractionEnabled];
    [[self searchBar] setAlpha:[[self searchBar] isUserInteractionEnabled] ? 1.0f : 0.5f];
    [[self detailViewController] toggleEnabled:![[self tableView] isEditing]];
}

#pragma mark -
#pragma mark - Internal helper methods:

- (void)toggleOptionsView {

    if (![self optionsView]) {
        [self setOptionsView:[DRIViewHelper optionsViewForView:self]];
        [self setOptionsViewConstraint:[[self optionsView] pinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeBottom ofItem:[[self tableView] superview] withConstant:0.0]];
        [self setOriginalOffset:UIEdgeInsetsMake(self.tableView.tableHeaderView.frame.size.height, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right)];
    }

    [[[self tableView] superview] layoutIfNeeded];

    [UIView animateWithDuration:0.25 animations:^{
        [[[self tableView] superview] removeConstraint:[self optionsViewConstraint]];
        [self setOptionsViewConstraint:![self isShowingOptionsView] ? [[self optionsView]
                pinAttribute:NSLayoutAttributeTop
                 toAttribute:NSLayoutAttributeBottom
                      ofItem:[self tableView] withConstant:0.0] : [[self optionsView]
                pinAttribute:NSLayoutAttributeBottom
       toSameAttributeOfItem:[self tableView]]];
        [[[self tableView] superview] layoutIfNeeded];
        [[self tableView] setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, self.tableView.isEditing && [[[self tableView] indexPathsForSelectedRows] count] ? 50 : self.originalOffset.bottom, 0)];
    } completion:^(BOOL finished) {
        if (![self isShowingOptionsView]) {
            [[self optionsView] removeFromSuperview];
            [self setOptionsView:nil];
        }
    }];
}

- (void)selectAllRichMessages:(id)sender {

    BOOL allSelected = [[self richInboxDataController] toggleAllSelectedMessages];

    UIBarButtonItem *leftBarButtonItem = allSelected ? [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"deselect_all_navigation_title")
                                                                                        style:UIBarButtonItemStyleDone
                                                                                       target:self
                                                                                       action:@selector(selectAllRichMessages:)] : [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"select_all_navigation_title")
                                                                                                                                                                    style:UIBarButtonItemStyleDone
                                                                                                                                                                   target:self
                                                                                                                                                                   action:@selector(selectAllRichMessages:)];

    [[self navigationItem] setLeftBarButtonItem:leftBarButtonItem];

    if (allSelected && !self.optionsView) {
        [self setShowingOptionsView:YES];
        [self toggleOptionsView];
        [[self optionsView] updateDelete:allSelected];
    }
    else if (!allSelected) {
        [self setShowingOptionsView:NO];
        [self toggleOptionsView];
    }
}

- (void)updateTableViewUI {

    if (![[self tableView] isEditing]) {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"donky_select_all_icon.png"]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(enterEditMode)]];
    }

    if ([[[self searchBar] text] length]) {
        return;
    }

    if ([[self richInboxDataController] richMessageCount] == 0) {

        [[self detailViewController] setDetailItem:nil];

        [[[self tableView] tableHeaderView] setHidden:YES];

        [[self navigationItem] setRightBarButtonItem:nil];

        if ([[self tableView] superview] && ![self noMessagesView]) {
            //Load label:
            [self setNoMessagesView:[UIView autoLayoutView]];
            [[self noMessagesView] setBackgroundColor:[self.theme colourForKey:kDRUIInboxNoMessagesBackgroundColour]];
            [[self noMessagesView] setUserInteractionEnabled:NO];
            [[[self tableView] superview] addSubview:[self noMessagesView]];

            [[self noMessagesView] constrainToSize:CGSizeMake(250, 150)];
            [[self noMessagesView] centerInView:[[self tableView] superview]];

            UILabel *noRichMessages = [UILabel autoLayoutView];
            [noRichMessages setUserInteractionEnabled:NO];
            [noRichMessages setTextColor:[[self theme] colourForKey:kDRUIInboxNoMessagesTextColour]];
            [noRichMessages setFont:[[self theme] fontForKey:kDRUIInboxNoMessagesFont]];
            [noRichMessages setTextAlignment:NSTextAlignmentCenter];
            [noRichMessages setNumberOfLines:0];
            [noRichMessages setText:DRichMessageLocalizedString(@"rich_inbox_no_messages_placeholder")];
            [[self noMessagesView] addSubview:noRichMessages];

            [noRichMessages centerInView:[self noMessagesView]];
        }
    }
    else {
        [[self noMessagesView] removeFromSuperview];
        [self setNoMessagesView:nil];
        [[[self tableView] tableHeaderView] setHidden:NO];
    }
}

#pragma mark -
#pragma mark - Delegates

- (void)richInboxMessageSelected:(DNRichMessage *)richMessage {

    if ([[self tableView] isEditing]) {
        return;
    }

    if (!richMessage) {
        [[self detailViewController] setDetailItem:nil];
        [self updateTableViewUI];
        return;
    }

    if ([[self tableView] isEditing]) {
        [[self tableView] setEditing:NO animated:YES];
    }

    //Check if message is expired:
    if ([richMessage richHasCompletelyExpired]) {
        //We need to delete:
        [[self detailViewController] setDetailItem:nil];
        [DRIViewHelper showDeleteAlert:self richMessage:richMessage selectedIndex:[[self richInboxDataController] indexOfMessage:richMessage]];
        return;
    }

    DRIMessageViewController *richMessageViewController = nil;

    //If there is no navigation controller, then we present 'modally':
    if (!self.navigationController) {
        richMessageViewController =  [[DRIMessageViewController alloc] initWithRichMessage:richMessage];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:richMessageViewController];
        [richMessageViewController addBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:richMessageViewController action:NSSelectorFromString(@"closeView:")] buttonSide:DMVLeftSide];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    }

    //Load rich view:
    if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {
        [self.detailViewController setDetailItem:richMessage];
    }
    else {
        richMessageViewController =  [[DRIMessageViewController alloc] initWithRichMessage:richMessage];
        [[self navigationController] pushViewController:richMessageViewController animated:YES];
    }

    [richMessageViewController setDelegate:self];
}

- (void)endRefreshingWithSuccess:(BOOL)success {
    [[self refreshControl] endRefreshing];
}

- (void)messagesSelected:(BOOL)selected {

    UIBarButtonItem *leftBarButtonItem = selected ? [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"deselect_all_navigation_title")
                                                                                     style:UIBarButtonItemStyleDone
                                                                                    target:self
                                                                                    action:@selector(selectAllRichMessages:)] : [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"select_all_navigation_title")
                                                                                                                                                                 style:UIBarButtonItemStyleDone
                                                                                                                                                                target:self action:@selector(selectAllRichMessages:)];
    [[self navigationItem] setLeftBarButtonItem:leftBarButtonItem];

    if (selected && ![self optionsView]) {
        [self setShowingOptionsView:YES];
        [self toggleOptionsView];
        [[self optionsView] updateDelete:selected];
    }
    else if (!selected) {
        [self setShowingOptionsView:NO];
        [self toggleOptionsView];
    }
}

- (void)updateUI {
    [self updateTableViewUI];
}

- (void)moreButtonTappedForRichMessage:(DNRichMessage *)richMessage atIndexPath:(NSIndexPath *)indexPath senderFrame:(CGRect)senderFrame {
    [DRIViewHelper presentCellActionSheet:self withMessage:richMessage atIndexPath:indexPath senderFrame:senderFrame];
}

- (void)deleteMessage:(DNRichMessage *)richMessage {
    [[self richInboxDataController] deleteRichMessage:richMessage];
    [self updateTableViewUI];
}

- (void)deleteAllExpiredMessages {
    [[self richInboxDataController] deleteAllExpiredMessages];
    [self updateTableViewUI];
}

- (void)shareRichMessage:(DNRichMessage *)richMessage {
    if ([[richMessage urlToShare] length]) {
        [[self richInboxDataController] closeAllCells];
        UIViewController *controller = [DCUIActionHelper presentShareActionSheet:self messageURL:[richMessage urlToShare] presentFromPopOver:[DNSystemHelpers isDeviceIPad] message:richMessage];
        if (controller) {
            //Get index path:
            DRITableViewCell *cell = (DRITableViewCell *) [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[self richInboxDataController] indexOfMessage:richMessage] inSection:0]];
            [self setShareItemPopOverController:[[UIPopoverController alloc] initWithContentViewController:controller]];
            [[self shareItemPopOverController] presentPopoverFromRect:[cell frame] inView:[self tableView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)toggleEditMode {
    [self enterEditMode];
}

- (void)searchDidStart {
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[self detailViewController] toggleEnabled:NO];
}

- (void)searchDidEnd {
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [[self detailViewController] toggleEnabled:YES];
}

- (void)deleteButtonTapped {
    [self setShowingOptionsView:NO];
    [self toggleOptionsView];
    [[self richInboxDataController] deleteAllSelectedMessages];
    [self updateTableViewUI];
}

- (void)updateTabBarCount {

    UITabBar *tabBar = [[self tabBarController] tabBar];

    __block UITabBarItem *tab = nil;
    [[tabBar items] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj title] isEqualToString:[self title]]) {
            tab = obj;
            *stop = YES;
        }
    }];

    NSNumber *unreadCount = [[self richInboxDataController] unreadRichMessageCount];
    if ([unreadCount integerValue] > 0) {
        [tab setBadgeValue:[unreadCount stringValue]];
    }
    else {
        [tab setBadgeValue:nil];
    }
}

#pragma mark -
#pragma mark - Action sheet and Alert delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DNRichMessage *richMessage = [self.richInboxDataController richMessageAtRow:[actionSheet tag]];
    if (!richMessage) {
        DNInfoLog(@"Message is nil and cannot be shared... An error has occured...");
        return;
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:DRichMessageLocalizedString(@"rich_inbox_share_button_title")]) {
         [self shareRichMessage:richMessage];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:DCUILocalizedString(@"common_ui_generic_delete")]) {
        [self deleteMessage:richMessage];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:DCUILocalizedString(@"common_ui_generic_delete_all")]) {
         [self deleteAllExpiredMessages];
     }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self deleteAllExpiredMessages];
    }
    else {
        [[self richInboxDataController] deleteMessageAtIndex:[alertView tag]];
    }

    [self updateTableViewUI];
}


#pragma mark -
#pragma mark - Setters

- (void)setTheme:(DRUITheme *)theme {
    if (_theme != theme || !theme) {
        _theme = theme ? : [[DRUITheme alloc] initWithDefaultTheme];
    }
}

- (void)setSearchBar:(UISearchBar *)searchBar {
    if (_searchBar != searchBar) {
        _searchBar = searchBar;
        [_searchBar setDelegate:[self searchController]];
        [_searchBar setShowsSearchResultsButton:NO];
    }
}

@end

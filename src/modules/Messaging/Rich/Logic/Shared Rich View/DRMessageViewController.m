//
//  DRMessageViewController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <MacTypes.h>
#import "DRMessageViewController.h"
#import "UIView+AutoLayout.h"
#import "NSDate+DNDateHelper.h"
#import "DCUIThemeController.h"
#import "DRUIThemeConstants.h"
#import "DRichMessage+Localization.h"
#import "DCUIActionHelper.h"
#import "DRLogicHelper.h"
#import "DNSystemHelpers.h"
#import "DCUILocalization+Localization.h"
#import "DRMessageViewControllerHelper.h"

@interface DRMessageViewController ()
@property(nonatomic, readwrite, getter=shouldHideViewController) BOOL hideViewController;
@property(nonatomic, strong) UIPopoverController *shareItemPopOverController;
@property(nonatomic, strong) UIPopoverController *masterPopoverController;
@property(nonatomic, strong) UIBarButtonItem *expandViewBarButton;
@property(nonatomic, strong) UIBarButtonItem *loadingBarButton;
@property(nonatomic, strong) DNRichMessage *richMessage;
@property(nonatomic, strong) UIView *noMessagesView;
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) DRUITheme *theme;
@end

@implementation DRMessageViewController


#pragma mark -
#pragma mark - View life cycle

- (instancetype)initWithRichMessage:(DNRichMessage *)richMessage {

    self = [super init];

    if (self) {
        [self initialiseView:richMessage];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];

    if (self) {
        [self initialiseView:nil];
    }

    return self;
}

- (void)initialiseView:(DNRichMessage *) richMessage {

    //Get the theme:
    self.theme = (DRUITheme *) [[DCUIThemeController sharedInstance] themeForName:kDRUIThemeName];

    //We don't have a theme, so initialise with the default:
    if (!self.theme) {
        self.theme = [[DRUITheme alloc] initWithDefaultTheme];
    }

    [[self view] setBackgroundColor:[UIColor whiteColor]];

    self.hideViewController = YES;

    [self setRichMessage:richMessage];

    [self setTitle:[[self richMessage] senderDisplayName]];

    [self loadRichMessage];

}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setupWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeBarButtonItem:self.expandViewBarButton buttonSide:DMVLeftSide];
    self.expandViewBarButton = nil;
}

#pragma mark -
#pragma mark - WebView creation

- (void)setupWebView {

    self.webView = [UIWebView autoLayoutView];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self.webView setAllowsInlineMediaPlayback:YES];
    [[self.webView scrollView] setMinimumZoomScale:0.0];
    [[self view] addSubview:self.webView];
    [self.webView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];

}

#pragma mark -
#pragma mark - WebView Delegates

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self removeBarButtonItem:self.loadingBarButton buttonSide:DMVRightSide];
    self.loadingBarButton = nil;

    if ([[self.richMessage canShare] boolValue] && [[self.richMessage urlToShare] length]) {
        [self addBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)] buttonSide:DMVRightSide];
    }
}

#pragma mark -
#pragma mark - Helper Methods

- (void)shareButtonTapped:(UIBarButtonItem *)sender {
    UIViewController *viewController = [DCUIActionHelper presentShareActionSheet:self messageURL:[self.richMessage urlToShare] presentFromPopOver:YES message:self.richMessage];
    if (viewController) {
        self.shareItemPopOverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
        [self.shareItemPopOverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem isRighSide:(BOOL)rightSide {
    [self addBarButtonItem:buttonItem buttonSide:rightSide ? DMVRightSide : DMVLeftSide];
}

- (void)addBarButtonItem:(UIBarButtonItem *)buttonItem buttonSide:(DonkyMessageViewBarButtonSide)side {
    [DRMessageViewControllerHelper addBarButtonItem:buttonItem buttonSide:side navigationController:self.navigationItem];
}

- (void)removeBarButtonItem:(UIBarButtonItem *)buttonItem buttonSide:(DonkyMessageViewBarButtonSide)side {
    [DRMessageViewControllerHelper removeBarButtonItem:buttonItem buttonSide:side navigationItem:self.navigationItem];
}

- (void)toggleEnabled:(BOOL)isEnabled {
    [self.webView setAlpha:isEnabled ? 1.0f : 0.50f];
    [self.webView setUserInteractionEnabled:isEnabled];

    [[self.navigationItem rightBarButtonItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled:isEnabled];
    }];

    [[self.navigationItem leftBarButtonItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled:isEnabled];
    }];
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[self delegate] respondsToSelector:@selector(richMessagePopUpWasClosed:)]) {
            [[self delegate] richMessagePopUpWasClosed:[[self richMessage] messageID]];
        }
    }];
}

- (NSString *) richMessageContent {

    if (![[self richMessage] expiryTimestamp]) {
        return [[self richMessage] body];
    }

    //Figure out expiration:
    NSDate *currentDate = [NSDate date];

    NSDate *expirationDate = [[self richMessage] expiryTimestamp];

    NSString *richMessageContent = nil;

    if ([expirationDate isDateBeforeDate:currentDate]) {
        richMessageContent = [[self richMessage] expiredBody];
    }
    else {
        richMessageContent = [[self richMessage] body];
    }

    return richMessageContent;
}

- (void)loadRichMessage {

    NSString *richMessageContent = [self richMessageContent];

    if (richMessageContent) {

        if (self.noMessagesView) {
            [self.noMessagesView removeFromSuperview];
            self.noMessagesView = nil;
        }

        [self.webView loadHTMLString:richMessageContent baseURL:nil];

        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loading startAnimating];

        self.loadingBarButton = [[UIBarButtonItem alloc] initWithCustomView:loading];

        self.navigationItem.rightBarButtonItem = self.loadingBarButton;

        [self.webView setUserInteractionEnabled:YES];
    }
    else {
        [self.webView loadHTMLString:@"" baseURL:nil];
        if (!self.noMessagesView) {
            //Load label:
            self.noMessagesView = [UIView autoLayoutView];
            [self.noMessagesView setBackgroundColor:[self.theme colourForKey:kDRUIInboxNoMessagesBackgroundColour]];
            [self.noMessagesView setUserInteractionEnabled:NO];
            [self.view addSubview:self.noMessagesView];

            [self.noMessagesView constrainToSize:CGSizeMake(250, 150)];
            [self.noMessagesView centerInView:self.view];

            UILabel *noRichMessages = [DRMessageViewControllerHelper noRichMessageViewWithTheme:self.theme];
            [self.noMessagesView addSubview:noRichMessages];

            [noRichMessages centerInView:self.noMessagesView];

            [self.webView setUserInteractionEnabled:NO];
        }
    }

    [DRLogicHelper markMessageAsRead:self.richMessage];
}

#pragma mark -
#pragma mark - Split View Controller Methods

- (void)setDetailItem:(DNRichMessage *)detailItem {

    if (_detailItem != detailItem) {

        _detailItem = detailItem;
        
        if (([DNSystemHelpers isDeviceSixPlus] && [DNSystemHelpers isDeviceSixPlusLandscape] && !self.expandViewBarButton) && detailItem) {
            self.navigationItem.leftItemsSupplementBackButton = YES;
            self.expandViewBarButton = self.splitViewController.displayModeButtonItem;
            if (self.expandViewBarButton) {
                [self addBarButtonItem:self.expandViewBarButton buttonSide:DMVLeftSide];
            }
        }

        [self setRichMessage:detailItem];
        [self setTitle:[detailItem senderDisplayName]];

        [self loadRichMessage];
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
        collapseSecondaryViewController:(UIViewController *)secondaryViewController
        ontoPrimaryViewController:(UIViewController *)primaryViewController {

    return [secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DRMessageViewController class]]
        && ([(DRMessageViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {

    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    if ([DNSystemHelpers isDeviceSixPlusLandscape] && [newCollection horizontalSizeClass] == UIUserInterfaceSizeClassCompact) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = DCUILocalizedString(@"common_ui_generic_inbox");
    [self addBarButtonItem:barButtonItem buttonSide:DMVLeftSide];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
     // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark -
#pragma mark - Helper Getters (for pop up)

- (UINavigationController *)richPopUpNavigationControllerWithModalPresentationStyle:(UIModalPresentationStyle) presentationStyle {
    NSString *richMessageContent = [self richMessageContent];
    if (richMessageContent) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        if (presentationStyle)
            [navigationController setModalPresentationStyle:presentationStyle];

        return navigationController;
    }
    return nil;
}

@end

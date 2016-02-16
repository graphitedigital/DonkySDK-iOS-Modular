//
//  DRIMessageViewController.m
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRIMessageViewController.h"
#import "UIView+AutoLayout.h"
#import "NSDate+DNDateHelper.h"
#import "DCUIThemeController.h"
#import "DRUIThemeConstants.h"
#import "DCUIActionHelper.h"
#import "DRLogicHelper.h"
#import "DNSystemHelpers.h"
#import "DCUILocalization+Localization.h"
#import "DRIMessageViewControllerHelper.h"
#import "DRUITheme.h"
#import "DRLogicMainController.h"
#import "DNRichMessage+DNRichMessageHelper.h"

@interface DRIMessageViewController ()
@property(nonatomic, readwrite, getter=shouldHideViewController) BOOL hideViewController;
@property(nonatomic, strong) UIPopoverController *shareItemPopOverController;
@property(nonatomic, strong) UIPopoverController *masterPopoverController;
@property(nonatomic, strong) UIBarButtonItem *expandViewBarButton;
@property(nonatomic, strong) UIBarButtonItem *loadingBarButton;
@property(nonatomic, strong) UIBarButtonItem *shareButtonItem;
@property(nonatomic, strong) DNRichMessage *richMessage;
@property(nonatomic, strong) UIView *noMessagesView;
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) DRUITheme *theme;
@end

@implementation DRIMessageViewController


#pragma mark -
#pragma mark - View life cycle

- (instancetype)initWithRichMessage:(DNRichMessage *)richMessage {

    self = [super init];

    if (self) {
        [self setRichMessage:richMessage];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];

    if (self) {

        
    }

    return self;
}

- (void)initialiseView:(DNRichMessage *) richMessage {

    //Get the theme:
    [self setTheme:(DRUITheme *) [[DCUIThemeController sharedInstance] themeForName:kDRUIThemeName]];

    //We don't have a theme, so initialise with the default:
    if (![self theme]) {
        [self setTheme:[[DRUITheme alloc] initWithDefaultTheme]];
    }

    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setHideViewController:YES];

    [self setRichMessage:richMessage];

    [self setTitle:[[self richMessage] senderDisplayName]];

    [self loadRichMessage];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self initialiseView:[self richMessage]];

    [self setupWebView];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeBarButtonItem:[self expandViewBarButton] buttonSide:DMVLeftSide];
    [self setExpandViewBarButton:nil];
}

#pragma mark -
#pragma mark - WebView creation

- (void)setupWebView {

    [self setWebView:[UIWebView autoLayoutView]];
    [[self webView] setDelegate:self];
    [[self webView] setScalesPageToFit:YES];
    [[self webView] setAllowsInlineMediaPlayback:YES];
    [[[self webView] scrollView] setMinimumZoomScale:0.0];
    [[self view] addSubview:[self webView]];
    [[self webView] pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0 usingLayoutGuidesFrom:self];

}

#pragma mark -
#pragma mark - WebView Delegates

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if ([self loadingBarButton]) {
        [self removeBarButtonItem:[self loadingBarButton] buttonSide:DMVRightSide];
        [self setLoadingBarButton:nil];
    }

    if ([[self richMessage] canBeShared] && ![self shareButtonItem]) {
        [self setShareButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)]];
        [self addBarButtonItem:[self shareButtonItem] buttonSide:DMVRightSide];
    }
}

#pragma mark -
#pragma mark - Helper Methods

- (void)shareButtonTapped:(UIBarButtonItem *)sender {
    UIViewController *viewController = [DCUIActionHelper presentShareActionSheet:self messageURL:[[self richMessage] urlToShare] presentFromPopOver:YES message:[self richMessage]];
    if (viewController) {
        [self setShareItemPopOverController:[[UIPopoverController alloc] initWithContentViewController:viewController]];
        [[self shareItemPopOverController] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem isRighSide:(BOOL)rightSide {
    [self addBarButtonItem:buttonItem buttonSide:rightSide ? DMVRightSide : DMVLeftSide];
}

- (void)addBarButtonItem:(UIBarButtonItem *)buttonItem buttonSide:(DonkyMessageViewBarButtonSide)side {
    [DRIMessageViewControllerHelper addBarButtonItem:buttonItem buttonSide:side navigationController:self.navigationItem];
}

- (void)removeBarButtonItem:(UIBarButtonItem *)buttonItem buttonSide:(DonkyMessageViewBarButtonSide)side {
    [DRIMessageViewControllerHelper removeBarButtonItem:buttonItem buttonSide:side navigationItem:self.navigationItem];
}

- (void)toggleEnabled:(BOOL)isEnabled {
    [[self webView] setAlpha:isEnabled ? 1.0f : 0.50f];
    [[self webView] setUserInteractionEnabled:isEnabled];

    [[[self navigationItem] rightBarButtonItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled:isEnabled];
    }];

    [[[self navigationItem] leftBarButtonItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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

        if ([self noMessagesView]) {
            [[self noMessagesView] removeFromSuperview];
            [self setNoMessagesView:nil];
        }

        [[self webView] loadHTMLString:richMessageContent baseURL:nil];
        
        if ([self shareButtonItem]) {
            [self removeBarButtonItem:[self shareButtonItem] buttonSide:DMVRightSide];
            [self setShareButtonItem:nil];
        }
        
        if ([self loadingBarButton]) {
            [self removeBarButtonItem:[self loadingBarButton] buttonSide:DMVRightSide];
            [self setLoadingBarButton:nil];
        }

        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loading startAnimating];

        [self setLoadingBarButton:[[UIBarButtonItem alloc] initWithCustomView:loading]];

        [self addBarButtonItem:[self loadingBarButton] buttonSide:DMVRightSide];

        [[self webView] setUserInteractionEnabled:YES];
    }
    else {
        [[self webView] loadHTMLString:@"" baseURL:nil];
        if (![self noMessagesView]) {
            //Load label:
            [self setNoMessagesView:[UIView autoLayoutView]];
            [[self noMessagesView] setBackgroundColor:[[self theme] colourForKey:kDRUIInboxNoMessagesBackgroundColour]];
            [[self noMessagesView] setUserInteractionEnabled:NO];
            [[self view] addSubview:[self noMessagesView]];

            [[self noMessagesView] constrainToSize:CGSizeMake(250, 150)];
            [[self noMessagesView] centerInView:self.view];

            UILabel *noRichMessages = [DRIMessageViewControllerHelper noRichMessageViewWithTheme:[self theme]];
            [[self noMessagesView] addSubview:noRichMessages];

            [noRichMessages centerInView:[self noMessagesView]];

            [[self webView] setUserInteractionEnabled:NO];
        }
    }

    [DRLogicMainController markMessageAsRead:[self richMessage]];
}

#pragma mark -
#pragma mark - Split View Controller Methods

- (void)setDetailItem:(DNRichMessage *)detailItem {

    if (_detailItem != detailItem) {

        _detailItem = detailItem;

        [self setRichMessage:detailItem];
        [self setTitle:[detailItem senderDisplayName]];
        [self loadRichMessage];
        [self addExpandingButton];

    }

    if (!detailItem) {
        if ([self expandViewBarButton]) {
            [self removeBarButtonItem:[self expandViewBarButton] buttonSide:DMVLeftSide];
            [self setExpandViewBarButton:nil];
        }
        if ([self shareButtonItem]) {
            [self removeBarButtonItem:[self shareButtonItem] buttonSide:DMVRightSide];
            [self setShareButtonItem:nil];
        }
        if ([self loadingBarButton]) {
            [self removeBarButtonItem:[self loadingBarButton] buttonSide:DMVRightSide];
            [self setLoadingBarButton:nil];
        }
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
        collapseSecondaryViewController:(UIViewController *)secondaryViewController
        ontoPrimaryViewController:(UIViewController *)primaryViewController {

    return [secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DRIMessageViewController class]]
        && ([(DRIMessageViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {

    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    if ([DNSystemHelpers isDeviceSixPlusLandscape] && [newCollection horizontalSizeClass] == UIUserInterfaceSizeClassCompact) {
        [[self navigationController] popToRootViewControllerAnimated:NO];
    }
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    [barButtonItem setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];
    __block BOOL hasInboxButton = NO;
    [[[[self navigationController] navigationItem] leftBarButtonItems] enumerateObjectsUsingBlock:^(UIBarButtonItem *obj, NSUInteger idx, BOOL *stop) {
        UIBarButtonItem *item = obj;
        if ([[item title] isEqualToString:DCUILocalizedString(@"common_ui_generic_inbox")]) {
            hasInboxButton = YES;
            *stop = YES;
        }
    }];

    if (!hasInboxButton) {
        [self addBarButtonItem:barButtonItem buttonSide:DMVLeftSide];
    }

    [self setMasterPopoverController:popoverController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
     // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    [self setMasterPopoverController:nil];
}

- (void)addExpandingButton {
    if (([DNSystemHelpers isDeviceSixPlus] && [DNSystemHelpers isDeviceSixPlusLandscape] && ![self expandViewBarButton]) && [self detailItem]) {
        [[self navigationItem] setLeftItemsSupplementBackButton:YES];
        [self setExpandViewBarButton:[[self splitViewController] displayModeButtonItem]];
        if ([self expandViewBarButton]) {
            [self addBarButtonItem:[self expandViewBarButton] buttonSide:DMVLeftSide];
        }
    }
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

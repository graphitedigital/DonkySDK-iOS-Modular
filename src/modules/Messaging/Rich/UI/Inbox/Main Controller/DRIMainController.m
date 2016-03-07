//
//  DRIMainController.m
//  RichInbox
//
//  Created by Donky Networks on 12/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRIMainController.h"
#import "DNSystemHelpers.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DCMConstants.h"
#import "DRConstants.h"
#import "DCUILocalization+Localization.h"
#import "DRIMainControllerHelper.h"
#import "DRichMessage+Localization.h"
#import "DCUIThemeController.h"
#import "DRUIThemeConstants.h"
#import "DNQueueManager.h"

@interface DRIMainController ()
@property (nonatomic, strong) DNLocalEventHandler richMessageBadgeCount;
@end

@implementation DRIMainController

+(DRIMainController *)sharedInstance {
    static dispatch_once_t pred;
    static DRIMainController *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DRIMainController alloc] initPrivate];
    });

    return sharedInstance;
}

-(instancetype)init {
    return [self initPrivate];
}

-(instancetype)initPrivate{

    self  = [super init];

    if (self) {

        [self setRichLogicController:[[DRLogicMainController alloc] init]];

        DNModuleDefinition *richInboxMainController = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"];
        [[DNDonkyCore sharedInstance] registerModule:richInboxMainController];

        [self setShowBannerView:YES];
        [self setLoadTappedMessage:YES];

        [self setIPadModelPresentationStyle:UIModalPresentationFormSheet];
        
    }

    return self;
}

- (void)start {

    [[self richLogicController] start];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDRichMessageBadgeCount handler:[self richMessageBadgeCount]];
}

- (void)stop {
    
    [[self richLogicController] stop];

    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDRichMessageBadgeCount handler:[self richMessageBadgeCount]];

}

- (UINavigationController *)richInboxTableViewWithNavigationController {
    return [DRIMainController richInboxTableViewWithNavigationController];
}

- (DRITableViewController *)richInboxTableViewController {
    return [DRIMainController richInboxTableViewController];
}

- (DCUISplitViewController *)richInboxSplitViewController {
    return [DRIMainController richInboxSplitViewController];
}

- (UIViewController *)universalRichInboxViewController {
    return [DRIMainController universalRichInboxViewController];
}

- (void)setTabBarItemProperties:(id)viewController {

    DRUITheme *theme = (DRUITheme *) [[DCUIThemeController sharedInstance] themeForName:kDRUIThemeName];

    if (!theme) {
        theme = [[DRUITheme alloc] initWithDefaultTheme];
    }

    [[viewController tabBarItem] setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];
    [[viewController tabBarItem] setImage:[theme imageForKey:kDRUIInboxIconImage]];

}

- (void)enableLeftBarDoneButtonForViewController:(id)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(DRITableViewController *)[[viewController viewControllers] firstObject] enableLeftBarDoneButton:YES];
    }
    else if ([viewController isKindOfClass:[UISplitViewController class]]) {
        [(DRITableViewController *)[[[[viewController viewControllers] firstObject] viewControllers] firstObject] enableLeftBarDoneButton:YES];
    }
}

#pragma mark -
#pragma mark - Getters

- (DNLocalEventHandler)richMessageBadgeCount {

    if (!_richMessageBadgeCount) {
        _richMessageBadgeCount = [DRIMainControllerHelper richMessageBadgeCount];
    }

    return _richMessageBadgeCount;
}


#pragma mark -
#pragma mark - Class Methods

+ (UINavigationController *) richInboxTableViewWithNavigationController {

    UINavigationController *tableViewNavigationController = [[UINavigationController alloc] initWithRootViewController:[DRIMainController richInboxTableViewController]];

    [[[tableViewNavigationController viewControllers] firstObject] setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];

    [DRIMainController setTabBarItemProperties:tableViewNavigationController];

    return tableViewNavigationController;
}

+ (DRITableViewController *) richInboxTableViewController {

    DRITableViewController *tableViewController = [[DRITableViewController alloc] initWithStyle:UITableViewStylePlain];

    return tableViewController;
}

+ (DCUISplitViewController *) richInboxSplitViewController {

    NSAssert([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlus], @"Error, cannot load a split view controller on an iPhone (unless it's an iPhone 6+)");

    DRIMessageViewController *richMessageViewController = [[DRIMessageViewController alloc] initWithRichMessage:nil];

    DRITableViewController *richTableViewController = [DRIMainController richInboxTableViewController];

    DCUISplitViewController *splitViewController = [[DCUISplitViewController alloc] initWithMasterView:richTableViewController detailViewController:richMessageViewController];

    [richTableViewController setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];

    [DRIMainController setTabBarItemProperties:splitViewController];

    return splitViewController;
}

+ (UIViewController *)universalRichInboxViewController {

    if ([DNSystemHelpers isDeviceSixPlus] || [DNSystemHelpers isDeviceIPad]) {
        return [DRIMainController richInboxSplitViewController];
    }
    else {
        return [DRIMainController richInboxTableViewWithNavigationController];
    }
}

+ (void)setTabBarItemProperties:(id)viewController {
    DRUITheme *theme = (DRUITheme *) [[DCUIThemeController sharedInstance] themeForName:kDRUIThemeName];
    if (!theme) {
        theme = [[DRUITheme alloc] initWithDefaultTheme];
    }
    [[viewController tabBarItem] setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];
    [[viewController tabBarItem] setImage:[theme imageForKey:kDRUIInboxIconImage]];
    [[viewController tabBarItem] setSelectedImage:[theme imageForKey:kDRUIInboxSelectedIconImage]];
}

@end

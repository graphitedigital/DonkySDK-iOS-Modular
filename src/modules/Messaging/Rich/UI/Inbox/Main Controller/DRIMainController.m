//
//  DRIMainController.m
//  RichInbox
//
//  Created by Chris Watson on 12/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRIMainController.h"
#import "DNSystemHelpers.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DCMConstants.h"
#import "DRConstants.h"
#import "DCUILocalization+Localization.h"
#import "DRIMainControllerHelper.h"
#import "DRichMessage+Localization.h"

@interface DRIMainController ()
@property(nonatomic, strong) DNLocalEventHandler richMessageTapped;
@property(nonatomic, strong) DNLocalEventHandler richMessageNotificationHandler;
@property(nonatomic, strong) DNLocalEventHandler bannerTappedHandler;
@property(nonatomic, strong) DNLocalEventHandler richMessageBadgeCount;
@property(nonatomic, strong) DCUIBannerView *multiBannerView;
@property(nonatomic, strong) DCUINotificationController *notificationController;
@end

@implementation DRIMainController

+(DRIMainController *)sharedInstance
{
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

-(instancetype)initPrivate
{

    self  = [super init];

    if (self) {

        [self setRichLogicController:[[DRLogicMainController alloc] init]];
        [self setNotificationController:[[DCUINotificationController alloc] init]];

        DNModuleDefinition *richInboxMainController = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"];
        [[DNDonkyCore sharedInstance] registerModule:richInboxMainController];

        [self setShowBannerView:YES];
        [self setLoadTappedMessage:YES];
        [self setVibrate:YES];

        [self setIPadModelPresentationStyle:UIModalPresentationFormSheet];
        
    }

    return self;
}

- (void)start {

    [[self richLogicController] start];

    __weak DRIMainController *weakSelf = self;

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDRichMessageNotificationTapped handler:[self richMessageTapped]];

    [self setRichMessageNotificationHandler:^(DNLocalEvent *event) {
        if ([event isKindOfClass:[DNLocalEvent class]]) {
            [weakSelf richMessageNotificationsReceived:[event data]];
        }
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDRichMessageNotificationEvent handler:[self richMessageNotificationHandler]];
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventNotificationTapped handler:[self bannerTappedHandler]];
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDRichMessageBadgeCount handler:[self richMessageBadgeCount]];
}

- (void)stop {
    
    [[self richLogicController] stop];

    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDRichMessageNotificationTapped handler:[self richMessageTapped]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDRichMessageNotificationEvent handler:[self richMessageNotificationHandler]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventNotificationTapped handler:[self bannerTappedHandler]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDRichMessageBadgeCount handler:[self richMessageBadgeCount]];

    [self setRichMessageTapped:nil];
    [self setRichMessageNotificationHandler:nil];
    [self setBannerTappedHandler:nil];
}

- (UINavigationController *) richInboxTableViewWithNavigationController {

    UINavigationController *tableViewNavigationController = [[UINavigationController alloc] initWithRootViewController:[self richInboxTableViewController]];
    
    [[[tableViewNavigationController viewControllers] firstObject] setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];

    [self setTabBarItemProperties:tableViewNavigationController];

    return tableViewNavigationController;
}

- (DRITableViewController *) richInboxTableViewController {

    DRITableViewController *tableViewController = [[DRITableViewController alloc] initWithStyle:UITableViewStylePlain];

    return tableViewController;
}

- (DCUISplitViewController *) richInboxSplitViewController {

    NSAssert([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlus], @"Error, cannot load a split view controller on an iPhone (unless it's an iPhone 6+)");

    DRIMessageViewController *richMessageViewController = [[DRIMessageViewController alloc] initWithRichMessage:nil];

    DRITableViewController *richTableViewController = [self richInboxTableViewController];

    DCUISplitViewController *splitViewController = [[DCUISplitViewController alloc] initWithMasterView:richTableViewController detailViewController:richMessageViewController];

    [richTableViewController setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];

    [self setTabBarItemProperties:splitViewController];
    
    return splitViewController;
}

- (UIViewController *)universalRichInboxViewController {

    if ([DNSystemHelpers isDeviceSixPlus] || [DNSystemHelpers isDeviceIPad]) {
        return [[DRIMainController sharedInstance] richInboxSplitViewController];
    }
    else {
        return [[DRIMainController sharedInstance] richInboxTableViewWithNavigationController];
    }
}

- (void)setTabBarItemProperties:(id)viewController {
    
    [[viewController tabBarItem] setTitle:DCUILocalizedString(@"common_ui_generic_inbox")];
    [[viewController tabBarItem] setImage:[UIImage imageNamed:@"donky_inbox_icon.png"]];
    
}

- (void)richMessageNotificationsReceived:(NSDictionary *)notificationData {
    //Clean out nulls:
    NSArray *notifications = notificationData[kDNDonkyNotificationRichMessage];

    if ([notifications count] >= 2) {

        //Show multi banner text:
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            if ([self shouldShowBannerView] && ![self multiBannerView]) {
                [self setMultiBannerView:[[DCUIBannerView alloc] initWithSenderDisplayName:@"Donky"
                                                                                    body:[NSString stringWithFormat:DRichMessageLocalizedString(@"rich_box_multiple_messages_received"), [notifications count]]
                                                                         messageSentTime:[NSDate date]
                                                                           avatarAssetID:nil
                                                                        notificationType:@"MultiRichMessage"
                                                                               messageID:nil]];
                [[self notificationController] presentNotification:[self multiBannerView]];
                [[self notificationController] loadDefaultAvatar];
            }
        }
    }
    else {
       [DRIMainControllerHelper processNotifications:notificationData
                              notificationController:[self notificationController]
                                 richLogicController:[self richLogicController]
                                      showBannerView:[self shouldShowBannerView]];
    }
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

- (DNLocalEventHandler)richMessageTapped {

    if (!_richMessageTapped) {
        __weak DRIMainController *weakSelf = self;
        _richMessageTapped = [DRIMainControllerHelper richMessageTapped:weakSelf];
    }

    return _richMessageTapped;
}

- (DNLocalEventHandler)bannerTappedHandler {

    if (!_bannerTappedHandler) {
        __weak DRIMainController *weakSelf = self;
        _bannerTappedHandler = [DRIMainControllerHelper bannerTapped:weakSelf notificationController:self.notificationController];
    }

    return _bannerTappedHandler;
}

- (DNLocalEventHandler)richMessageBadgeCount {

    if (!_richMessageBadgeCount) {
        _richMessageBadgeCount = [DRIMainControllerHelper richMessageBadgeCount];
    }

    return _richMessageBadgeCount;
}

@end

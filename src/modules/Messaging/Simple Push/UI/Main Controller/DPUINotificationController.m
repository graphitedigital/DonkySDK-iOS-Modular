//
//  DPUINotificationController.m
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "UIView+AutoLayout.h"
#import "DPUINotificationController.h"
#import "DPUINotification.h"
#import "DNConstants.h"
#import "DPConstants.h"
#import "DPPushNotificationController.h"
#import "UIViewController+DNRootViewController.h"
#import "DNDonkyCore.h"
#import "NSDate+DNDateHelper.h"
#import "DCUIMainController.h"
#import "DPUIBannerView.h"
#import "DCMConstants.h"

static CGFloat const DPUINotificationBannerDismissTime = 10.0f;

@interface DPUINotificationController ()
@property(nonatomic, strong) NSArray *notificationBannerViewTopEdge;
@property(nonatomic, strong) NSLayoutConstraint *bannerViewHeightConstraint;
@property(nonatomic, strong) DPUIBannerView *notificationBannerView;
@property(nonatomic) CGRect bannerOriginalFrame;
@property(nonatomic, getter=hasMoved) BOOL moved;
@property(nonatomic) CGPoint originalCenter;
@property(nonatomic, strong) NSMutableArray *queuedNotifications;
@property(nonatomic, strong) NSTimer *bannerDismissTimer;
@property(nonatomic, strong) DPPushNotificationController *pushNotificationController;
@property(nonatomic, copy) void (^pushReceivedHandler)(DNLocalEvent *);
@property(nonatomic, copy) void (^bannerTappedHandler)(DNLocalEvent *);
@end

@implementation DPUINotificationController

#pragma mark -
#pragma mark - Setup Singleton


+(DPUINotificationController *)sharedInstance
{
    static DPUINotificationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPUINotificationController alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init
{
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    self  = [super init];
    if (self) {
        //Start Push Logic:
        self.pushNotificationController = [[DPPushNotificationController alloc] init];
        [self.pushNotificationController start];
    }

    return self;
}

- (void)start {

    __weak DPUINotificationController *weakSelf = self;
    self.pushReceivedHandler = ^(DNLocalEvent *event) {
        if ([event isKindOfClass:[DNLocalEvent class]])
            [weakSelf pushNotificationReceived:[event data]];
    };

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:self.pushReceivedHandler];
    
    self.bannerTappedHandler = ^(DNLocalEvent *event) {
        [weakSelf bannerDismissTimerDidTick];
    };
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventSimplePushTapped handler:self.bannerTappedHandler];
    
    DNModuleDefinition *simplePushUIController = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.1.0.0"];
    [[DNDonkyCore sharedInstance] registerModule:simplePushUIController];
    
}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:self.pushReceivedHandler];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:self.bannerTappedHandler];
    
    self.bannerTappedHandler = nil;
    self.pushNotificationController = nil;
}

#pragma mark -
#pragma mark - Core Logic

- (void)pushNotificationReceived:(NSDictionary *)notificationData {

    __block BOOL duplicate = NO;

    NSArray *backgroundNotifications = notificationData[@"PendingPushNotifications"];

    DNServerNotification *notification = notificationData[kDNDonkyNotificationSimplePush];

    [backgroundNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *notificationID = obj;
        if ([notificationID isEqualToString:[notification serverNotificationID]]) {
            duplicate = YES;
            *stop = YES;
        }
    }];

    NSDate *expired = [NSDate donkyDateFromServer:[notification data][@"expiryTimeStamp"]];

    BOOL messageExpired = NO;
    if (expired)
        messageExpired = [expired donkyHasDateExpired];
    
    if (!duplicate && !messageExpired) {
        //Only present this if it hasn't already been seen:
        UIViewController *presentingViewController = [UIViewController applicationRootViewController];
        if ([presentingViewController view] && !self.notificationBannerView) {
            DPUINotification *donkyNotification = [[DPUINotification alloc] initWithNotification:notification];
            //Create view
            self.notificationBannerView = [[DPUIBannerView alloc] initWithNotification:donkyNotification];
            [self.notificationBannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            //If we are on simple push, we add the other gestures:
            if (![self.notificationBannerView buttonView])
                [self.notificationBannerView configureGestures];
            
            [[presentingViewController view] addSubview:self.notificationBannerView];

            [self calculateBannerViewHeightForPresentingView:[presentingViewController view] animateChange:NO];
            [[self notificationBannerView] layoutIfNeeded];

            [self.notificationBannerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            self.notificationBannerViewTopEdge = [self.notificationBannerView pinToSuperviewEdges:JRTViewPinTopEdge inset:-self.notificationBannerView.frame.size.height];

            [self.bannerDismissTimer invalidate];

            if (!self.notificationBannerView.buttonView)
                self.bannerDismissTimer = [NSTimer scheduledTimerWithTimeInterval:DPUINotificationBannerDismissTime target:self selector:@selector(bannerDismissTimerDidTick) userInfo:nil repeats:NO];

            [self performSelector:@selector(presentView) withObject:nil afterDelay:0.50];

        }
        else {
            if (![self queuedNotifications])
                [self setQueuedNotifications:[[NSMutableArray alloc] init]];

            [[self queuedNotifications] addObject:notificationData];
        }
    }
    else
        [self reduceAppBadge:1];
}

- (void)presentView {
    UIViewController *presentingViewController = [UIViewController applicationRootViewController];
    [UIView animateWithDuration:0.25f animations:^{
        [[presentingViewController view] removeConstraints:self.notificationBannerViewTopEdge];
        self.notificationBannerViewTopEdge = [self.notificationBannerView pinToSuperviewEdges:JRTViewPinTopEdge inset:0];
        [[presentingViewController view] layoutIfNeeded];
        [DCUIMainController addGestureToView:self.notificationBannerView withDelegate:self withSelector:@selector(panGesture:)];
    }];
}

- (void)reduceAppBadge:(NSInteger)count {
    DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDPDonkyEventChangeBadgeCount
                                                                   publisher:NSStringFromClass([self class])
                                                                   timeStamp:[NSDate date]
                                                                        data:@(count)];
    [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
}

- (void)calculateBannerViewHeightForPresentingView:(UIView *)presentingView animateChange:(BOOL)animate {

    if (self.bannerViewHeightConstraint) {
        [[self notificationBannerView] layoutIfNeeded];
        [[self notificationBannerView] removeConstraint:self.bannerViewHeightConstraint];
    }

    CGFloat stringHeight = [DCUIMainController sizeForString:self.notificationBannerView.messageLabel.text
                                                        font:self.notificationBannerView.messageLabel.font
                                                   maxHeight:CGFLOAT_MAX
                                                    maxWidth:presentingView.frame.size.width - 100].height;

    //buffer for buttons:
    CGFloat buffer = [self.notificationBannerView buttonView] ? 60 : 10;
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            if (stringHeight > 40)
                self.bannerViewHeightConstraint = [[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                        toSameAttributeOfItem:self.notificationBannerView.messageLabel
                                                                                 withConstant:buffer];
            else
                self.bannerViewHeightConstraint = [[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                        toSameAttributeOfItem:self.notificationBannerView.avatarImageView
                                                                                 withConstant:buffer];
            [self.notificationBannerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            NSLog(@"Done");
        }];
    }
    else {
        if (stringHeight > 40)
            self.bannerViewHeightConstraint = [[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                    toSameAttributeOfItem:self.notificationBannerView.messageLabel
                                                                             withConstant:buffer];
        else
            self.bannerViewHeightConstraint = [[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                    toSameAttributeOfItem:self.notificationBannerView.avatarImageView
                                                                             withConstant:buffer];
    }

    self.bannerOriginalFrame = self.notificationBannerView.frame;
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture {

    if (!self.hasMoved) {
        self.bannerOriginalFrame = panGesture.view.frame;
        self.originalCenter = panGesture.view.center;
    }
    if ([panGesture state] != UIGestureRecognizerStateEnded) {
        if (!self.hasMoved)
            self.moved = YES;

        CGPoint translation = [panGesture translationInView:panGesture.view];
        if ((panGesture.view.frame.origin.y + translation.y) < self.bannerOriginalFrame.origin.y) {
            panGesture.view.center = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + translation.y);
            [panGesture setTranslation:CGPointMake(0, 0) inView:panGesture.view];
        }
    }
    else {
        if (panGesture.view.center.y < 20)
            [self slideBannerView];
        else {
            [UIView animateWithDuration:0.25 animations:^{
                panGesture.view.center = CGPointMake(panGesture.view.center.x, self.originalCenter.y);
            } completion:^(BOOL finished) {
                if (finished)
                    self.notificationBannerViewTopEdge = [self.notificationBannerView pinToSuperviewEdges:JRTViewPinTopEdge inset:0];
            }];
        }
        self.moved = NO;
    }
}

- (void)slideBannerView {
    [UIView animateWithDuration:0.25 animations:^{
        [self.notificationBannerView setCenter:CGPointMake(self.notificationBannerView.center.x, -self.notificationBannerView.frame.size.height)];
    } completion:^(BOOL finished) {
        [self bannerDismissTimerDidTick];
    }];
}

- (void)bannerDismissTimerDidTick {
    __weak DPUINotificationController *weakSelf = self;
    if (self.queuedNotifications.count > 0) {
        [self dismissNotificationBannerView:^{
            NSDictionary *notification = [[weakSelf queuedNotifications] firstObject];
            [[weakSelf queuedNotifications] removeObject:notification];
            [weakSelf pushNotificationReceived:notification];
        }];
    } else {
        [self dismissNotificationBannerView:^{
            [weakSelf.bannerDismissTimer invalidate];
            weakSelf.bannerDismissTimer = nil;
        }];
    }
}

- (void)dismissNotificationBannerView:(void (^)(void))completion {
    // Disable touch events on the banner
    self.notificationBannerView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.notificationBannerView setCenter:CGPointMake(self.notificationBannerView.center.x, -self.notificationBannerView.frame.size.height)];
    } completion:^(BOOL finished) {
        [self.notificationBannerView removeFromSuperview];
        self.notificationBannerView = nil;
        [self reduceAppBadge:1];
        if(completion)
            completion();
    }];
}

@end

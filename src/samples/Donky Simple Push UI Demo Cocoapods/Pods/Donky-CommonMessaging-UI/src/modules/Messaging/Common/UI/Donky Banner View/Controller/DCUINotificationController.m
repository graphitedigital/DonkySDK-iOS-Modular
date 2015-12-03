//
//  DCUINotificationController.m
//  RichInbox
//
//  Created by Donky Networks on 16/06/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import "DCUINotificationController.h"
#import "UIView+AutoLayout.h"
#import "UIViewController+DNRootViewController.h"
#import "DCUIMainController.h"

static CGFloat const DCUINotificationBannerDismissTime = 10.0f;

@interface DCUINotificationController ()

@property(nonatomic, strong) NSArray *notificationBannerViewTopEdge;
@property(nonatomic, strong) NSTimer *bannerDismissTimer;
@property(nonatomic, strong) NSMutableArray *queuedNotifications;
@property(nonatomic, strong) NSLayoutConstraint *bannerViewHeightConstraint;
@property(nonatomic) CGRect bannerOriginalFrame;
@property(nonatomic, getter=hasMoved) BOOL moved;
@property(nonatomic) CGPoint originalCenter;
@end

@implementation DCUINotificationController

- (void)presentNotification:(DCUIBannerView *)notificationBannerView {

    //Only present this if it hasn't already been seen:
    UIViewController *presentingViewController = [UIViewController applicationRootViewController];
    if ([presentingViewController view] && ![self notificationBannerView]) {

        //Create view
        [self setNotificationBannerView:notificationBannerView];
        [[self notificationBannerView] setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [[presentingViewController view] addSubview:[self notificationBannerView]];

        [self calculateBannerViewHeightForPresentingView:[presentingViewController view] animateChange:NO];
        [[self notificationBannerView] layoutIfNeeded];

        [[self notificationBannerView] pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        [self setNotificationBannerViewTopEdge:[self.notificationBannerView pinToSuperviewEdges:JRTViewPinTopEdge inset:-[[self notificationBannerView] frame].size.height]];

        [[self bannerDismissTimer] invalidate];

        if (![[self notificationBannerView] buttonView]) {
            [self setBannerDismissTimer:[NSTimer scheduledTimerWithTimeInterval:DCUINotificationBannerDismissTime target:self selector:@selector(bannerDismissTimerDidTick) userInfo:nil repeats:NO]];
        }

        [self performSelector:@selector(presentView) withObject:nil afterDelay:0.50];

    }
    else {
        if (![self queuedNotifications]) {
            [self setQueuedNotifications:[[NSMutableArray alloc] init]];
        }

        __block BOOL duplicate = NO;
        [[self queuedNotifications] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DCUIBannerView *bannerView = obj;
            if ([[bannerView messageID] isEqualToString:[[self notificationBannerView] messageID]]) {
                duplicate = YES;
                *stop = YES;
            }
        }];
        
        if (!duplicate) {
            if ([[notificationBannerView messageID] isEqualToString:[[self notificationBannerView] messageID]]) {
                duplicate = YES;
            }
        }
        
        if (!duplicate) {
            [[self queuedNotifications] addObject:notificationBannerView];
        }
    }
}


- (void)calculateBannerViewHeightForPresentingView:(UIView *)presentingView animateChange:(BOOL)animate {

    if ([self bannerViewHeightConstraint]) {
        [[self notificationBannerView] layoutIfNeeded];
        [[self notificationBannerView] removeConstraint:[self bannerViewHeightConstraint]];
    }
    
    CGFloat stringHeight = [DCUIMainController sizeForString:[[[self notificationBannerView] messageLabel] text]font:[[[self notificationBannerView] messageLabel] font]
                                                   maxHeight:CGFLOAT_MAX
                                                    maxWidth:[presentingView frame].size.width - 100].height;

    //buffer for buttons:
    CGFloat buffer = [[self notificationBannerView] buttonView] ? 60 : 10;
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            if (stringHeight > 40) {
                [self setBannerViewHeightConstraint:[[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                        toSameAttributeOfItem:[[self notificationBannerView] messageLabel]
                                                                                 withConstant:buffer]];
            }
            else {
                [self setBannerViewHeightConstraint:[[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                          toSameAttributeOfItem:[[self notificationBannerView] avatarImageView]
                                                                                   withConstant:buffer]];
            }

            [[self notificationBannerView] layoutIfNeeded];
        } completion:nil];
    }
    else {
        if (stringHeight > 40) {
            [self setBannerViewHeightConstraint:[[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                      toSameAttributeOfItem:[[self notificationBannerView] messageLabel]
                                                                               withConstant:buffer]];
        }
        else {
            [self setBannerViewHeightConstraint:[[self notificationBannerView] pinAttribute:NSLayoutAttributeBottom
                                                                      toSameAttributeOfItem:[[self notificationBannerView] avatarImageView]
                                                                               withConstant:buffer]];
        }
    }

    [self setBannerOriginalFrame:[[self notificationBannerView] frame]];
}

- (void)loadDefaultAvatar {
    [[self notificationBannerView] loadDefaultAvatar];
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture {

    if (![self hasMoved]) {
        [self setBannerOriginalFrame:[[panGesture view] frame]];
        [self setOriginalCenter:[[panGesture view] center]];
    }
    if ([panGesture state] != UIGestureRecognizerStateEnded) {
        if (![self hasMoved]) {
            [self setMoved:YES];
        }

        CGPoint translation = [panGesture translationInView:[panGesture view]];
        if (([[panGesture view] frame].origin.y + translation.y) < [self bannerOriginalFrame].origin.y) {
            [[panGesture view] setCenter:CGPointMake([panGesture view].center.x, [panGesture view].center.y + translation.y)];
            [panGesture setTranslation:CGPointMake(0, 0) inView:[panGesture view]];
        }
    }
    else {
        if ([panGesture view].center.y < 20)
            [self slideBannerView];
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [panGesture view].center = CGPointMake([panGesture view].center.x, [self originalCenter].y);
            } completion:^(BOOL finished) {
                if (finished) {
                    [self setNotificationBannerViewTopEdge:[self.notificationBannerView pinToSuperviewEdges:JRTViewPinTopEdge inset:0]];
                }
            }];
        }
        [self setMoved:NO];
    }
}

- (void)slideBannerView {
    [UIView animateWithDuration:0.25 animations:^{
        [[self notificationBannerView] setCenter:CGPointMake([self notificationBannerView].center.x, -[[self notificationBannerView] frame].size.height)];
    } completion:^(BOOL finished) {
        [self bannerDismissTimerDidTick];
    }];
}

- (void)bannerDismissTimerDidTick {
    __weak DCUINotificationController *weakSelf = self;
    if ([[self queuedNotifications] count] > 0) {
        [self dismissNotificationBannerView:^{
            DCUIBannerView *notification = [[weakSelf queuedNotifications] firstObject];
            [[weakSelf queuedNotifications] removeObject:notification];
            [weakSelf presentNotification:notification];
            if (![notification buttonView]) {
                [notification configureGestures];
            }
        }];
    } else {
        [self dismissNotificationBannerView:^{
            [[weakSelf bannerDismissTimer] invalidate];
            [weakSelf setBannerDismissTimer:nil];
        }];
    }
}

- (void)dismissNotificationBannerView:(void (^)(void))completion {
    // Disable touch events on the banner
    [[self notificationBannerView] setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [[self notificationBannerView] setCenter:CGPointMake([self notificationBannerView].center.x, -[[self notificationBannerView] frame].size.height)];
    } completion:^(BOOL finished) {
        [[self notificationBannerView] removeFromSuperview];
        [self setNotificationBannerView:nil];
        if(completion) {
            completion();
        }
    }];
}

- (void)presentView {
    UIViewController *presentingViewController = [UIViewController applicationRootViewController];
    [UIView animateWithDuration:0.25f animations:^{
        [[presentingViewController view] removeConstraints:self.notificationBannerViewTopEdge];
        [self setNotificationBannerViewTopEdge:[[self notificationBannerView] pinToSuperviewEdges:JRTViewPinTopEdge inset:0]];
        [[presentingViewController view] layoutIfNeeded];
        [DCUIMainController addGestureToView:[self notificationBannerView] withDelegate:self withSelector:@selector(panGesture:)];
    }];
}

@end

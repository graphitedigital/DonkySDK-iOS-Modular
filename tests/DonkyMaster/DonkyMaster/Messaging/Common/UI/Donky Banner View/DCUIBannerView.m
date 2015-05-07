//
//  DCUIBannerView.m
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DCUIBannerView.h"
#import "UIView+AutoLayout.h"
#import "DNAssetController.h"
#import "DCUINotificationViewHelper.h"
#import "DNDonkyCore.h"
#import "DCMConstants.h"

@interface DCUIBannerView ()
@property(nonatomic, strong) UIActivityIndicatorView *activityView;
@property(nonatomic, strong) UILabel *displayNameLabel;
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UILabel *nowLabel;
@property(nonatomic, readwrite) UIImageView *avatarImageView;
@property(nonatomic, readwrite) UILabel *messageLabel;
@end

@implementation DCUIBannerView

- (instancetype)initWithSenderDisplayName:(NSString *)displayName body:(NSString *)body messageSentTime:(NSDate *)sentTime avatarAssetID:(NSString *)assetId {

    self = [super initWithFrame:CGRectZero];

    if (self) {

        self.backgroundView = [UIView autoLayoutView];
        [self.backgroundView setBackgroundColor:[UIColor blackColor]];
        [self.backgroundView setAlpha:0.95];
        [self addSubview:self.backgroundView];

        [self.backgroundView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];

        [self configureBasicView:displayName notificationBody:body messageSent:sentTime avatartAssetID:assetId];
    }

    return self;
}


- (void)configureGestures {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)singleTap:(UITapGestureRecognizer *)singleTap {
    DNLocalEvent *buttonTappedEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventSimplePushTapped publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:self];
    [[DNDonkyCore sharedInstance] publishEvent:buttonTappedEvent];
}

- (void)configureBasicView:(NSString *)senderDisplayName notificationBody:(NSString *)body messageSent:(NSDate *)messageSent avatartAssetID:(NSString *)avatarID {
    
    self.avatarImageView = [UIImageView autoLayoutView];
    [self.avatarImageView setImage:[UIImage imageNamed:@"avatar_default.png"]];
    self.avatarImageView.layer.borderWidth = 1.0f;
    self.avatarImageView.layer.borderColor = [[UIColor colorWithRed:149.0f/255.0f green:151.0f/255.0f blue:153.0f/255.0f alpha:1.0f] CGColor];

    [self.backgroundView addSubview:self.avatarImageView];

    [self.avatarImageView pinToSuperviewEdges:JRTViewPinLeftEdge inset:10];
    [self.avatarImageView pinToSuperviewEdges:JRTViewPinTopEdge inset:30];
    [self.avatarImageView constrainToSize:CGSizeMake(46, 46)];

    self.activityView = [UIActivityIndicatorView autoLayoutView];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activityView setHidesWhenStopped:YES];
    [self.backgroundView addSubview:self.activityView];
    [self.activityView centerInView:self.avatarImageView];

    //// Display label:
    self.displayNameLabel = [UILabel autoLayoutView];
    [self.displayNameLabel setText:senderDisplayName];
    self.displayNameLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.displayNameLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    self.displayNameLabel.textColor = [UIColor whiteColor];
    [self.backgroundView addSubview:self.displayNameLabel];

    [self.displayNameLabel pinToSuperviewEdges:JRTViewPinLeftEdge inset:66];
    [self.displayNameLabel pinAttribute:NSLayoutAttributeTop toSameAttributeOfItem:self.avatarImageView];

    //Detail Label:
    self.messageLabel = [UILabel autoLayoutView];
    [self.messageLabel setText:body];
    [self.messageLabel setNumberOfLines:2];
    [self.messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.backgroundView addSubview:self.messageLabel];

    [self.messageLabel pinToSuperviewEdges:JRTViewPinLeftEdge inset:66];
    [self.messageLabel pinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeBottom ofItem:self.displayNameLabel];

    self.nowLabel = [UILabel autoLayoutView];
    [self.nowLabel setText:[DCUINotificationViewHelper nowLabelText:messageSent]];
    self.nowLabel.textColor = [UIColor colorWithRed:109.0f/255.0f green:110.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
    self.nowLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.backgroundView addSubview:self.nowLabel];

    [self.nowLabel pinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeRight ofItem:self.displayNameLabel withConstant:10];
    [self.nowLabel pinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeTop ofItem:self.messageLabel];
    [self.nowLabel pinAttribute:NSLayoutAttributeTop toSameAttributeOfItem:self.displayNameLabel];
    [self.activityView startAnimating];

    //We only download the avatar if there's an asset ID;
    if (avatarID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *avatar = [DNAssetController avatarAssetForID:avatarID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self avatarImageView] setImage:avatar];
                [[self avatarImageView] setNeedsDisplay];
                [self.activityView stopAnimating];
            });
        });
    }
}

@end

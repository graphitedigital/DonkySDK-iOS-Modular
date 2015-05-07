//
//  DPUIBannerView.m
//  PushUI
//
//  Created by Chris Watson on 15/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "UIView+AutoLayout.h"
#import "DPUIBannerView.h"
#import "DPUIInteractiveNotificationButton.h"
#import "DPUINotification.h"
#import "DPConstants.h"
#import "DNLocalEvent.h"
#import "DNDonkyCore.h"
#import "NSDate+DNDateHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNConstants.h"
#import "DCMConstants.h"

static NSString *const DPUIButtonSetActions = @"buttonSetActions";

@interface DPUIBannerView ()
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIView *buttonBorder;
@property(nonatomic, readwrite) UIView *buttonView;
@end

@implementation DPUIBannerView

- (instancetype)initWithNotification:(DPUINotification *) notification {

    self = [super initWithSenderDisplayName:[notification senderDisplayName] body:[notification body] messageSentTime:[notification sentTimeStamp] avatarAssetID:[notification avatarAssetID]];

    if (self) {

        if ([[notification buttonSets] count])
            [self addButtons:notification];
    }

    return self;
}

- (void)addButtons:(DPUINotification *)notification {

    NSDictionary *mobile = [[notification buttonSets] firstObject];

    NSArray *buttonActions = mobile[DPUIButtonSetActions];

    if ([buttonActions count] > 1) {

        if (!self.buttonView) {
            self.buttonView = [UIView autoLayoutView];
            [self.buttonView setBackgroundColor:[UIColor clearColor]];
            [self.backgroundView addSubview:self.buttonView];

            [self.buttonView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];
        }

        //Create the containerView
        self.buttonBorder = [UIView autoLayoutView];
        [self.buttonBorder setBackgroundColor:[UIColor whiteColor]];
        [self.buttonView addSubview:self.buttonBorder];

        [self.buttonBorder pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        [self.buttonBorder constrainToHeight:1.0];

        //User to pin the edges of the buttons to the center of the view.
        UIView *centerMarker = [UIView autoLayoutView];
        [self.buttonView addSubview:centerMarker];

        [centerMarker centerInContainerOnAxis:NSLayoutAttributeCenterX];
        [centerMarker pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0];
        [centerMarker constrainToSize:CGSizeMake(2, 2)];

        //Add the buttons
        DPUIInteractiveNotificationButton *buttonOne = [self getButtonFromData:[buttonActions firstObject] withUserInfo:notification];
        [self.buttonView addSubview:buttonOne];

        [buttonOne pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinBottomEdge inset:10.0];
        [buttonOne pinAttribute:NSLayoutAttributeRight toAttribute:NSLayoutAttributeLeft ofItem:centerMarker withConstant:-10];

        DPUIInteractiveNotificationButton *buttonTwo = [self getButtonFromData:[buttonActions lastObject] withUserInfo:notification];
        [self.buttonView addSubview:buttonTwo];

        [buttonTwo pinToSuperviewEdges:JRTViewPinRightEdge | JRTViewPinBottomEdge inset:10.0];
        [buttonTwo pinAttribute:NSLayoutAttributeLeft toAttribute:NSLayoutAttributeRight ofItem:centerMarker withConstant:10];

        [self.buttonBorder pinAttribute:NSLayoutAttributeBottom toAttribute:NSLayoutAttributeTop ofItem:buttonOne withConstant:-10];
    }

        //We make the whole view a button
    else {
        DPUIInteractiveNotificationButton *buttonOne = [self getButtonFromData:[buttonActions firstObject] withUserInfo:notification];
        [buttonOne setBackgroundColor:[UIColor clearColor]];
        [self.backgroundView addSubview:buttonOne];

        [buttonOne pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];
    }
}


- (DPUIInteractiveNotificationButton *)getButtonFromData:(NSDictionary *)dictionary withUserInfo:(DPUINotification *)notification {

    DPUIInteractiveNotificationButton *button = [DPUIInteractiveNotificationButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button setClipsToBounds:NO];
    [[button layer] setCornerRadius:10.0];
    [button setTitle:dictionary[@"label"] forState:UIControlStateNormal];
    [[button titleLabel] setTextAlignment:NSTextAlignmentLeft];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(performButtonAction:) forControlEvents:UIControlEventTouchUpInside];

//    //Get it's action:
    NSString *action = dictionary[@"actionType"];
    [button setButtonActionType:action];
    [button setActionData:dictionary[@"data"]];
    [button setMessageId:[notification messageID]];
    [button setSenderInternalUserId:[notification senderInternalUserID]];
    [button setSenderMessageId:[notification senderMessageID]];
    [button setContextItems:[notification contextItems]];
    [button setCreatedOn:[notification messageSentTimeStamp]];
    [button setButtonSets:[notification buttonSets]];

    return button;
}

- (void)performButtonAction:(DPUIInteractiveNotificationButton *)button {

    if (![[button buttonActionType] isEqualToString:@"Dismiss"]) {
        DNLocalEvent *actionDataEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventInteractivePushData
                                                                      publisher:NSStringFromClass([self class])
                                                                      timeStamp:[NSDate date]
                                                                           data:[button actionData]];
        [[DNDonkyCore sharedInstance] publishEvent:actionDataEvent];
    }

    NSDate *interactionDate = [NSDate date];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params dnSetObject:kDNMiscOperatingSystem forKey:@"operatingSystem"];
    [params dnSetObject:[interactionDate donkyDateForServer] forKey:@"interactionTimeStamp"];

    //First button set index:
    NSArray *buttonSetAction = [[button buttonSets] firstObject][@"buttonSetActions"];

    if (!button.titleLabel.text.length)
        [params dnSetObject:[buttonSetAction count] == 2 ? @"Button2" : @"Button1" forKey:@"userAction"];
    else
        [params dnSetObject:[[buttonSetAction firstObject][@"label"] isEqualToString:button.titleLabel.text] ? @"Button1" : @"Button2" forKey:@"userAction"];

    [params dnSetObject:[[button buttonSets] firstObject][@"interactionType"] forKey:@"interactionType"];

    [params dnSetObject:[NSString stringWithFormat:@"%@|%@", [buttonSetAction firstObject][@"label"] ? : @"", [buttonSetAction lastObject][@"label"] ? : @""] forKey:@"buttonDescription"];

    //Set request ids:
    [params dnSetObject:button.senderInternalUserId forKey:@"senderInternalUserId"];
    [params dnSetObject:button.senderMessageId forKey:@"senderMessageId"];
    [params dnSetObject:button.messageId forKey:@"messageId"];

    [params dnSetObject:[button.createdOn donkyDateForServer] forKey:@"messageSentTimeStamp"];
    
    double timeToInteract = [interactionDate timeIntervalSinceDate:button.createdOn];
    
    if (isnan(timeToInteract))
        timeToInteract = 0;
    
    [params dnSetObject:@(timeToInteract) forKey:@"timeToInteractionSeconds"];
    
    [params dnSetObject:[buttonSetAction count] == 2 ? @"twoButton" : @"oneButton" forKey:@"interactionType"];

    [params dnSetObject:button.contextItems forKey:@"contextItems"];

    DNLocalEvent *interactionResult = [[DNLocalEvent alloc] initWithEventType:@"InteractionResult" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:params];

    [[DNDonkyCore sharedInstance] publishEvent:interactionResult];
    
    
    DNLocalEvent *pushTappedEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventSimplePushTapped publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:[button actionData]];
    [[DNDonkyCore sharedInstance] publishEvent:pushTappedEvent];

}

@end

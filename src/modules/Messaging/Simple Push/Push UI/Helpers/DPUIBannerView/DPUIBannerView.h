//
//  DPUIBannerView.h
//  PushUI
//
//  Created by Chris Watson on 15/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUIBannerView.h"

@class DPUINotification;

@interface DPUIBannerView : DCUIBannerView

@property(nonatomic, readonly) UIView *buttonView;

- (instancetype)initWithNotification:(DPUINotification *)notification;

@end

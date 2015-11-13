//
//  DPUIBannerView.h
//  PushUI
//
//  Created by Donky Networks on 15/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUIBannerView.h"
#import "DPUINotification.h"

@interface DPUIBannerView : DCUIBannerView

/*!
 Initialiser method for a Banner view with Simple push content.
 
 @param notification the server notification containing the Simple Push details.
 
 @return a new instance of a DPUIBannerView
 
 @since 2.0.0.0
 */
- (instancetype)initWithNotification:(DPUINotification *)notification;

@end

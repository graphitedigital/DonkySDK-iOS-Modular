//
//  DCUINewBannerView.h
//  RichInbox
//
//  Created by Donky Networks on 08/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUITheme.h"

@interface DCUINewBannerView : UIView

/*!
 The text label of the banner view.
 
 @since 2.2.2.7
 */
@property(nonatomic, strong) UILabel *textLabel;

/*!
 The bottome constraint of the banner view.
 
 @since 2.6.5.4
 */
@property(nonatomic, strong) NSLayoutConstraint *bottomConstraint;

/*!
 Initialiser to create a 'NEW' banner view in the Inboxes to illustrate unread messages.
 
 @param text the text to display in the banner.
 
 @return a new DCUINewBannerView
 
 @since 2.2.2.7
 */
- (instancetype)initWithText:(NSString *)text;

@end

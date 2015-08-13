//
//  DCUINewBannerView.h
//  RichInbox
//
//  Created by Chris Watson on 08/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
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
 Initialiser to create a 'NEW' banner view in the Inboxes to illustrate unread messages.
 
 @param text the text to display in the banner.
 
 @return a new DCUINewBannerView
 
 @since 2.2.2.7
 */
- (instancetype)initWithText:(NSString *)text;

@end

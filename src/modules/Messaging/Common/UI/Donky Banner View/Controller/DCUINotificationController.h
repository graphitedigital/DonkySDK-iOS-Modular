//
//  DCUINotificationController.h
//  RichInbox
//
//  Created by Donky Networks on 16/06/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCUIBannerView.h"

@interface DCUINotificationController : NSObject

/*!
 The banner view that is currently being dispalyed.
 
 @since 2.2.2.7
 */
@property(nonatomic, strong) DCUIBannerView *notificationBannerView;

/*!
 Method to present a new banner view, if there is already one being dispalyed, these are queued, 
 the next ones being displayed once the original one dismisses.
 
 @param notificationBannerView the banner view that should be presented.
 
 @since 2.2.2.7
 */
- (void)presentNotification:(DCUIBannerView *)notificationBannerView;

/*!
 Method used to dismiss the currently displaying banner view, this will also present a new banner if
 there are any in the queue.
 
 @since 2.2.2.7
 */
- (void)bannerDismissTimerDidTick;

/*!
 Helper method to overide the attempt of loading an avatar. This will display the 
 default 'message' image.
 
 @since 2.4.3.1
 */
- (void)loadDefaultAvatar;

@end

//
//  DPUINotificationController.h
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DCUIBannerView;
@class DPPushNotificationController;
@class DNLocalEvent;

/*!
 Main controller to handle the presentation of the internal banner view, when a notification is received or processed by Donky.
 */
@interface DPUINotificationController : NSObject <UIGestureRecognizerDelegate>

/*!
 Singleton object:

 @return a new shared instance of DPUINotificationController

 @since 2.0.0.0
 */
+(DPUINotificationController *)sharedInstance;

/*!
 Initialiser method.
 
 @return a new instance of DPUINotificationController
 
 @since 2.0.0.0
 */
- (instancetype)init;

/*!
 Start the push ui

 @since 2.0.0.0
 */
- (void)start;

/*!
  Stop the push ui

  @since 2.0.0.0
 */
- (void)stop;

/*!
 Method to handle incoming remote notifications.
 
 @param notificationData the data for the remote notification/
 
 @since 2.0.0.0
 */
- (void)pushNotificationReceived:(NSDictionary *)notificationData;

@end

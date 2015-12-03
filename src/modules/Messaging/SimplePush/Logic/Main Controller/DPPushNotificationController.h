//
//  DPPushNotificationController.h
//  DonkyPushModule
//
//  Created by Donky Networks on 13/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNModuleDefinition.h"
#import "DNLocalEvent.h"
#import "DNSubscription.h"

/*!
 The main controller responsible for processing incoming notifications.
 
 @since 2.0.0.0
 */
@interface DPPushNotificationController : NSObject

///*!
// An array containing pending push notifications. Notifications are added to this array when they are used to open
// the app by the user. These notifications will not be displayed internally by the banner view.
// 
// @since 2.0.0.0
// */
//@property (nonatomic, strong) NSMutableArray *pendingPushNotifications;

/*!
 The current simple push message that is being displayed.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) DNSubscription *simplePushMessage;

/*!
 Singleton instance to hold the module
 
 @return new instance
 */
+ (DPPushNotificationController *) sharedInstance;

/*!
 Initialiser method.

 @return new instance of DPPushNotificationController.

 @since 2.0.0.0
 */
- (instancetype)init;

/*!
 Start the push logic
 */
- (void)start;

/*!
 Stop the push logic:
 */
- (void)stop;

@end

//
//  DPPushNotificationController.h
//  DonkyPushModule
//
//  Created by Chris Watson on 13/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DNModuleDefinition;
@class DNLocalEvent;

//Block for getting deep link
typedef void (^DPInteractiveDeepLink) (NSString *buttonAction);

/*!
 The main controller responsible for processing incoming notifications.
 
 @since 2.0.0.0
 */
@interface DPPushNotificationController : NSObject

/*!
 Singleton instance to hold the module
 
 @return new instance
 */
+ (DPPushNotificationController *) sharedInstance;

/*!
 Start the push logic
 
 */
- (void)start;

/*!
 Stop the push logic:
 
 */
- (void)stop;


/*!
 An array containing pending push notifications. Notifications are added to this array when they are used to open
 the app by the user. These notifications will not be dispalyed internally by the banner view. 
 
 @since 2.0.0.0
 */
@property(nonatomic, strong) NSMutableArray *pendingPushNotifications;

/*!
 Initialiser method.
 
 @return new instance of DPPushNotificationController.
 
 @since 2.0.0.0
 */
- (instancetype)init;

/*!
 Method to reduce the Apps badge count by a specified amount.
 
 @param count the number by which to reduce the apps badge count.
 
 @since 2.0.0.0
 */
- (void)minusAppIconCount:(NSInteger)count;

@end

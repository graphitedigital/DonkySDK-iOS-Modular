//
//  DNNotificationController.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNBlockDefinitions.h"

/*!
 Helper class to register/unRegister a devices push notification token with the network. As well as other 
 notificaiton and application badge count related tasks.
 
 @since 2.0.0.0
 */
@interface DNNotificationController : NSObject

/*!
 Method to request push notification permission from the user.
 
 @since 2.0.0.0
 */
+ (void)registerForPushNotifications;

/*!
 Method to register the token against the current device on the network. NOTE: THis is the method that must be called in the application delegate's application:didRegisterForRemoteNotificationsWithDeviceToken:
 
 @param token the token data object returned to the application delegate.
 
 @since 2.0.0.0
 */
+ (void)registerDeviceToken:(NSData *)token;

/*!
 Additional method to register an APNS audio file on the network as well as a file.
 
 @param token         the device token
 @param soundFileName the sound file name e.g. donky.mp3
 
 @since 2.4.4.2
 */
+ (void)registerDeviceToken:(NSData *)token remoteNotificationSound:(NSString *)soundFileName;

/*!
 Method to update the native remote notification audio file.
 
 @param soundFileName the name of the audio file. e.g. donky.mp3
 @param successBlock block that is called when the initialisation is successful.
 @param failureBlock block that is called when the initialisation fails.
 
 @since 2.4.4.1
 */
+ (void)setRemoteNotificationSoundFile:(NSString *)soundFileName successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure;

/*!
 Method to handle all incoming remote notifications. Use this method for the following application delegate callbacks:
 application:didReceiveRemoteNotification:, application:didReceiveRemoteNotification:, application:handleActionWithIdentifier:forRemoteNotification:.
 
 @param userInfo   the user info dictionary containing the remote notification payload.
 @param identifier identifier of the button pressed to launch the application. NOTE: only used for interactive remote notifications. iOS 8.0 + only.
 @param handler    a completion handler, this is used internally by the SDK to return any deep links/data embedded in a button action of notification.
 
 @since 2.0.0.0
 */
+ (void)didReceiveNotification:(NSDictionary *)userInfo handleActionIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *))handler;

/*!
  Method to disable remote notifications. Remote notifications are set to enable by default upon registration. Thereafter, calling this method with false will trigger the SDK to remove the token from the network and this device will no longer be sent remote notifications. Calling it again with true will trigger the device token to be sent to the network again.
 
 @param disable whether push should be disable or enabled.
 
 @since 2.0.0.0
 */
+ (void)enablePush:(BOOL)disable;

/*!
 Helper method to reset the badge count, this will get the total count of all unread messages and 
 set the badge count to that value.
 
 @since 2.4.3.1
 */
+ (void)resetApplicationBadgeCount;

/*!
 Helper method to add custom cateogries to the remote notificaiton sets used by the SDK.
 
 @param categories the cateogries that you wish to add to the registered set.
 
 @since 2.6.5.4
 */
+ (void)addCategoriesToRemoteNotifications:(NSMutableSet *)categories;

/*!
 Method to handle the custom action attached to a remote mention. Invoke this from the Application Delegate method of the same signature.
 
 @param identifier        the identifier for the button set whoms button has been tapped.
 @param userInfo          the user info from the notification.
 @param responseInfo      any repsonse info, this is typically from a text field on a remote notification.
 @param completionHandler the completion handler that is to be invoked.
 
 @since 2.6.5.4
 */
+ (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler;

@end

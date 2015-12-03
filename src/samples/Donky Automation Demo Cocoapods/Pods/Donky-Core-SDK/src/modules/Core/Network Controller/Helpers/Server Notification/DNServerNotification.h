//
//  DNServerNotification.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 A native object representing the data returned from a server notification. This is the object that is passed to all modules that subscribe for Notifications.
 */
@interface DNServerNotification : NSObject

/*!
 The ID of the notification on the server.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *serverNotificationID;

/*!
 The type of notification.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *notificationType;

/*!
 The time that the notification was created on the network.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSDate *createdOn;

/*!
 The data inside the notification.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSDictionary *data;

/*!
 Initialiser to create a new Server Notification from a Dictionary object.
 
 @param notification the server notification with which to create the local object.
 
 @return a new DNServerNotification object with the provided details.
 
 @since 2.0.0.0
 */
- (instancetype)initWithNotification:(NSDictionary *)notification;

@end

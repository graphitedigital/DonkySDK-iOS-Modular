//
//  DNSubscription.h
//  Core Container
//
//  Created by Chris Watson on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @param data data that is returned from the invoking method.
 
 @since 2.0.0.0
 */
typedef void (^DNSubscriptionHandler) (id data);

/*!
  Class create a Subscription object. This is used when subscribing for notifications & Outbound Notification.
 
 @since 2.0.0.0
 */
@interface DNSubscription : NSObject

/*!
 The type of notification that this subscriber is interested in. DNConstants for a list of Donky notification types.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSString *notificationType;

/*!
 The handler that is to be invoked when this subscriber is triggered.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) DNSubscriptionHandler handler;

/*!
 Initialiser method to create the DNSubscription object with the user configurable options.
 
 @param notificationType the notification type this subscriber is interested in.
 @param handler          the handler that is to be invoked when this subscriber is triggered.
 
 @return a new DNSubscription object.
 
 @since 2.0.0.0
 */
- (instancetype) initWithNotificationType:(NSString *)notificationType handler:(DNSubscriptionHandler)handler;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
@property (nonatomic, getter=shouldAutoAcknowledge) BOOL autoAcknowledge;

@end

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
 @param batch an array of data that is returned from the inboking method.
 
 @since 2.2.2.7
 */
typedef void (^DNSubscriptionBachHandler) (NSArray *batch);

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
 The handler that is to be invoked when this subscriber is triggered, this differs from the
 DNSubscriptionHandler in that it allows batch objects to be returned. It will return an array of 
 objects rather than 1 at a time. Use this when you are expecting a large number of the same 
 notification types.
 
 @since 2.2.2.7
 */
@property(nonatomic, readonly) DNSubscriptionBachHandler batchHandler;

/*!
 Initialiser method to create the DNSubscription object with the user configurable options.
 
 @param notificationType the notification type this subscriber is interested in.
 @param handler          the handler that is to be invoked when this subscriber is triggered.
 
 @return a new DNSubscription object.
 
 @since 2.0.0.0
 */
- (instancetype)initWithNotificationType:(NSString *)notificationType handler:(DNSubscriptionHandler)handler;

/*!
 Initialiser method to create the DNSubscription object with the user configurable options.
 
 @param notificationType the notification type this subscriber is interested in.
 @param batchHandler     the handler that is to be invoked when this subscriber is triggered.
 
 @return a new DNSubscription object.
 
 @since 2.2.2.7
 */
- (instancetype)initWithNotificationType:(NSString *)notificationType batchHandler:(DNSubscriptionBachHandler)batchHandler;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
@property (nonatomic, getter=shouldAutoAcknowledge) BOOL autoAcknowledge;

@end

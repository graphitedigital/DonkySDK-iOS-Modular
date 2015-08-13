//
//  DRConstants.h
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRConstants : NSObject

/*!
 Once a rich message has been read.

 @since 2.2.2.7
 */
extern NSString * const kDRichMessageReadEvent;

/*!
 Event published when a rich message notification is tapped.
 
 @since 2.2.2.7
 */
extern NSString * const kDRichMessageNotificationTapped;

/*!
 Event published when a rich message notification is received from the 
 network.
 
 @since 2.2.2.7
 */
extern NSString * const kDRichMessageNotificationEvent;

/*!
 Local event published when the rich message logic controller should affect the badge count.
 
 @since 2.2.2.7
 */
extern NSString * const kDRichMessageBadgeCount;

/*!
 When a rich message notification is received and the information is past to the logic controller, 
 the key/value pairs contains an array of notifications that were tapped by the user.
 This is the key for that value.
 
 @since 2.2.2.7
 */
extern NSString * const kDRPendingRichNotifications;


@end

//
//  DCMMainController.h
//  Common Messaging
//
//  Created by Chris Watson on 07/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNServerNotification.h"
#import "DNMessage.h"

@interface DCMMainController : NSObject

/*!
 Helper method to record the message as delivered on the network, this will go towards analytics.
 
 @param notification the notification that was received.
 
 @since 2.0.0.0
 */
+ (void)markMessageAsReceived:(DNServerNotification *)notification;

/*!
 Helper method to mark a message as read.
 
 @param notification the notification for the message.
 
 @since 2.0.0.0
 */
+ (void)markMessageAsRead:(DNMessage *)message;

/*!
 Helper method to report the fact that a rich message has been shared via the share sheet.
 
 @param message     the message that was shared.
 @param sharedUsing the name of the service used to share the message i.e. twitter
 
 @since 2.2.2.7
 */
+ (void)reportSharingOfRichMessage:(DNMessage *)message sharedUsing:(NSString *)sharedUsing;

@end

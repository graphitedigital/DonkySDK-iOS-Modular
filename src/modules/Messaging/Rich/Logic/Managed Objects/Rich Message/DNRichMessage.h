//
//  DNRichMessage.h
//  DonkyCore
//
//  Created by Chris Watson on 16/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNMessage.h"


@interface DNRichMessage : DNMessage

/*!
 If the message can be forwarded.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSNumber * canForward;

/*!
 If the user can reply to a message (requires the Chat & Contacts Modules)
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSNumber * canReply;

/*!
 If the message can be shared externally.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSNumber * canShare;

/*!
 The conversation ID on the network, used if the user has replied to the message (requires the Chat & Contacts Modules).
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * conversationID;

/*!
 The expired body for the message, this is displayed if the message has an expiration date before the default 30 days.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * expiredBody;

/*!
 For internal network use.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * externalRef;

/*!
 The description of the message, this is used to populate the inbox view detail label.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * messageDescription;

/*!
 For internal network use.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * senderAccountType;

/*!
 Used when replying to rich messages or forwarding internally (forwarding requires Chat & Contacts Modules).
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * senderExternalUserID;

/*!
 Whether the notification should be silent.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSNumber * silentNotification;

/*!
 The title of the rich message, this is used to populate the rich inbox view and the notification.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * title;

/*!
 The URL that is shared when sharing is enabled.
 
 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * urlToShare;

/*!
 The message notification ID, this is used to correlate with a remote notification that has been interacted with.

 @since 2.0.0.0
 */
@property (nonatomic, retain) NSString * notificationID;

@end

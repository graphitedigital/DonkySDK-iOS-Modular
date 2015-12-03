//
//  DCUINotification.h
//  RichInbox
//
//  Created by Donky Networks on 16/06/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNServerNotification.h"

@interface DCUINotification : NSObject

/*!
 The time that the message was sent.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSDate *sentTimeStamp;

/*!
 The time that the message expires, if not set then the message expires after 30 days.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSDate *expiryTimeStamp;

/*!
 The content of the message.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *body;

/*!
 The type of message.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *messageType;

/*!
 The id of the sender message.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *senderMessageID;

/*!
 THe ID of the message, this is used to store messages in the DB. 
 Use this when attempting to find them.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *messageID;

/*!
 For internal use only.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSDictionary *contextItems;

/*!
 For internal use only.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *senderInternalUserID;

/*!
 The ID of the avatar asset, use this in conjunction with the asset URl in order
 to retrieve the image.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *avatarAssetID;

/*!
 The display name of the user that sent the 
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *senderDisplayName;

/*!
 The button set of this notification, this is used for the interactive notifications.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSArray * buttonSets;

/*!
 For internal use only.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly) NSString *serverId;

/*!
 The intitialiser method used to create a new notification, this is used for the 
 banner views.
 
 @param notification the notification that needs a banner view to be displayed.
 
 @return a new instance of DCUINotification.
 
 @since 2.2.2.7
 */
- (instancetype)initWithNotification:(DNServerNotification *)notification;

/*!
 The initialiser method used to create a new notification but supply a custom body. By default, the 'body' value of the notifications is used
 however, there are times where this may not be appropriate.
 
 @param notification the notification that has been received.
 @param customBody   the custom body to be displayed in the notification.
 
 @return a new instance of DCUINotification.
 
 @since 2.4.3.1
 */
- (instancetype)initWithNotification:(DNServerNotification *)notification customBody:(NSString *)customBody;

/*!
 Helper method to retrieve values from the DNServerNotification object.
 
 @param key          the key of the item being retrieved.
 @param notification the notification in which the key is contained.
 
 @return a new instance of DCUINotification 
 
 @since 2.2.2.7
 */
- (id)objectForKey:(NSString *)key inNotification:(DNServerNotification *)notification;

@end

//
//  DRLogicMainController.h
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNModuleDefinition.h"
#import "DNSubscription.h"
#import "DNRichMessage.h"
#import "DNLocalEvent.h"

@interface DRLogicMainController : NSObject

/*!
 Singleton instance for Donky Rich Logic
 
 @return the current DNDonkyCore instance.
 */
+ (DRLogicMainController *) sharedInstance;

/*!
 Whether the device should vibrate when a new message has been received. A device will never 
 vibrate if the rich message was set to silent when deployed.
 
 @since 2.4.3.1
 */
@property (nonatomic, getter=shouldVibrate) BOOL vibrate;

/*!
 Method to instruct the Logic Controller to start monitoring for Rich Messages. These are processed and a local event
 is published with the rich message data.
 
 @since 2.0.0.0
 */
- (void)start;

/*!
 Method to stop the Logic for when a Rich Message is received. Any Rich Messages received after Stop is called will be
 ignored and deleted from the network.
 
 @since 2.0.0.0
 */
- (void)stop;

/*!
 Helper method to delete a rich message with the provided ID.
 
 @param messageID the id of the rich message that should be deleted.
 
 @since 2.0.0.0
 */
- (void)deleteMessage:(DNRichMessage *)richMessage  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (void)deleteMessage:(DNRichMessage *)richMessage;

/*!
 Helper method to delete more than one notification at once.
 
 @param richMessages an array of Rich message objects.
 
 @since 2.2.2.7
 */
- (void)deleteAllMessages:(NSArray *)richMessages  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (void)deleteAllMessages:(NSArray *)richMessages;

/*!
 Helper method to mark a Rich Message as read. NOTE: this must be called by the integrator when NOT using the UI. This ensures that statistics around Rich Messages is recorded and that they are not displayed more than once.
 
 @param messageID the ID of the message that should be marked as read.
 
 @since 2.0.0.0
 */
- (void)markMessageAsRead:(DNRichMessage *)message  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (void)markMessageAsRead:(DNRichMessage *)message;

/*!
 Helper method to get all rich messages who's description contains the supplied string.
 
 @param filter the string which should be sought for.
 
 @return an array of DNRichMessage objects.
 
 @since 2.0.0.0
 
 @see DNRichMessage
 */
- (NSArray *)filterRichMessages:(NSString *)filter ascending:(BOOL)ascending  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (NSArray *)filterRichMessages:(NSString *)filter ascending:(BOOL)ascending;

/*!
 Helper method to determine whether a rich message exists for the supplied message ID.
 
 @param messageID the message ID that corresponds to the message.
 
 @return bool to determine if the message exists or not.
 
 @since 2.2.2.7
 */
- (BOOL)doesRichMessageExistForID:(NSString *)messageID  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (BOOL)doesRichMessageExistForID:(NSString *)messageID;

/*!
 Helper method to retrieve a rich message from the database given a provided message ID.
 
 @param messageID the message ID for the rich message requested.
 
 @return a new rich message object.
 
 @since 2.2.2.7
 */
- (DNRichMessage *)richMessageWithID:(NSString *)messageID  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (DNRichMessage *)richMessageWithID:(NSString *)messageID;

/*!
 Helper method to process all the rich messages that have been received from APNS.
 This accepts an array of messages so that batch processing can be achieved.
 
 @param notifications an array of DNServerNotifications.
 
 @since 2.2.2.7
 */
- (void)richMessageNotificationsReceived:(NSArray *)notifications __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (void)richMessageNotificationsReceived:(NSArray *)notifications;

/*!
 Helper method to get all rich messages.
 
 @return an array of DNRichMessage objects.
 
 @since 2.0.0.1
 
 @see DNRichMessage
 */
- (NSArray *)allRichMessagesAscending:(BOOL)ascending  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (NSArray *)allRichMessagesAscending:(BOOL)ascending;

/*!
 Helper method to retrieve rich messages with an offset. This is used to to load x amount of messages at once.
 
 @param offset    how many messages to 'skip' when retrieving rich messages from the database.
 @param limit     the number of messages to retrieve.
 @param ascending whether to sort them in ascending order, they are sorted by message sent date.
 
 @return an array of rich message objects.
 
 @since 2.2.2.7
 */
- (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending;

/*!
 Helper method to get all un-read rich messages.
 
 @return an array of DNRichMessage objects.
 
 @since 2.0.0.1
 
 @see DNRichMessage
 */
- (NSArray *)allUnreadRichMessages  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (NSArray *)allUnreadRichMessages;

/*!
 Helper method to delete all the expired messages from the database.
 
 @since 2.2.2.7
 */
- (void)deleteAllExpiredMessages  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (void)deleteAllExpiredMessages;

/*!
 Helper method to delete all those messages that have reached their lifetime limit (30 days).
 
 @since 2.5.4.3
 */
- (void)deleteMaxLifeRichMessages  __attribute__((deprecated("Please use class method of same signature - 2.7.0.0")));

+ (void)deleteMaxLifeRichMessages;

@end

//
//  DRLogicMainController.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DNModuleDefinition;
@class DNSubscription;

@interface DRLogicMainController : NSObject

/*!
 Singleton instance for Donky Rich Logic
 
 @return the current DNDonkyCore instance.
 */
+ (DRLogicMainController *) sharedInstance;

/*!
 Method to instruct the Logic Controller to start monitoring for Rich Messages. These are processed and a local event is published with the rich message data.
 
 @since 2.0.0.0
 */
- (void)start;

/*!
 Method to stop the Logic for when a Rich Message is received. Any Rich Messages received after Stop is called will be ignored and deleted from the network.
 
 @since 2.0.0.0
 */
- (void)stop;

/*!
 Helper method to delete a rich message with the provided ID.
 
 @param messageID the id of the rich message that should be deleted.
 
 @since 2.0.0.0
 */
- (void)deleteMessage:(NSString *)messageID;

/*!
 Helper method to mark a Rich Message as read. NOTE: this must be called by the integrator when NOT using the UI. This ensures that statistics around Rich Messages is recorded and that they are not displayed more than once.
 
 @param messageID the ID of the message that should be marked as read.
 
 @since 2.0.0.0
 */
- (void)markMessageAsRead:(NSString *)messageID;

/*!
 Helper method to get all rich messages who's description contains the supplied string.
 
 @param filter the string which should be saught for.
 
 @return an array of DNRichMessage objects.
 
 @since 2.0.0.0
 
 @see DNRichMessage
 */
- (NSArray *)filterRichMessages:(NSString *)filter;

@end

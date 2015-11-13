//
//  DNContentNotification.h
//  Core Container
//
//  Created by Donky Networks on 19/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNClientNotification.h"

/*!
 Wrapper class used to create a content notification. These are notifications used to send custom content to the network or other app space users.
 
 @since 2.0.0.0
 */
@interface DNContentNotification : DNClientNotification

/*!
 An array of User ID's to whom the content should be sent.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSDictionary *audience;
    
/*!
 Any filters that the network should apply when processing the notification.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSArray *filters;

/*!
 The content to send with the content notification.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSDictionary *content;

/*!gi
 Any custom behaviour the be applied to the push notification when the message is received by other app space users.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSDictionary *nativePush;

/*!
 Initialiser method to quickly create a new DNContentNotification to transfer data from this device to another user(s).
 
 @param users      an array of User ID's that this content should be sent to.
 @param customType an identifier for this content so that the receiving devices know how to process the data. i.e. in a chess game you may have customType = "chessMove".
 @param data       the data to send to the users. In the chess game example you may have "king" = "A1 - A5". Representing a kings move from A1 to A5.
 
 @return a new DNContentNotification object correctly formatted with the provided data to be sent to the network.
 
 @since 2.0.0.0
 */
- (instancetype)initWithUsers:(NSArray *)users customType:(NSString *)customType data:(id) data;

/*!
 Initialiser method to create a specific DNContentNotification to transfer data from this device to other user(s). This initialiser allows you to specify more options to allow a more targeted message.
 
 @param audience   a dictionary of users to whom the message should be sent. This should be formatted in the following way:    users = [@{@"userId : @"1234"}, @{@"userId" : @"5678"}]. Where users is an array of NSDictionaries containing the key userId. This is then put inside a Type dictionary with the optional types (as of V1.0.0.0) being specifiedUsers.
 @param filters    any filters that the network should apply when processing this message i.e. send to iOS devices only.
 @param content    the content (data) that should be sent with this message. i.e. @{"type" : @"Custom", "customType" : @"CUSTOM TYPE FOR THIS DATA", @"data" : YOUR_DATA"}.
 @param nativePush any custom behaviours to apply to the native push i.e. sound file, badge count etc. i.e.
 
 @return a new DNContentNotification object correctly formatted with the provided data to be sent to the network.
 
 @since 2.0.0.0
 */
- (instancetype)initWithAudience:(NSDictionary *)audience filters:(NSArray *)filters content:(NSDictionary *)content nativePush:(NSDictionary *)nativePush;

@end

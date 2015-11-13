//
//  DNMessage.h
//  ChatLogic
//
//  Created by Donky Networks on 08/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DNMessage : NSManagedObject

@property (nonatomic, retain) NSString * avatarAssetID;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) id contextItems;
@property (nonatomic, retain) NSDate * expiryTimestamp;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * messageScope;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * senderDisplayName;
@property (nonatomic, retain) NSString * senderInternalUserID;
@property (nonatomic, retain) NSString * senderMessageID;
@property (nonatomic, retain) NSDate * sentTimestamp;
@property (nonatomic, retain) NSNumber * silentNotification;
@property (nonatomic, retain) NSNumber * canForward;
@property (nonatomic, retain) NSNumber * canReply;
@property (nonatomic, retain) NSString * externalRef;
@property (nonatomic, retain) NSString * externalID;
@property (nonatomic, retain) NSString * messageType;
@property (nonatomic, retain) NSString * senderExternalUserID;
@property (nonatomic, retain) NSString * senderAccountType;
@property (nonatomic, retain) NSString * notificationID;
@property (nonatomic, retain) NSString * conversationID;
@property (nonatomic, retain) NSDate * messageReceivedTimestamp;

@end

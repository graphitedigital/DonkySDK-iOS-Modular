//
//  DNMessage.h
//  DonkyCore
//
//  Created by Chris Watson on 16/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DNMessage : NSManagedObject

@property (nonatomic, retain) NSString * avatarAssetID;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * expiryTimestamp;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * messageScope;
@property (nonatomic, retain) NSString * senderDisplayName;
@property (nonatomic, retain) NSString * messageType;
@property (nonatomic, retain) NSDate * messageReceivedTimestamp;
@property (nonatomic, retain) NSString * senderInternalUserID;
@property (nonatomic, retain) NSString * senderMessageID;
@property (nonatomic, retain) NSDate * sentTimestamp;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) id contextItems;
@property (nonatomic, retain) NSString *notificationID;

@end

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

@property (nonatomic, retain) NSNumber * canForward;
@property (nonatomic, retain) NSNumber * canReply;
@property (nonatomic, retain) NSNumber * canShare;
@property (nonatomic, retain) NSString * conversationID;
@property (nonatomic, retain) NSString * expiredBody;
@property (nonatomic, retain) NSString * externalRef;
@property (nonatomic, retain) NSString * messageDescription;
@property (nonatomic, retain) NSString * senderAccountType;
@property (nonatomic, retain) NSString * senderExternalUserID;
@property (nonatomic, retain) NSNumber * silentNotification;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlToShare;
@property (nonatomic, retain) NSString * notificationID;

@end

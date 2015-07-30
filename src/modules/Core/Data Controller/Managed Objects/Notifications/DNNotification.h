//
//  DNNotification.h
//  DonkyCore
//
//  Created by Chris Watson on 09/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DNNotification : NSManagedObject

@property (nonatomic, retain) id audience;
@property (nonatomic, retain) id content;
@property (nonatomic, retain) id data;
@property (nonatomic, retain) id filters;
@property (nonatomic, retain) id acknowledgementDetails;
@property (nonatomic, retain) id nativePush;
@property (nonatomic, retain) NSNumber * sendTries;
@property (nonatomic, retain) NSString * serverNotificationID;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * notificationID;


@end

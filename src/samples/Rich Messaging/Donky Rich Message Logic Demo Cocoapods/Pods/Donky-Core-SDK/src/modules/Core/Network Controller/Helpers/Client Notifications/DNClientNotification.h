//
//  DNClientNotification.h
//  Core Container
//
//  Created by Chris Watson on 19/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNServerNotification.h"
#import "DNNotification.h"

@interface DNClientNotification : NSObject

@property(nonatomic, readonly) NSString *notificationID;

@property (nonatomic, readonly) NSDate *sentTime;

@property(nonatomic, strong) NSString *notificationType;

@property(nonatomic, strong) NSNumber *sendTries;

@property(nonatomic, strong) NSMutableDictionary *acknowledgementDetails;

@property(nonatomic, strong) NSDictionary *data;

- (instancetype)initWithAcknowledgementNotification:(DNServerNotification *)notification;

- (instancetype)initWithType:(NSString *)type data:(NSDictionary *)data acknowledgementData:(DNServerNotification *)notification;

- (instancetype)initWithNotification:(DNNotification *)notification;

@end

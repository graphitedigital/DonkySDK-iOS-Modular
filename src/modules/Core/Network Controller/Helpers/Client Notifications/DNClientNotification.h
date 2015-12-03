//
//  DNClientNotification.h
//  Core Container
//
//  Created by Donky Networks on 19/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNServerNotification.h"
#import "DNNotification.h"

@interface DNClientNotification : NSObject

@property (nonatomic, readonly) NSString *notificationID;

@property (nonatomic, readonly) NSDate *sentTime;

@property (nonatomic, copy) NSString *notificationType;

@property (nonatomic, copy) NSNumber *sendTries;

@property (nonatomic, strong) NSMutableDictionary *acknowledgementDetails;

@property (nonatomic, copy) NSDictionary *data;

- (instancetype)initWithNotification:(DNNotification *)notification;

- (instancetype)initWithAcknowledgementNotification:(DNServerNotification *)notification;

- (instancetype)initWithType:(NSString *)type data:(NSDictionary *)data acknowledgementData:(DNServerNotification *)notification;

@end

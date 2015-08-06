//
//  DNPushNotificationUpdate.h
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNPushNotificationUpdate : NSObject

- (instancetype) initWithPushToken:(NSString *)token;

- (instancetype)initWithMessageAlertSound:(NSString *) messageAlertSound deviceToken:(NSString *) token;

- (NSDictionary *)parameters;

@end

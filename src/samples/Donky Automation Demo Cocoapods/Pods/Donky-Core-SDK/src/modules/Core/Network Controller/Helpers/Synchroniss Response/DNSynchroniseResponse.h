//
//  DNSynchroniseResponse.h
//  Donky Network SDK Container
//
//  Created by Chris Watson on 09/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNSynchroniseResponse : NSObject

@property (nonatomic, readonly) NSArray *serverNotifications;

@property (nonatomic, readonly) NSArray *failedClientNotifications;

@property (nonatomic, readonly) BOOL moreNotificationsAvailable;

- (instancetype)initWithDonkyNetworkResponse:(NSDictionary *)response;

@end

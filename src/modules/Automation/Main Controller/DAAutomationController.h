//
//  DAAutomationController.h
//  Automation
//
//  Created by Donky Networks on 04/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAAutomationController : NSObject

/*!
 Use this method to execute a third party trigger. The trigger will be added to the Network outgoing queue and sent
 with the next synchronise.
 
 @param key        the key for the server trigger that should be fired.
 @param customData any custom data to send too.
 
 @since 2.0.0.0
 */
+ (void)executeThirdPartyTriggerWithKey:(NSString *)key customData:(NSDictionary *)customData;

/*!
 Use this method to execute a third party trigger. The trigger will sent immediately.
 
 @param key        the key for the server trigger that should be fired.
 @param customData any custom data to send too.
 
 @since 2.0.0.0
 */
+ (void)executeThirdPartyTriggerWithKeyImmediately:(NSString *)key customData:(NSDictionary *)customData;

@end

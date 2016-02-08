//
//  DLSTargetUser.h
//  Location Services
//
//  Created by Donky Networks on 22/10/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The object used to reply to and send location requests to another user. It carries two properties and a designated initialiser. 
 Only one of the properties is required.
 
 @since 2.6.6.5
 */
@interface DLSTargetUser : NSObject

/*!
 The external user ID of the target user.
 
 @since 2.6.6.5
 */
@property (nonatomic, readonly) NSString *userID;

/*!
 The network profile ID of the target user.
 
 @since 2.6.6.5
 */
@property (nonatomic, readonly) NSString *networkProfileID;

/*!
 The designated initialiser for the Target User object. You only need to provide
 one of the user IDs but providing both is acceptable.
 
 @param userID           the recipient external user ID.
 @param networkProfileID the recipient network profile ID.
 
 @return a new DLSTargetUser object with the user ids.
 
 @since 2.6.6.5
 */
- (instancetype)initWithUserID:(NSString *)userID networkProfileID:(NSString *)networkProfileID;

@end

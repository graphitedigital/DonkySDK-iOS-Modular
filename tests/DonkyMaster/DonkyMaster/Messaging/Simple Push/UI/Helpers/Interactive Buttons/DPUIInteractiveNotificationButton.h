//
//  DPUIInteractiveNotificationButton.h
//  Donky
//
//  Created by Chris Watson on 21/10/14.
//  Copyright (c) 2014 Dynmark International Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface DPUIInteractiveNotificationButton : UIButton

@property (nonatomic, strong) NSString *buttonActionType;

@property (nonatomic, strong) NSString *actionData;

@property (nonatomic, strong) NSString *senderInternalUserId;

@property (nonatomic, strong) NSString *messageId;

@property (nonatomic, strong) NSString *senderMessageId;

@property (nonatomic, strong) NSDictionary *contextItems;

@property (nonatomic, strong) NSArray *buttonSets;

@property (nonatomic, strong) NSDate *createdOn;

@end

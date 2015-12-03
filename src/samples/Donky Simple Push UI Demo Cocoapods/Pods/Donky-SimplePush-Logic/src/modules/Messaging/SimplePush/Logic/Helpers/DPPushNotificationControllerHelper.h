//
//  DPPushNotificationControllerHelper.h
//  Push Container
//
//  Created by Donky Networks on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface DPPushNotificationControllerHelper : NSObject

+ (UIMutableUserNotificationCategory *)categoryWithFirstButtonTitle:(NSString *)firstButtonTitle firstButtonIdentifier:(NSString *)firstButtonIdentifier firstButtonIsForground:(BOOL)firstButtonForeground secondButtonTitle:(NSString *)secondButtonTitle secondButtonIdentifier:(NSString *)secondButtonIdentifier secondButtonIsForeground:(BOOL)secondButtonForeground andCategoryIdentifier:(NSString *)categoryIdentifier;

@end

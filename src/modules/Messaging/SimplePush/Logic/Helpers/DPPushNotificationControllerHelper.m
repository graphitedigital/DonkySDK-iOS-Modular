//
//  DPPushNotificationControllerHelper.m
//  Push Container
//
//  Created by Donky Networks on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPPushNotificationControllerHelper.h"

@implementation DPPushNotificationControllerHelper

+ (UIMutableUserNotificationCategory *)categoryWithFirstButtonTitle:(NSString *)firstButtonTitle firstButtonIdentifier:(NSString *)firstButtonIdentifier firstButtonIsForground:(BOOL)firstButtonForeground secondButtonTitle:(NSString *)secondButtonTitle secondButtonIdentifier:(NSString *)secondButtonIdentifier secondButtonIsForeground:(BOOL)secondButtonForeground andCategoryIdentifier:(NSString *)categoryIdentifier {

    UIMutableUserNotificationAction *firstAction = [[UIMutableUserNotificationAction alloc] init];
    firstAction.title = firstButtonTitle;
    firstAction.identifier = firstButtonIdentifier;
    firstAction.activationMode = firstButtonForeground ? UIUserNotificationActivationModeForeground : UIUserNotificationActivationModeBackground;
    firstAction.destructive = NO;
    firstAction.authenticationRequired = NO;

    UIMutableUserNotificationAction *secondAction = [[UIMutableUserNotificationAction alloc] init];
    secondAction.title = secondButtonTitle;
    secondAction.identifier = secondButtonIdentifier;
    secondAction.activationMode = secondButtonForeground ? UIUserNotificationActivationModeForeground : UIUserNotificationActivationModeBackground;
    secondAction.destructive = NO;
    secondAction.authenticationRequired = NO;

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = categoryIdentifier;
    [notificationCategory setActions:@[secondAction, firstAction] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[secondAction, firstAction] forContext:UIUserNotificationActionContextMinimal];

    return notificationCategory;

}

@end

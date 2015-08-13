//
//  DRIMainControllerHelper.h
//  RichInbox
//
//  Created by Chris Watson on 23/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DNRichMessage.h"
#import "DNBlockDefinitions.h"
#import "DRIMainController.h"
#import "DCUINotificationController.h"
#import "DCUIBannerView.h"

@interface DRIMainControllerHelper : DNRichMessage

+ (DNLocalEventHandler)richMessageTapped:(DRIMainController *)mainController;

+ (DNLocalEventHandler)bannerTapped:(DRIMainController *)mainController notificationController:(DCUINotificationController *)notificationController;

+ (void)processNotifications:(NSDictionary *)notificationData notificationController:(DCUINotificationController *)notificationController richLogicController:(DRLogicMainController *)richLogicController showBannerView:(BOOL)showBannerView;

+ (DNLocalEventHandler)richMessageBadgeCount;

@end

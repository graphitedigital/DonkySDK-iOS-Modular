//
//  DRIMainControllerHelper.h
//  RichInbox
//
//  Created by Donky Networks on 23/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Donky_RichMessage_Logic/DNRichMessage.h>
#import <Donky_Core_SDK/DNBlockDefinitions.h>
#import "DRIMainController.h"

@interface DRIMainControllerHelper : DNRichMessage

+ (DNLocalEventHandler)richMessageBadgeCount;

@end

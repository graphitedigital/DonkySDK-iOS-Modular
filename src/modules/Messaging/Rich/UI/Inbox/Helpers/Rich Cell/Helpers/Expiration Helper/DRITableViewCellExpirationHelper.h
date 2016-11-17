//
//  DRITableViewCellExpirationHelper.h
//  RichInbox
//
//  Created by Donky Networks on 27/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Donky_RichMessage_Logic/DNRichMessage.h>
#import "DRITableViewCell.h"

@interface DRITableViewCellExpirationHelper : NSObject

+ (NSTimer *)expiryTimerForMessage:(DNRichMessage *)richMessage target:(DRITableViewCell *)target;

@end

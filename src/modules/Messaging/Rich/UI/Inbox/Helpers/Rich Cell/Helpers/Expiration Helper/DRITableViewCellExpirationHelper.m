//
//  DRITableViewCellExpirationHelper.m
//  RichInbox
//
//  Created by Donky Networks on 27/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "DRITableViewCellExpirationHelper.h"
#import "DNConfigurationController.h"

@implementation DRITableViewCellExpirationHelper

+ (NSTimer *)expiryTimerForMessage:(DNRichMessage *)richMessage target:(DRITableViewCell *)target {
    NSDate *expiryDate = nil;
    NSTimeInterval timeLeft = 0;

    if ([richMessage expiryTimestamp] && ![richMessage expiredBody].length) {
        expiryDate = [richMessage expiryTimestamp];
        timeLeft = [expiryDate timeIntervalSinceDate:[NSDate date]];
    }

    if (!expiryDate) {
        //Calculate date:
        NSDate *sentDate = [richMessage sentTimestamp];
        NSInteger maxDays = [DNConfigurationController richMessageAvailabilityDays];
        maxDays = maxDays * 86400; //gives you days in seconds.
        timeLeft = maxDays - [sentDate timeIntervalSinceDate:[NSDate date]];
    }

    if (timeLeft > 0) {
     return [NSTimer scheduledTimerWithTimeInterval:timeLeft target:target selector:@selector(configureCell) userInfo:nil repeats:NO];
    }

    return nil;
}

@end

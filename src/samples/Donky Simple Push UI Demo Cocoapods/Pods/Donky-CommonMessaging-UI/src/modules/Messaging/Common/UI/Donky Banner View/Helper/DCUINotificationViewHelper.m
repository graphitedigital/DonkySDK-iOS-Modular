//
//  DCUINotificationViewHelper.m
//  Push UI Container
//
//  Created by Donky Networks on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DCUINotificationViewHelper.h"
#import "DCUILocalization+Localization.h"
#import "DNSystemHelpers.h"

@implementation DCUINotificationViewHelper

+ (NSString *)nowLabelText:(NSDate *)sentDate {

    NSString *nowLabelText = DCUILocalizedString(@"dn_notification_now");

    if (!sentDate) {
        return nowLabelText;
    }

    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = nil;
    
    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        components = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:sentDate toDate:[NSDate date] options:0];
    }
    else {
        components = [currentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:sentDate toDate:[NSDate date] options:0];
    }

    if ([components year] > 0) {
        nowLabelText = [NSString stringWithFormat:@"%ld %@ ago", (long) [components year], DCUILocalizedString(@"dn_notification_years")];
    }
    else if ([components month] > 0) {
        nowLabelText = [NSString stringWithFormat:@"%ld %@ ago", (long) [components month], DCUILocalizedString(@"dn_notification_months")];
    }
    else if ([components day] > 0) {
        nowLabelText = [NSString stringWithFormat:@"%ld %@ ago", (long) [components day], DCUILocalizedString(@"dn_notification_days")];
    }
    else if ([components hour] > 0) {
        nowLabelText = [NSString stringWithFormat:@"%ld %@ ago", (long) [components hour], DCUILocalizedString(@"dn_notification_hours")];
    }
    else if ([components minute] > 0) {
        nowLabelText = [NSString stringWithFormat:@"%ld %@ ago", (long) [components minute], DCUILocalizedString(@"dn_notification_minutes")];
    }
    else {
        nowLabelText = DCUILocalizedString(@"dn_notification_now");
    }

    return nowLabelText;
}


@end

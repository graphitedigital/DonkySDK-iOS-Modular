//
//  NSDate+DCMDate.m
//  RichInbox
//
//  Created by Donky Networks on 06/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "NSDate+DCMDate.h"
#import "DCUILocalization+Localization.h"
#import <Donky_Core_SDK/DNSystemHelpers.h>

@implementation NSDate (DCMDate)

- (NSString *)donkyRelativeString {

    NSString *relativeLabel = nil;

    if (self) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setLocale:[NSLocale currentLocale]];

        NSCalendar *currentCalendar = [NSCalendar currentCalendar];

        NSDateComponents *components = nil;
        NSDateComponents *sentDateComponents = nil;
        NSDateComponents *currentDate = nil;
        
        if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
            components = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self toDate:[NSDate date] options:0];
            sentDateComponents = [currentCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:self];
            currentDate = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:[NSDate date]];
        }
        else {
            components = [currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self toDate:[NSDate date] options:0];
            sentDateComponents = [currentCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:self];
            currentDate = [currentCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
        }
        
        //If this is today and within the last 5 min:
        if ([components day] < 1 && [components minute] < 5  && [components hour] < 1) {
            relativeLabel = DCUILocalizedString(@"common_messaging_inbox_now");
        }
        //If this is today and less than an hour ago, we print out the minutes:
        else if ([components day] < 1 && [components hour] < 1) {
            relativeLabel = [NSString stringWithFormat:@"%ld %@", (long)[components minute], DCUILocalizedString(@"common_messaging_date_label_minutes")];
        }
        //If we are 1 day later:
        else if (([currentDate day] - [sentDateComponents day] == 1) && [currentDate month] == [sentDateComponents month]) {
            relativeLabel = DCUILocalizedString(@"common_messaging_date_label_yesterday");
        }
        //We are less than 1 day but more than 1 hour...
        else if ([components day] < 1 && [components hour] >= 1) {
            relativeLabel = [NSString stringWithFormat:@"%ld %@", (long)[components hour], DCUILocalizedString(@"common_messaging_date_label_hours")];
        }
        //If this isn't today but less than a week ago:
        else if ([components day] == 1) {
            relativeLabel = DCUILocalizedString(@"common_messaging_date_label_yesterday");
        }
        else if ([components day] <= 7) {
            [formatter setDateFormat:@"EEE"];
            relativeLabel = [[formatter stringFromDate:self] capitalizedString];
        }
        //Anything later, we simply print the date:
        else {
            relativeLabel = [formatter stringFromDate:self];
        }
    }

    return relativeLabel;
}

- (BOOL)needsRefresh {

    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self toDate:[NSDate date] options:0];

    if ([components day] < 1 && [components minute] < 5  && [components hour] < 1) {
        return YES;
    }
    else if ([components day] < 1 && [components hour] < 1) {
        return YES;
    }
    else if ([components day] < 1 && [components hour] <= 1) {
        return YES;
    }

    return NO;
}

- (NSInteger)nextRefresh {

    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self toDate:[NSDate date] options:0];

    if ([components day] < 1 && [components minute] < 5 && [components hour] < 1) {
        return (5 - [components minute]) * 60;
    }
    else if ([components day] < 1 && [components hour] < 1) {
        return 60 - [components second];
    }
    else if ([components day] < 1 && [components hour] <= 1) {
        return (60 * 60) - (([components minute] * 60) + [components second]);
    }

    return 1;
}

@end

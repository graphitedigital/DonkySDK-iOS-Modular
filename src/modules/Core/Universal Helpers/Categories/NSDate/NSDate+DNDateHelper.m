//
//  DKDateHelper.m
//  Logging
//
//  Created by Donky Networks on 13/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "NSDate+DNDateHelper.h"
#import "DNConstants.h"
#import "DNConfigurationController.h"
#import "DNSystemHelpers.h"

@implementation NSDate (DNDateHelper)

- (NSString *)donkyDateForServer {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)donkyDateForServerWithoutZone {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)donkyDateFromServer:(NSString *)date {
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        return [dateFormatter dateFromString:date];
    }
    return nil;
}
- (NSString *)donkyDateForDebugLog {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDNLoggingDateFormat];
    return [formatter stringFromDate:self];
}

- (BOOL)donkyHasDateExpired {
    if (!self) {
        return YES;
    }
    
    return [self compare:[NSDate date]] != NSOrderedDescending;
}

- (BOOL)donkyHasMessageExpired {
    if (!self) {
        return YES;
    }

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = nil;
    
    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        components = [calendar components:(NSCalendarUnitDay) fromDate:self toDate:[NSDate date] options:0];
    }
    else {
        components = [calendar components:(NSDayCalendarUnit) fromDate:self toDate:[NSDate date] options:0];
    }

    return ([components day] > [DNConfigurationController richMessageAvailabilityDays]);
}

- (BOOL)isDateBeforeDate:(NSDate *) secondDate {
    if (secondDate) {
        return [self compare:secondDate] != NSOrderedDescending;
    }
    
    return NO;
}

- (BOOL)isDateOlderThan24Hours {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = nil;
    
    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        components = [calendar components:(NSCalendarUnitHour) fromDate:self toDate:[NSDate date] options:0];
    }
    else {
        components = [calendar components:(NSHourCalendarUnit) fromDate:self toDate:[NSDate date] options:0];
    }

    return ([components hour] < 24);
}

- (BOOL)donkyHasReachedDate {
    return [self timeIntervalSinceNow] < 0.0;
}

@end

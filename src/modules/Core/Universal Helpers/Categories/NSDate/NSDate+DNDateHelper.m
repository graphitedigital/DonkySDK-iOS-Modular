//
//  DKDateHelper.m
//  Logging
//
//  Created by Chris Watson on 13/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "NSDate+DNDateHelper.h"
#import "DNConstants.h"

@implementation NSDate (DNDateHelper)

- (NSString *)donkyDateForServer {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)donkyDateFromServer:(NSString *)date {

    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];

        return [dateFormatter dateFromString:date];
    }

    return nil;
}

- (NSString *) donkyDateForDebugLog {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDNLoggingDateFormat];
    return [formatter stringFromDate:self];
}

- (BOOL)donkyHasDateExpired {
    if (!self)
        return YES;
    
    return [self compare:[NSDate date]] != NSOrderedDescending;
}

- (BOOL)isDateBeforeDate:(NSDate *) secondDate {
    if (secondDate)
        return [self compare:secondDate] != NSOrderedDescending;
    return NO;
}


@end

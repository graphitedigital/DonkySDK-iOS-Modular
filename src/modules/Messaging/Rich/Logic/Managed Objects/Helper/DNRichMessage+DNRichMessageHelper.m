//
//  DNRichMessage+DNRichMessageHelper.m
//  RichInbox
//
//  Created by Donky Networks on 13/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNRichMessage+DNRichMessageHelper.h"
#import <Donky_Core_SDK/NSDate+DNDateHelper.h>

@implementation DNRichMessage (DNRichMessageHelper)

- (BOOL)richHasCompletelyExpired {
    return (([[self expiryTimestamp] donkyHasDateExpired] && ![self expiredBody].length) || [[self sentTimestamp] donkyHasMessageExpired]);
}

- (BOOL)richHasReachedExpiration {
    return [[self sentTimestamp] donkyHasMessageExpired];
}

- (BOOL)canBeShared {
    return ((![[self expiryTimestamp] donkyHasDateExpired] && ![[self sentTimestamp] donkyHasMessageExpired]) && ([[self canShare] boolValue] && [[self urlToShare] length] > 0));
}

@end

//
//  DNNotification.m
//  DonkyCore
//
//  Created by Donky Networks on 09/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNNotification.h"

@implementation DNNotification

@dynamic audience;
@dynamic content;
@dynamic data;
@dynamic filters;
@dynamic acknowledgementDetails;
@dynamic nativePush;
@dynamic sendTries;
@dynamic serverNotificationID;
@dynamic type;
@dynamic notificationID;

@end
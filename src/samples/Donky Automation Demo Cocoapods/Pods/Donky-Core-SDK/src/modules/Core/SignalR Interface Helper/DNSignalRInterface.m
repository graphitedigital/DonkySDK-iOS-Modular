//
//  DNSignalRInterface.m
//  SignalR
//
//  Created by Donky Networks on 06/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "DNSignalRInterface.h"
#import "DNDonkyCore.h"
#import "DNLoggingController.h"

static NSString *const DNSignalRService = @"DonkySignalRService";

@implementation DNSignalRInterface

+ (void)openConnection {
    id serviceInstance = [[DNDonkyCore sharedInstance] serviceForType:DNSignalRService];
    if (serviceInstance) {
        SEL openConnection = NSSelectorFromString(@"start");
        ((void (*)(id, SEL))[serviceInstance methodForSelector:openConnection])(serviceInstance, openConnection);
    }
}

+ (void)closeConnection {
    id serviceInstance = [[DNDonkyCore sharedInstance] serviceForType:DNSignalRService];
    if (serviceInstance) {
        SEL openConnection = NSSelectorFromString(@"stop");
        ((void (*)(id, SEL))[serviceInstance methodForSelector:openConnection])(serviceInstance, openConnection);
    }
}

+ (BOOL)signalRServiceIsReady {

    BOOL isOpen = NO;
    id serviceInstance = [[DNDonkyCore sharedInstance] serviceForType:DNSignalRService];
    if (serviceInstance) {
        SEL isConnectionOpen = NSSelectorFromString(@"signalRIsReady");
        IMP imp = [serviceInstance methodForSelector:isConnectionOpen];
        BOOL (*func)(id, SEL) = (void*)imp;
        isOpen = func(serviceInstance, isConnectionOpen);
    }
    
    return isOpen;
}

+ (void)sendData:(id)data completion:(DNSignalRCompletionBlock)completionBlock {
    if ([DNSignalRInterface signalRServiceIsReady]) {
        SEL sendData = NSSelectorFromString(@"sendData:completion:");
        id serviceInstance = [[DNDonkyCore sharedInstance] serviceForType:DNSignalRService];
        IMP imp = [serviceInstance methodForSelector:sendData];
        if ([serviceInstance respondsToSelector:sendData]) {
            void (*func)(id, SEL, id, id) = (void*)imp;
            func(serviceInstance, sendData, data, completionBlock);
        }
    }
}


@end

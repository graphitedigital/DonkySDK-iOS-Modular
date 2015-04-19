//
//  DPPushUISingleton.m
//  Push Container
//
//  Created by Chris Watson on 19/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPPushUISingleton.h"
#import "DPUINotificationController.h"

@interface DPPushUISingleton ()
@property(nonatomic, strong) DPUINotificationController *dPUIPresentationController;
@end

@implementation DPPushUISingleton

+(DPPushUISingleton *)sharedInstance
{
    static DPPushUISingleton *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPPushUISingleton alloc] initPrivate];
    });
    return sharedInstance;
}

-(id)init
{
    return [DPPushUISingleton sharedInstance];
}

-(id)initPrivate
{
    self  = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)startPushUI {
    self.dPUIPresentationController = [[DPUINotificationController alloc] init];
}

- (void)stopPushUI {
    self.dPUIPresentationController = nil;
}

@end

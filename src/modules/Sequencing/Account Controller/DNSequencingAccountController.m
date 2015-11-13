//
//  DNSequencingAccountController.m
//  DonkySequencing
//
//  Created by Donky Networks on 10/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "DNSequencingAccountController.h"
#import "DNLoggingController.h"
#import "DSSequenceController.h"

@implementation DNSequencingAccountController

+ (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DNInfoLog(@"calling in sequencing controller...");
   [[DSSequenceController sharedInstance] updateAdditionalProperties:newAdditionalProperties success:successBlock failure:failureBlock];
}

+ (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DNInfoLog(@"calling in sequencing controller...");
    [[DSSequenceController sharedInstance] saveUserTags:tags success:successBlock failure:failureBlock];
}

+ (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DNInfoLog(@"calling in sequencing controller...");
    [DNSequencingAccountController updateUserDetails:userDetails automaticallyHandleUserIDTaken:YES success:successBlock failure:failureBlock];
}

+ (void)updateUserDetails:(DNUserDetails *)userDetails automaticallyHandleUserIDTaken:(BOOL)autoHandleIDTaken success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock {
    DNInfoLog(@"calling in sequencing controller...");
    [[DSSequenceController sharedInstance] updateUserDetails:userDetails automaticallyHandleUserIDTaken:autoHandleIDTaken success:successBlock failure:failureBlock];
}

+ (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DNInfoLog(@"calling in sequencing controller...");
    [[DSSequenceController sharedInstance] updateRegistrationDetails:userDetails deviceDetails:deviceDetails success:successBlock failure:failureBlock];
}

+ (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DNInfoLog(@"calling in sequencing controller...");
    [[DSSequenceController sharedInstance] updateDeviceDetails:deviceDetails success:successBlock failure:failureBlock];
}

@end

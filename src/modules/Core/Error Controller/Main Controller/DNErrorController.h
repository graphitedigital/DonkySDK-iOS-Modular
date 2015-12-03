//
//  DNErrorController.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DNCoreSDKErrorNotRegistered = 8001,
    DNCoreSDKErrorNotAuthorised = DNCoreSDKErrorNotRegistered,
    DNCoreSDKErrorNoAPIKey,
    DNCoreSDKErrorDuplicateSynchronise,
    DNCoreSDKNetworkError,
    DNCoreSDKFatalException,
    DNCoreAutoLoggingDisabled,
    DNCoreFrequentErrorLogs,
    DNCoreSDKSuspendedUser,
    DNCoreContentNotificationSizeLimit,
    DNCoreErrorDuplicateRequest,
    DNCoreSDKErrorDuplicateAsyncCall
} DonkyNetworkSDKErrorCodes;

@interface DNErrorController : NSObject

+ (NSError *)errorWithCode:(DonkyNetworkSDKErrorCodes)code;

+ (NSString *)descriptionForError:(DonkyNetworkSDKErrorCodes)code;

+ (NSString *)recoveryForError:(DonkyNetworkSDKErrorCodes)code;

+ (NSError *)errorCode:(DonkyNetworkSDKErrorCodes)code userInfo:(NSDictionary *)info;

+ (NSError *)errorCode:(DonkyNetworkSDKErrorCodes)code additionalData:(id)additional;

+ (BOOL)serviceReturned:(NSInteger)errorCode error:(NSError *)error;

+ (BOOL)serviceReturnedFailureKey:(NSString *)failureValue error:(NSError *)error;

@end

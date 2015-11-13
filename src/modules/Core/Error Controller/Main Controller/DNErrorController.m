//
//  DNErrorController.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNErrorController.h"
#import "DNLoggingController.h"
#import "DNSystemHelpers.h"
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#import "DNConstants.h"

@implementation DNErrorController

+ (NSError *)errorWithCode:(DonkyNetworkSDKErrorCodes)code {
    return [[NSError alloc] initWithDomain:kDonkyErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : [DNErrorController descriptionForError:code], NSLocalizedRecoverySuggestionErrorKey : [DNErrorController recoveryForError:code]}];
}

+ (NSError *)errorCode:(DonkyNetworkSDKErrorCodes)code userInfo:(NSDictionary *)info {
    return [NSError errorWithDomain:kDonkyErrorDomain code:code userInfo:info];
}

+ (NSError *)errorCode:(DonkyNetworkSDKErrorCodes)code additionalData:(id)additional {
    return [[NSError alloc] initWithDomain:kDonkyErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : [DNErrorController descriptionForError:code], @"AdditionalInformation" : additional }];
}

+ (NSString *)recoveryForError:(DonkyNetworkSDKErrorCodes)code {
    switch (code) {
        case DNCoreSDKErrorNotAuthorised:
            return @"Check that you have initialised the SDK.";
        default:break;
        case DNCoreSDKErrorNoAPIKey:
            return @"Please supply and API key on the initialise calls.";
        case DNCoreSDKErrorDuplicateSynchronise:
            return @"If you have any pending clinet types that aren't sent with the current synchronise, these will be automatically sent once it has completed.";
        case DNCoreSDKNetworkError:break;
        case DNCoreSDKFatalException:break;
        case DNCoreSDKSuspendedUser:
            return @"Contact system administrator to get reactivated...";
        case DNCoreAutoLoggingDisabled:break;
        case DNCoreFrequentErrorLogs:break;
        case DNCoreContentNotificationSizeLimit:break;
        case DNCoreErrorDuplicateRequest:
            return @"Duplicate request, cancelling";
        case DNCoreSDKErrorDuplicateAsyncCall:
            return @"Use completion handlers to ensure a synchronous update of user details.";
    }

    return @"";
}

+ (NSString *)descriptionForError:(DonkyNetworkSDKErrorCodes)code {

    switch (code) {
        case DNCoreSDKErrorNotAuthorised:
            return @"This deivce is not authroised. Therefore the request cannot be performed.";
        case DNCoreSDKErrorNoAPIKey:
            return @"No API key found.";
        case DNCoreSDKErrorDuplicateSynchronise:
            return @"A synchronise is already being performed. If there are pending content notifications when the current sync has finisehd, they will be sent...";
        case DNCoreSDKNetworkError:
            return @"A network error has occurred.";
        case DNCoreSDKFatalException:
            return @"A fatal SDK exception has been caught and logged. Please try again...";
        case DNCoreSDKSuspendedUser:
            return @"User is suspended. Cannot perform secure network calls.";
        case DNCoreAutoLoggingDisabled:
            return @"Tried to auto submit debug log in response to exception. Always submit debug logs is false or notification ID was nil.";
        case DNCoreFrequentErrorLogs:
            return @"Cannot submit debug log. Last submission was too soon.";
        case DNCoreContentNotificationSizeLimit:
            return @"Some of the content notifications were too large to send. These notifications can be found inside the 'AdditionalInformation' object.";
        case DNCoreErrorDuplicateRequest:
            return @"This is a duplicate request, Donky does not need to process this and such it will be cancelled.";
        case DNCoreSDKErrorDuplicateAsyncCall:
            return @"A call to update user details is already being performed. Network calls are performed asynchronously and we cannot gurantee in which order the network will process them. Queining multiple calls to update state can therfore lead to network and client being out of sync. Please adhere to correct usage of state changing APIs and use completion handlers where appropriate.";
    }

    return [NSString stringWithFormat:@"Unkown error... %d", code];
}

+ (BOOL)serviceReturned:(NSInteger)errorCode error:(NSError *)error {
   return [[error localizedDescription] rangeOfString:[NSString stringWithFormat:@"%ld", (long)errorCode]].location != NSNotFound;
}

+ (BOOL)serviceReturnedFailureKey:(NSString *)failureValue error:(NSError *)error {
    return [[error userInfo][@"failureKey"] isEqualToString:failureValue];
}

@end

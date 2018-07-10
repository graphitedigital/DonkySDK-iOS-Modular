//
//  DNLoggingController.m
//  Logging
//
//  Created by Donky Networks on 12/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNLoggingController.h"
#import "DNFileHelpers.h"
#import "NSDate+DNDateHelper.h"
#import "DNConstants.h"
#import "DNAppSettingsController.h"
#import "DNSystemHelpers.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNConfigurationController.h"
#import "DNUserDefaultsHelper.h"
#import "DNErrorController.h"

static NSString *const DNLogSubmissionRequestReason = @"manualRequest";
static NSString *const DNLogSubmissionAutomaticReason = @"automaticByDevice";
static NSString *const DNLogSubmissionReasonKey = @"submissionReason";
static NSString *const DNDataKey = @"data";
static NSString *const DNAlwaysSubmitErrors = @"AlwaysSubmitErrors";

static NSString *const DNPascalAlwaysSubmitErrors = @"alwaysSubmitErrors";

@implementation DNLoggingController

+ (void)log:(NSString *)message function:(NSString *)function line:(NSInteger)line logType:(DonkyLogType) logType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //Can we output debug logs:
        if ([DNAppSettingsController loggingEnabled]) {
            //We check if we can log out this type of error, if not simply return early.
            switch (logType) {
                case DNDebugLog:
                    if (![DNAppSettingsController outputDebugLogs] || ![DNSystemHelpers donkyIsDebuggerAttached])
                        return;
                    break;
                case DNErrorLog:
                    if (![DNAppSettingsController outputErrorLogs])
                        return;
                    break;
                case DNSensitiveLog:
                    if (![DNAppSettingsController outputSensitiveLogs] || ![DNSystemHelpers donkyIsDebuggerAttached])
                        return;
                    break;
                case DNWarningLog:
                    if (![DNAppSettingsController outputWarningLogs])
                        return;
                    break;
                case DNInfoLog:
                    if (![DNAppSettingsController outputInfoLogs])
                        return;
                    break;
            }

            //Construct the log string:
            NSString *log = [NSString stringWithFormat:@"\n%@ [line %li] %@", function, (long) line, message];

            //Output to the console:
            NSLog(@"%@", log);
            //Save this log to the file:
            [DNLoggingController addLogToFile:log];
        }
    });
}

+ (void)addLogToFile:(NSString *)log {
    
    NSString *filePath = [DNFileHelpers pathForFile:kDNLoggingFileName inDirectory:kDNLoggingDirectoryName];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    
    NSString *toWrite = [[[NSDate date] donkyDateForDebugLog] stringByAppendingString:[NSString stringWithFormat:@" %@\n", log]];
    [fileHandle writeData:[toWrite dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];

    //Get log file size:
    if ([DNFileHelpers sizeForFile:filePath] > kDonkyLogFileSizeLimit) {
        [DNLoggingController archiveDebugLog];
    }
}

+ (void)deleteLogs {
    NSString *filePath = [DNFileHelpers pathForFile:kDNLoggingFileName inDirectory:kDNLoggingDirectoryName];
    [DNFileHelpers removeFileIfExistsAtPath:filePath];
    NSString *archivedPath = [DNFileHelpers pathForFile:kDNLoggingArchiveFileName inDirectory:kDNLoggingArchiveDirectoryName];
    [DNFileHelpers removeFileIfExistsAtPath:archivedPath];
}

+ (NSString *)activeDebugLog {
    NSString *filePath = [DNFileHelpers pathForFile:kDNLoggingFileName inDirectory:kDNLoggingDirectoryName];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

+ (void)archiveDebugLog {
    //Get the original:
    NSString *filePath = [DNFileHelpers pathForFile:kDNLoggingFileName inDirectory:kDNLoggingDirectoryName];
    NSString *destinationPath = [[DNFileHelpers pathForDirectory:kDNLoggingArchiveDirectoryName] stringByAppendingString:[NSString stringWithFormat:@"/%@", kDNLoggingArchiveFileName]];
    //We only keep 1 archived file. So remove the current one if it exists.
    [DNFileHelpers removeFileIfExistsAtPath:destinationPath];
    if ([DNFileHelpers copyItemAtPath:filePath toPath:destinationPath]) {
        //We've copied it now delete the original:
        [DNFileHelpers removeFileIfExistsAtPath:filePath];
    }
}

+ (NSString *)archivedDebugLog {
    NSString *filePath = [DNFileHelpers pathForFile:kDNLoggingArchiveFileName inDirectory:kDNLoggingArchiveDirectoryName];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

+ (void)submitLogToDonkyNetworkSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock {
    [DNLoggingController submitLogToDonkyNetwork:nil success:successBlock failure:failureBlock];
}

+ (void)submitLogToDonkyNetwork:(NSString *)notificationID success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock {

    //Check time of last submission:
    NSDate *lastDate = [DNUserDefaultsHelper objectForKey:DNDebugLogSubmissionTime];

    if (lastDate) {
        NSTimeInterval timeSinceLastSubmission = [[NSDate date] timeIntervalSinceDate:lastDate];
        if (timeSinceLastSubmission < [DNAppSettingsController debugLogSubmissionInterval]) {
            if (failureBlock) {
                failureBlock(nil, [DNErrorController errorWithCode:DNCoreFrequentErrorLogs]);
            }
            return;
        }
    }

    //If this is an auto submit log and always submit errors is false then we bail out early.
    if (!notificationID && ![[DNConfigurationController objectFromConfiguration:DNAlwaysSubmitErrors] boolValue]) {
        if (failureBlock) {
            failureBlock(nil, [DNErrorController errorWithCode:DNCoreAutoLoggingDisabled]);
        }
        return;
    }
    
    //Grab log:
    NSString *logString = [DNLoggingController archivedDebugLog];
    logString = [logString stringByAppendingString:[DNLoggingController activeDebugLog]];

    if ([logString length] > 0) {
        NSMutableDictionary *debugLogSubmission = [[NSMutableDictionary alloc] init];
        [debugLogSubmission dnSetObject:logString forKey:DNDataKey];
        [debugLogSubmission dnSetObject:notificationID ? DNLogSubmissionRequestReason : DNLogSubmissionAutomaticReason forKey:DNLogSubmissionReasonKey];
        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkSendDebugLog httpMethod:DNPost parameters:debugLogSubmission success:^(NSURLSessionDataTask *task, id responseData) {
            DNInfoLog(@"Log sent. Deleting logs ...");
            [DNConfigurationController saveConfigurationObject:@([responseData[DNPascalAlwaysSubmitErrors] boolValue]) forKey:DNAlwaysSubmitErrors];
            [DNLoggingController deleteLogs];
            //Save time:
            [DNUserDefaultsHelper saveObject:[NSDate date] withKey:DNDebugLogSubmissionTime];
            if (successBlock) {
                successBlock(task, responseData);
            }
        } failure:failureBlock];
    }
}

@end

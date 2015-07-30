//
//  DNLoggingController.h
//  Logging
//
//  Created by Chris Watson on 12/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"

typedef enum {
    DNDebugLog,
    DNErrorLog,
    DNSensitiveLog,
    DNWarningLog,
    DNInfoLog
} DonkyLogType;

static NSString *const DNDebugLogSubmissionTime = @"DebugLogSubmissionTime";
#define DNDebugLog(fmt, ...) [DNLoggingController log:[NSString stringWithFormat:@"DEBUG: " fmt, ##__VA_ARGS__] function:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] line:__LINE__ logType:DNDebugLog]
#define DNErrorLog(fmt, ...) [DNLoggingController log:[NSString stringWithFormat:@"ERROR: " fmt, ##__VA_ARGS__] function:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] line:__LINE__ logType:DNErrorLog]
#define DNSensitiveLog(fmt, ...) [DNLoggingController log:[NSString stringWithFormat:@"SENSITIVE: " fmt, ##__VA_ARGS__] function:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] line:__LINE__ logType:DNSensitiveLog]
#define DNWarningLog(fmt, ...) [DKLoggingController log:[NSString stringWithFormat:@"WARNING: " fmt, ##__VA_ARGS__] function:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] line:__LINE__ logType:DNWarningLog]
#define DNInfoLog(fmt, ...) [DNLoggingController log:[NSString stringWithFormat:@"INFO: " fmt, ##__VA_ARGS__] function:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] line:__LINE__ logType:DNInfoLog]

/*!
 DNLoggingController is responsible for logging, saving, retrieving and managing the debug logs of the Donky SDK.
 third parties may also utilise this logging in the event that they want debug information to be available via
 the Donky Network Debug Log.
 
 @since 2.0.0.0
 */
@interface DNLoggingController : NSObject

/*!
 The principle method of the Logging. This is called by the define. It is responsible for outputting the log
 to the console as well as passing it on to be saved to a local file.
 
 @param message  the message that should be logged to the console and file.
 @param function the function in which the log action is called.
 @param line     the line of code that the log message is called on.
 @param type      the level of logging for this message. Defined by the DonkyLogType enum.
 
 @since 2.0.0.0
 */
+ (void)log:(NSString *)message function:(NSString *)function line:(NSInteger)line logType:(DonkyLogType) type;

/*!
 The method responsible for saving the log to the file in the documents directory. The name and location of the file used can be
 changed by amending the kDNLoggingFileName & kDKLoggingDirectoryName constants in the DKConstants class.
 
 @param log the log that is to be saved, this has the time and date suffixed to it. The date format can be changed by amending the kDNLoggingDateFormat constant in the DKConstant class.

 @since 2.0.0.0
 */
+ (void)addLogToFile:(NSString *)log;

/*!
 The method responsible for retrieving the contents of the debug log as a string value.
 
 @return the contents of the debug file as a string.
 
 @since 2.0.0.0
 */
+ (NSString *)activeDebugLog;

/*!
 Moves the current debug log to the archived directory. The existing log is then deleted and a new one is made the next time DKLog is called.
 
 @since 2.0.0.0
 */
+ (void)archiveDebugLog;

/*!
 The method responsible for retrieving the contents of the archived debug log as a string value.
 
 @return the contents of the archived debug file as a string.
 
 @since 2.0.0.0
 */
+ (NSString *)archivedDebugLog;

/*!
 Sends the current active debug log to the donky network.

 @param successBlock   the block to be called when the log was successfully sent.
 @param failureBlock   the block to be called if there was a failure to send the log.

 @since 2.0.0.0
 */
+ (void)submitLogToDonkyNetworkSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Sends the current active debug log to the donky network.
 
 @param notificationID the id of the notification that prompted the request. Use nil if this was a manual request.
 @param successBlock   the block to be called when the log was successfully sent.
 @param failureBlock   the block to be called if there was a failure to send the log.
 
 @since 2.0.0.0
 */
+ (void)submitLogToDonkyNetwork:(NSString *)notificationID success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end

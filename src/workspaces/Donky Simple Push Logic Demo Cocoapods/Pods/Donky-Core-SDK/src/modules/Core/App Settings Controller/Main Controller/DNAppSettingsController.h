//
//  DNAppSettingsController.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The controller for all the client and SDK settings. To change any of these values edit the DNConfiguration.plist file.
 
 @since 2.0.0.0
 */
@interface DNAppSettingsController : NSObject

/*!
 Helper method to get the version of the SDK as a string.

 @return string containing the SDK version number.
 
 @since 2.0.0.0
 */
+ (NSString *)sdkVersion;

/*!
 Helper method to get the dictionary contents of the Logging Options
 
 @return NSDictionary representing the logging options located in the configuration plist.
 
 @since 2.0.0.0
 */
+ (NSDictionary *)donkyLoggingOptions;

/*!
 Helper method to control if the SDK should display a stock alert view when there isn't a valid internet connection. The alert view text is localised.

 @return BOOL to determine if alert view should be displayed.

 @since 2.0.0.0
 */
+ (BOOL)displayNoInternetAlert;

/*!
 Helper method to determine if logging is enable for this app, the value is pulled from the Donky Logging Options method in the configuration plist.
 
 @return BOOL to determine if logging is enabled.

 @since 2.0.0.0
 */
+ (BOOL)loggingEnabled;

/*!
 Helper method to determine if the Warning Logs output is enabled for this app.
 
 @return BOOL to determine if outputting Warning logs is enabled.
 
 @since 2.0.0.0
 */
+ (BOOL)outputWarningLogs;

/*!
 Helper method to determine if the Error Logs output is enabled for this app.

 @return BOOL to determine if outputting Error logs is enabled.
 
 @since 2.0.0.0
 */
+ (BOOL)outputErrorLogs;

/*!
 Helper method to determine if the Info Logs output is enabled for this app.
 
 @return BOOL to determine if outputting Info logs is enabled.
 
 @since 2.0.0.0
 */
+ (BOOL)outputInfoLogs;

/*!
 Helper method to determine if the Error Logs output is enabled for this app.

 @return BOOL to determine if outputting Debug logs is enabled.
 
 @since 2.0.0.0
 */
+ (BOOL)outputDebugLogs;

/*!
 Helper method to determine if the Error Logs output is enabled for this app.
 
 @return BOOL to determine if outputting Sensitive logs is enabled.
 
 @since 2.0.0.0
 */
+ (BOOL)outputSensitiveLogs;

/*!
 The minimum interval between debug log submission. This can be changed in the DNConfiguration.plist. If this limit is breached, the submitDebugLogs method will return an approritate error in the failueBlock.
 
 @return the minimum interval between debug log submissions in seconds.
 
 @since 2.0.0.0
 */
+ (NSInteger)debugLogSubmissionInterval;

@end

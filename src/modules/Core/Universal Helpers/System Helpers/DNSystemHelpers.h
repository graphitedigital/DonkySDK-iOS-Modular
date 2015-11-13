//
//  DNSystemHelpers.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 27/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

/*!
 Helper class for the deice for debugging purposes.
 
 @since 2.0.0.0
 */
@interface DNSystemHelpers : NSObject

/*!
 Method to determine if the app is currently running in debug mode.
 
 @return BOOL to determine if app is running in debug mode.
 
 @since 2.0.0.0
 */
+ (BOOL)donkyIsDebuggerAttached;

/*!
 Helper method to determine if the version of iOS currently being used is greater than x
 
 @param version the minimum iOS version.
 
 @return BOOL indicating if the current iOS version is at least the specified version.
 
 @since 2.0.0.0
 */
+ (BOOL)systemVersionAtLeast:(CGFloat) version;

/*!
 Helper method to determine if the version of iOS currenly being used is the same. NOTE
 this only checks large version numbers, i.e. 7 OR 8
 
 @param version the version of iOS that should be running i.e. 7 OR 8
 
 @return BOOL indicating if the current iOS version matches the supplied.
 
 @since 2.2.2.7
 */
+ (BOOL)systemVersionEquals:(CGFloat)version;

/*!
 Helper method to get a new GUID.
 
 @return a new GUID as a string.
 
 @since 2.0.0.0
 */
+ (NSString *)generateGUID;

/*!
 Helper method to determine if the current device is an iPad.
 
 @return BOOL inditicating whether the device is an iPad or not.
 
 @since 2.2.2.7
 */
+ (BOOL)isDeviceIPad;

/*!
 Helper method to determine if the current device is an iPhone 6+
 
 NOTE: This mehtod only works on a real device, not a simulator as it relies upon
 systemInfo.machine.
 
 @return BOOL indicating whether or not the device is an iPhone 6+ or not.
 
 @since 2.2.2.7
 */
+ (BOOL)isDeviceSixPlus;

/*!
 Helper method to determine whether the current device is an iPhone 6+
 AND that it is in landscape orientation.
 
 NOTE: This mehtod only works on a real device, not a simulator as it relies upon
 systemInfo.machine.
 
 @return BOOL indicating whether the current device is an iPhone 6+ AND
 it is in landscape orientation.
 
 @since 2.2.2.7
 */
+ (BOOL)isDeviceSixPlusLandscape;

/*!
 Helper method to combine two strings in the format expected for conversation IDs. Use this to generate repeatable unique ID's based on a set of
 users. This allows two devices to create the same ID for a converastion or custom data channel.
 
 @param firstString  the first string
 @param secondString the second string that should be added to the first string.
 
 @return a new string with the concatanted style of string1_string2
 
 @since 2.6.5.4
 */
+ (NSString *)combineString:(NSString *)firstString toString:(NSString *)secondString;

@end

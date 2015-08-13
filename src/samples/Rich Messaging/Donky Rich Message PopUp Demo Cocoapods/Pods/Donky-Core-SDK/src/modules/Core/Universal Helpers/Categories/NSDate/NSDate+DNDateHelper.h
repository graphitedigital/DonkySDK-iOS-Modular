//
//  DKDateHelper.h
//  Logging
//
//  Created by Chris Watson on 13/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 NSDate category to help format and de-serialise dates received from the network. Also some helper methods to perform logic around dates.
 
 @since 2.0.0.0
 */
@interface NSDate (DNDateHelper)

/*!
 Format the date object to be sent to the network and return it as an NSString.
 
 @return a string containing the date formatted for the network.
 
 @since 2.0.0.0
 */
- (NSString *)donkyDateForServer;

/*!
 Method to create an NSDate object from the date string received from the network.
 
 @param date the date as a string received from the network.
 
 @return a new NSDate object representing the server date string.
 
 @since 2.0.0.0
 */
+ (NSDate *)donkyDateFromServer:(NSString *)date;

/*!
 Helper method to create a string from a date in the format required for the Debug Logs. This can be customised by amending the constants in DNConstants.
 
 @return a new string from the date.
 
 @since 2.0.0.0
 */
- (NSString *)donkyDateForDebugLog;

/*!
 Helper method to determine if a date has or has not expired.
 
 @return BOOL indicating whether the date has expired.
 
 @since 2.0.0.0
 */
- (BOOL)donkyHasDateExpired;

/*!
 Helper method to determine if a donky message has expired.
 
 @return BOOL indicating whether the message has expired.
 
 @since 2.2.2.7
 */
- (BOOL)donkyHasMessageExpired;

/*!
 Helper method to determine if a date is before another date.
 
 @param secondDate the date which should be after the current date.
 
 @return BOOL inditcating if the date is before the supplied date.
 
 @since 2.0.0.0
 */
- (BOOL)isDateBeforeDate:(NSDate *)secondDate;

@end

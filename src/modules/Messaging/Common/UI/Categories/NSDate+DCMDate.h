//
//  NSDate+DCMDate.h
//  RichInbox
//
//  Created by Chris Watson on 06/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DCMDate)

/*!
 Helper method to get a relative date string for the NSDate.
 
 @return a new string, this could be just now, x min ago, x hour ago, the name of the day
 or the date.
 
 @since 2.2.2.7
 */
- (NSString *)donkyRelativeString;

/*!
 Whether this date needs to be refresehd, only the dates wihtin the last 24 hours need to be refreshed.
 
 @return BOOL determining whether a date needs to be refreshed.
 
 @since 2.2.2.7
 */
- (BOOL)needsRefresh;

/*!
 An integer representing the seconds until the date label 
 needs to be refreshed.
 
 @return an NSinteger representing seconds.
 
 @since 2.2.2.7
 */
- (NSInteger)nextRefresh;

@end

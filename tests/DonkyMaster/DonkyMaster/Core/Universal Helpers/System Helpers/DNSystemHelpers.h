//
//  DNSystemHelpers.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 27/02/2015.
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
+ (BOOL)donkySystemVersionAtLeast:(CGFloat) version;

/*!
 Helper method to get a new GUID.
 
 @return a new GUID as a string.
 
 @since 2.0.0.0
 */
+ (NSString *)generateGUID;

@end

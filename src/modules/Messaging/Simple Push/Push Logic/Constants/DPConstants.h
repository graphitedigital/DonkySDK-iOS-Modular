//
//  DKConstants.h
//  Logging
//
//  Created by Chris Watson on 13/02/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

/*!
 A full list of the Donky SDK constants. They are broken down into sections with the use
 of pragma marks. All Donky SDK Constants follow the same naming convention: k - 'DN' - Name of the Relevant Module - Variable Name
 e.g. kDNLoggingFileName (where logging = DNLoggingController) nad FileName is the variable that this constant is used for.
 */


/*!
 Subscribe to this event to receive notifications when the application badge count should be changed.

This notification should contain an NSNumber value representing the amount by which the app badge count should be reduced in the 'Data' property.

 @since 1.0.0.0
 */
extern NSString * const kDPDonkyEventChangeBadgeCount;

/*!
 Subscribe to this event ro receive the data inside Interactive Notifications.

 This notification should contain contain a string value in the data property.

 @since 2.0.0.0
 */
extern NSString * const kDNDonkyEventInteractivePushData;

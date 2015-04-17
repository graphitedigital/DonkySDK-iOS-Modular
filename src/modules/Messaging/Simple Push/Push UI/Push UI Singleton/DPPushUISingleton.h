//
//  DPPushUISingleton.h
//  Push Container
//
//  Created by Chris Watson on 19/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPPushNotificationController;
@class DPUINotificationController;

@interface DPPushUISingleton : NSObject


/*!
 Singleton instance to hold the module
 
 @return new instance
 */
+ (DPPushUISingleton *) sharedInstance;

/*!
 Method to start the push UI
 
 @since 2.0.0.0
 */
- (void)startPushUI;

/*!
 Method to stop the PushUI.
 
 @since 2.0.0.0
 */
- (void)stopPushUI;

@end

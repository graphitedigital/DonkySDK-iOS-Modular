//
//  DRUIPopUpMainController.h
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import "DRMessageViewController.h"
#import "DRLogicMainController.h"
#import "DNLocalEvent.h"

@interface DRUIPopUpMainController : NSObject <DRMessageViewControllerDelegate>

/*!
 The style in which the modal view should be presented.
 
 @since 2.0.0.0
 */
@property (nonatomic) UIModalPresentationStyle richPopUpPresentationStyle;

/*!
 Whether the Rich Message should be automatically deleted when the view is dismissed.
 
 @since 2.0.0.0
 */
@property (nonatomic, getter=shouldAutoDelete) BOOL autoDelete;

/*!
 A bool to determine whether the SDK should vibrate the device when a new message is received.
 
 @since 2.4.3.1
 */
@property (nonatomic, getter=shouldVibrate) BOOL vibrate;

/*!
 Singleton instance for the Donky Core.

 @return the current DNDonkyCore instance.
 */
+ (DRUIPopUpMainController *) sharedInstance;

/*!
 Method to prompt the controller to start monitoring for new rich messages.
 
 @since 2.0.0.0
 */
- (void)start;

/*!
 Method to stop the monitoring of Rich Messages. Any incoming Rich Messages after Stop is called will not be displayed to the user.
 
 @since 2.0.0.0
 */
- (void)stop;

@end

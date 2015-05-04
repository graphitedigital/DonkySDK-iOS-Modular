//
//  DRUIPopUpMainController.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUIRMessageViewController.h"

@class DRLogicMainController;
@class DNLocalEvent;

@interface DRUIPopUpMainController : NSObject <DCUIRMessageViewControllerDelegate>

/*!
 The style in which the modal view should be presented.
 
 @since 2.0.0.0
 */
@property (nonatomic) UIModalPresentationStyle richPopUpPresentationStyle;

/*!
 Whether the Rich Message should be automatically deleted when the view is dimissed.
 
 @since 2.0.0.0
 */
@property (nonatomic, getter=shouldAutoDelete) BOOL autoDelete;

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

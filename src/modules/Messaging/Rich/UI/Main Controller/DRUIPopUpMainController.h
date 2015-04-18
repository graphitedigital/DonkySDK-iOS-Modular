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

@property (nonatomic) UIModalPresentationStyle richPopUpPresentationStyle;

@property (nonatomic, getter=shouldAutoDelete) BOOL autoDelete;

/*!
 Singleton instance for the Donky Core.

 @return the current DNDonkyCore instance.
 */
+ (DRUIPopUpMainController *) sharedInstance;

- (void)start;

- (void)stop;

- (void)presentPopUp:(DNLocalEvent *)event;

@end

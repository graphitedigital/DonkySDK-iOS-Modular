//
//  ViewController.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)sync:(id)sender;

- (IBAction)updateToKnownUser:(id)sender;

- (IBAction)initialise:(id)sender;

- (IBAction)reRegister:(id)sender;

- (IBAction)reRegisterAnonymously:(id)sender;

- (IBAction)togglePushRegistration:(id)sender;

- (IBAction)sendCustomContent:(id)sender;

- (IBAction)loadColourDemo:(id)sender;

@end

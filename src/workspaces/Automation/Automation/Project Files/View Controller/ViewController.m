//
//  ViewController.m
//  Automation
//
//  Created by Chris Watson on 04/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DAAutomationController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)executeTrigger:(id)sender {

    [DAAutomationController executeThirdPartyTriggerWithKey:@"automation_test" customData:nil];
  //  [DAAutomationController executeThirdPartyTriggerWithKeyImmediately:@"automation_test" customData:nil];

}

@end

//
//  ViewController.m
//  Donky Automation Demo
//
//  Created by Chris Watson on 26/07/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DAAutomationController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [DAAutomationController executeThirdPartyTriggerWithKey:@"Trigger-Key" customData:@{}];

    [DAAutomationController executeThirdPartyTriggerWithKeyImmediately:@"Trigger-Key" customData:@{}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

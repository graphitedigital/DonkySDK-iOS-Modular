//
//  ViewController.m
//  PushLogic
//
//  Created by Chris Watson on 31/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DNLocalEvent.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyNotificationSimplePush handler:^(DNLocalEvent *event) {
        NSLog(@"%@", event);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

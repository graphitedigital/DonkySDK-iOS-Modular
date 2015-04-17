//
//  ViewController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "ViewController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DCUIRMessageViewController.h"
#import "DNNetworkController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sync:(id)sender {
    [[DNNetworkController sharedInstance] synchronise];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
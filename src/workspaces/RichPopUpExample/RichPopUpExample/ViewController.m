//
//  ViewController.m
//  RichPopUpExample
//
//  Created by Chris Watson on 28/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "ViewController.h"
#import "DNNetworkController.h"

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

- (void)sync:(id)sender {
    [[DNNetworkController sharedInstance] synchronise];
}

@end
//
//  SecondViewController.m
//  RichInboxTabs
//
//  Created by Chris Watson on 23/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (instancetype) init {
    
    
    self = [super init];
    
    if (self) {
        
        [[self view] setBackgroundColor:[UIColor whiteColor]];
        
        self.title = @"Second View";
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

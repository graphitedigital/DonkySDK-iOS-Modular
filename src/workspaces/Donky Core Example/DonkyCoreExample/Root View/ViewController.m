//
//  ViewController.m
//  DonkyCoreExample
//
//  Created by Chris Watson on 27/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "ViewController.h"
#import "DemoDataController.h"

@interface ViewController ()

@property(nonatomic, strong) DemoDataController *demoDataController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //Lets setup a send colour demo:
    [self addCustomNotificationModules];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send Colour" style:UIBarButtonItemStyleDone target:self action:@selector(changeColour:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(sync)];
}

- (void) sync {
    [self.demoDataController sync];
}

- (void)changeColour:(id)sender {

    if (self.demoDataController) {
        [self.demoDataController sendColourMessage:[UIColor redColor]];
    }
    
}

- (void)addCustomNotificationModules {

    //Create a view:
    UIView *colourDemo = [[UIView alloc] initWithFrame:self.view.frame];
    [[self view] addSubview:colourDemo];


    //Create our controller:
    self.demoDataController = [[DemoDataController alloc] initWithColourView:colourDemo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

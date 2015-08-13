//
//  DCUISplitViewController.m
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DCUISplitViewController.h"

@interface DCUISplitViewController ()

@end

@implementation DCUISplitViewController

- (instancetype)initWithMasterView:(UIViewController *)masterView detailViewController:(UIViewController *)detailView {

    self = [super init];

    if (self) {

        UINavigationController *tableViewNavigationController = [[UINavigationController alloc] initWithRootViewController:masterView];

        [self setMasterViewController:tableViewNavigationController];

        UINavigationController *richMessageNavigationController = [[UINavigationController alloc] initWithRootViewController:detailView];

        [self setDetailViewController:richMessageNavigationController];

        [self setViewControllers:@[tableViewNavigationController, richMessageNavigationController]];

        [self setDelegate:(id <UISplitViewControllerDelegate>) detailView];

    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

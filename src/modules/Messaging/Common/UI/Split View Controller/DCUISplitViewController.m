//
//  DCUISplitViewController.m
//  RichInbox
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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

//- (void)setDetailViewController:(UINavigationController *)detailViewController {
//    if (_detailViewController != detailViewController) {
//        _detailViewController = detailViewController;
//        [self setViewControllers:@[[self masterViewController], _detailViewController]];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

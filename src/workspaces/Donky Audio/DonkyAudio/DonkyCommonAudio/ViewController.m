//
//  ViewController.m
//  DonkyCommonAudio
//
//  Created by Chris Watson on 31/07/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "ViewController.h"
#import "DNNetworkController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DCMAMainController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:@"View" version:@"1.0.0.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationSimplePush batchHandler:^(NSArray *batch) {
//        DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"DCMAudioPlayAudioFile" publisher:@"VIEW" timeStamp:[NSDate date] data:@(DCMASimplePushMessage)];
//        [[DNDonkyCore sharedInstance] publishEvent:event];
        [[DCMAMainController sharedInstance] playAudioFileForMessage:DCMASimplePushMessage];
    }];
    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:moduleDefinition subscriptions:@[subscription]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sync:(id)sender {

    [[DNNetworkController sharedInstance] synchronise];

}


@end

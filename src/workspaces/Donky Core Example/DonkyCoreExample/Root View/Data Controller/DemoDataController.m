//
//  DemoDataController.m
//  DonkyCoreExample
//
//  Created by Chris Watson on 27/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "DemoDataController.h"
#import "DNModuleDefinition.h"
#import "DNDonkyCore.h"
#import "DNContentNotification.h"
#import "DNAccountController.h"
#import "DNNetworkController.h"

@interface DemoDataController ()
@property(nonatomic, strong) UIView *colourView;
@end

@implementation DemoDataController

- (instancetype) initWithColourView:(UIView *) view {

    self = [super init];

    if (self) {

        //We save the view that we want the colour applied to:
        [self setColourView:view];


        //We now need to subscribe to our custom notification, you can call it whatever you like, string from class is
        // quick and easy to identify on the back end:
        DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"];

        //Create the subscription:
        DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"customColour" handler:^(id data) {

            DNServerNotification *serverNotification = data;
            
            //Here we process the data:
            [[self colourView] setBackgroundColor:[self colorFromString:[serverNotification data][@"customData"][@"colour"]]];
            
            [self performSelector:@selector(changeBack) withObject:nil afterDelay:2.0];

            //Sync to ack the notification:
            [[DNNetworkController sharedInstance] synchronise];

        }];

        [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition subscriptions:@[subscription]];
    }

    return self;
}

- (void) changeBack {
    
    [[self colourView] setBackgroundColor:[UIColor whiteColor]];
    
}

- (void) sendColourMessage:(UIColor *) colour {

    //Create the content notification:
    DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[[[[DNAccountController registrationDetails] userDetails] userID]]
                                                                                   customType:@"customColour"
                                                                                         data:@{@"colour" : [self stringFromColor:colour]}];

    [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification] success:nil failure:nil];
}

- (NSString *)stringFromColor:(UIColor *)color
{
    CGColorRef colorRef = color.CGColor;
    return  [CIColor colorWithCGColor:colorRef].stringRepresentation;
}

-(UIColor *)colorFromString:(NSString *)stringValue
{
    CIColor *coreColor = [CIColor colorWithString:stringValue];
    return  [UIColor colorWithCIColor:coreColor];
}

- (void)sync {
    [[DNNetworkController sharedInstance] synchronise];
}

@end

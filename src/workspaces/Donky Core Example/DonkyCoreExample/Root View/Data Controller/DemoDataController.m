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

            //Here we process the data:
            [[self colourView] setBackgroundColor:[self colorFromString:data[@"colour"]]];

        }];

        [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition subscriptions:@[subscription]];
    }

    return self;
}

- (void) sendColourMessage:(UIColor *) colour {

    //Create the content notification:
    DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[[[[DNAccountController registrationDetails] userDetails] userID]]
                                                                                   customType:@"customColour"
                                                                                         data:@{@"colour" : [self stringFromColor:colour]}];

    [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification] success:^(NSURLSessionDataTask *task, id responseData) {
        NSLog(@"sent successfylly");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failed: %@", [error localizedDescription]);
    }];
}

- (NSString *)stringFromColor:(UIColor *)color
{
    const size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X",
                                      (int)(255 * components[MIN(0,totalComponents-2)]),
                    (int)(255 * components[MIN(1,totalComponents-2)]),
                            (int)(255 * components[MIN(2,totalComponents-2)])];
}

-(UIColor *)colorFromString:(NSString *)stringValue
{
    CGFloat r = 0.0, g = 0.0, b = 0.0, a = 1.0;
    sscanf([stringValue UTF8String],
#ifdef __x86_64
           "%lf %lf %lf %lf",
#else
            "%f %f %f %f",
#endif
            &r, &g, &b, &a);

    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)sync {
    [[DNNetworkController sharedInstance] synchronise];
}

@end

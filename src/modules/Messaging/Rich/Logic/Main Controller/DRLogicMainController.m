//
//  DRLogicMainController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "DRLogicMainController.h"
#import "DNModuleDefinition.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DCMMainController.h"
#import "DRLogicHelper.h"
#import "DNRichMessage.h"
#import "DNLoggingController.h"

@interface DRLogicMainController ()
@property(nonatomic, copy) void (^richMessageHandler)(id);
@property(nonatomic, strong) DNModuleDefinition *moduleDefinition;
@property(nonatomic, strong) DNSubscription *subscription;
@end

@implementation DRLogicMainController


+(DRLogicMainController *)sharedInstance
{
    static dispatch_once_t pred;
    static DRLogicMainController *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[DRLogicMainController alloc] initPrivate];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    
    self  = [super init];

    if (self) {

    }
    
    return self;
}


- (void)start {

    //Get unread chat messages:
    NSArray *unreadChat = [self allUnreadRichMessages];

    [unreadChat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *richMessage = obj;
        DNLocalEvent *richEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationRichMessage publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:richMessage];
        [[DNDonkyCore sharedInstance] publishEvent:richEvent];
    }];

    self.moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.1"];

    __weak DRLogicMainController *weakSelf = self;
    self.richMessageHandler = ^(id data) {

        DNRichMessage *richMessage = [DRLogicHelper saveRichMessage:data];

        if (richMessage) {
            DNLocalEvent *richEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationRichMessage
                                                                    publisher:NSStringFromClass([weakSelf class])
                                                                    timeStamp:[NSDate date]
                                                                         data:richMessage];
            [[DNDonkyCore sharedInstance] publishEvent:richEvent];

            [DCMMainController markMessageAsReceived:data];
        }
        else
            DNErrorLog(@"Could not create rich message from server notification: %@", data);
    };

    self.subscription = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationRichMessage handler:self.richMessageHandler];
    [self.subscription setAutoAcknowledge:NO];

    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:self.moduleDefinition subscriptions:@[self.subscription]];
}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:self.moduleDefinition subscriptions:@[self.subscription]];
}

- (NSArray *)allRichMessages {
    return [DRLogicHelper allRichMessages];
}

- (NSArray *)allUnreadRichMessages {
    return [DRLogicHelper allUnreadRichMessages];
}

- (void)deleteMessage:(NSString *)messageID {
    [DRLogicHelper deleteRichMessage:messageID];
}

- (void)markMessageAsRead:(NSString *)messageID {
    [DCMMainController markMessageAsRead:messageID];
}

- (NSArray *)filterRichMessages:(NSString *)filter {
    return [DRLogicHelper filteredRichMessage:filter tempContext:YES];
}

@end

//
//  DRLogicMainController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DRLogicMainController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DRLogicHelper.h"
#import "NSDate+DNDateHelper.h"
#import "DRLogicMainControllerHelper.h"
#import "DCAConstants.h"

@interface DRLogicMainController ()
@property(nonatomic, strong) DNLocalEventHandler backgroundNotificationsReceived;
@property(nonatomic, strong) DNSubscriptionBachHandler richMessageHandler;
@property(nonatomic, strong) NSMutableArray *backgroundNotifications;
@property(nonatomic, strong) DNLocalEventHandler notificationLoaded;
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

        [self setBackgroundNotifications:[[NSMutableArray alloc] init]];

        [self setVibrate:YES];

    }
    
    return self;
}

- (void)start {

    [self deleteAllExpiredMessages];

    [self setModuleDefinition:[[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.1.1"]];

    [self setSubscription:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationRichMessage batchHandler:[self richMessageHandler]]];

    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:[self moduleDefinition] subscriptions:@[[self subscription]]];
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventNotificationLoaded handler:[self notificationLoaded]];
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventBackgroundNotificationReceived handler:[self backgroundNotificationsReceived]];

    __weak DRLogicMainController *weakSelf = self;
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppWillEnterForegroundNotification handler:^(DNLocalEvent *event) {
        @synchronized (weakSelf.backgroundNotifications) {
            if ([[weakSelf backgroundNotifications] count]) {
                //Report influenced open:
                DNLocalEvent *pushOpenEvent = [[DNLocalEvent alloc] initWithEventType:kDAEventInfluencedAppOpen
                                                                        publisher:NSStringFromClass([weakSelf class])
                                                                        timeStamp:[NSDate date]
                                                                             data:[weakSelf backgroundNotifications]];
                [[DNDonkyCore sharedInstance] publishEvent:pushOpenEvent];
                [[weakSelf backgroundNotifications] removeAllObjects];
            }
        }
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNEventRegistration handler:^(DNLocalEvent *event) {
        BOOL wasUpdate = [[event data][@"IsUpdate"] boolValue];
        if (!wasUpdate) {
            [weakSelf deleteAllMessages:[weakSelf allRichMessagesAscending:YES]];
        }
    }];

    [[DNDonkyCore sharedInstance] registerService:NSStringFromClass([self class]) instance:self];

}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:[self moduleDefinition] subscriptions:@[[self subscription]]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventNotificationLoaded handler:[self notificationLoaded]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventBackgroundNotificationReceived handler:[self backgroundNotificationsReceived]];
}

#pragma mark -
#pragma mark - Helper Methods

- (NSArray *)allRichMessagesAscending:(BOOL)ascending {
    return [DRLogicHelper allRichMessagesAscending:ascending];
}

- (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending {
    return [DRLogicHelper richMessagesWithOffset:offset limit:limit ascending:ascending];
}

- (NSArray *)allUnreadRichMessages {
    return [DRLogicHelper allUnreadRichMessages];
}

- (void)deleteMessage:(DNRichMessage *)richMessage {
    [DRLogicHelper deleteRichMessage:richMessage];
}

- (void)deleteAllMessages:(NSArray *)richMessages {
    [DRLogicHelper deleteAllRichMessages:richMessages];
}

- (void)markMessageAsRead:(DNRichMessage *)message {
    [DRLogicHelper markMessageAsRead:message];
}

- (NSArray *)filterRichMessages:(NSString *)filter ascending:(BOOL)ascending {
    return [DRLogicHelper filteredRichMessage:filter tempContext:NO ascendingOrder:ascending];
}

- (BOOL)doesRichMessageExistForID:(NSString *)messageID {
    return [DRLogicHelper richMessageExistsForID:messageID];
}

- (DNRichMessage *)richMessageWithID:(NSString *)messageID {
    return [DRLogicHelper richMessageWithID:messageID];
}

- (BOOL)hasRichMessageExpired:(DNRichMessage *)richMessage {
    return [[richMessage expiryTimestamp] donkyHasDateExpired] || [[richMessage sentTimestamp] donkyHasMessageExpired];
}

- (void)richMessageNotificationsReceived:(NSArray *)notifications {
    @synchronized (self.backgroundNotifications) {
        [DRLogicMainControllerHelper richMessageNotificationReceived:notifications backgroundNotifications:[self backgroundNotifications]];
        [[self backgroundNotifications] removeAllObjects];
    }
}

- (void)deleteAllExpiredMessages {
    [DRLogicHelper deleteAllExpiredMessages];
}

#pragma mark -
#pragma mark - Getters:

- (DNSubscriptionBachHandler)richMessageHandler {
    if (!_richMessageHandler) {
        __weak DRLogicMainController *weakSelf = self;
        _richMessageHandler = [DRLogicMainControllerHelper richMessageHandler:weakSelf];
    }
    return _richMessageHandler;
}

- (DNLocalEventHandler)notificationLoaded {
    if (!_notificationLoaded) {
        __weak DRLogicMainController *weakSelf = self;
        _notificationLoaded = [DRLogicMainControllerHelper notificationLoaded:weakSelf];
    }
    return _notificationLoaded;
}

- (DNLocalEventHandler)backgroundNotificationsReceived {
    if (!_backgroundNotificationsReceived) {
        _backgroundNotificationsReceived = [DRLogicMainControllerHelper backgroundNotificationsReceived:[self backgroundNotifications]];
    }
    return _backgroundNotificationsReceived;
}

#pragma mark -
#pragma mark - Private Services

- (NSInteger)unreadMessageCount {
    return [[self allUnreadRichMessages] count];
}

@end
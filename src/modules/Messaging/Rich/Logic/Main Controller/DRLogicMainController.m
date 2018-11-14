//
//  DRLogicMainController.m
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRLogicMainController.h"
#import <Donky_Core_SDK/DNDonkyCore.h>
#import <Donky_Core_SDK/DNConstants.h>
#import "DRLogicHelper.h"
#import "DRLogicMainControllerHelper.h"

@interface DRLogicMainController ()
@property (nonatomic, copy) DNSubscriptionBatchHandler richMessageHandler;
@property (nonatomic, copy) DNSubscriptionBatchHandler richMessageDeletedHandler;
@property (nonatomic, copy) DNSubscriptionBatchHandler richMessageReadHandler;
@property (nonatomic, strong) DNModuleDefinition *moduleDefinition;
@property (nonatomic, strong) DNSubscription *richMessageSubscription;
@property (nonatomic, strong) DNSubscription *richMessageDeletedSubscription;
@property (nonatomic, strong) DNSubscription *richMessageReadSubscription;
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

        [self setVibrate:YES];

    }
    
    return self;
}

- (void)start {

    [DRLogicMainController deleteMaxLifeRichMessages];

    [self setModuleDefinition:[[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.2.1.2"]];

    [self setRichMessageSubscription:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationRichMessage
                                                                         batchHandler:[self richMessageHandler]]];
    [[self richMessageSubscription] setAutoAcknowledge:NO];

    [self setRichMessageDeletedSubscription:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationSyncMessageDeleted
                                                                                batchHandler:[self richMessageDeletedHandler]]];
    [[self richMessageDeletedSubscription] setAutoAcknowledge:NO];

    [self setRichMessageReadSubscription:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationSyncMessageRead
                                                                             batchHandler:[self richMessageReadHandler]]];
    [[self richMessageReadSubscription] setAutoAcknowledge:NO];

    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:[self moduleDefinition]
                                                  subscriptions:@[[self richMessageSubscription], [self richMessageReadSubscription], [self richMessageDeletedSubscription]]];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNEventRegistration handler:^(DNLocalEvent *event) {
        BOOL wasUpdate = [[event data][@"IsUpdate"] boolValue];
        if (!wasUpdate) {
            [DRLogicMainController deleteAllMessages:[DRLogicMainController allRichMessagesAscending:YES]];
        }
    }];

    [[DNDonkyCore sharedInstance] registerService:NSStringFromClass([self class]) instance:self];

}

- (void)stop {
    if ([self moduleDefinition]) {
        [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:[self moduleDefinition]
                                                        subscriptions:@[[self richMessageSubscription], [self richMessageDeletedSubscription], [self richMessageReadSubscription]]];
    }
    
    [[DNDonkyCore sharedInstance] unRegisterService:NSStringFromClass([self class])];
}

#pragma mark -
#pragma mark - Helper Methods

- (NSArray *)allRichMessagesAscending:(BOOL)ascending {
    return [DRLogicMainController allRichMessagesAscending:ascending];
}

- (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending {
    return [DRLogicMainController richMessagesWithOffset:offset limit:limit ascending:ascending];
}

- (NSArray *)allUnreadRichMessages {
    return [DRLogicMainController allUnreadRichMessages];
}

- (void)deleteMessage:(DNRichMessage *)richMessage {
    [DRLogicMainController deleteMessage:richMessage];
}

- (void)deleteAllMessages:(NSArray *)richMessages {
    [DRLogicMainController deleteAllMessages:richMessages];
}

- (void)markMessageAsRead:(DNRichMessage *)message {
    [DRLogicMainController markMessageAsRead:message];
}

- (NSArray *)filterRichMessages:(NSString *)filter ascending:(BOOL)ascending {
    return [DRLogicMainController filterRichMessages:filter ascending:ascending];
}

- (BOOL)doesRichMessageExistForID:(NSString *)messageID {
    return [DRLogicMainController doesRichMessageExistForID:messageID];
}

- (DNRichMessage *)richMessageWithID:(NSString *)messageID {
    return [DRLogicMainController richMessageWithID:messageID];
}

- (void)richMessageNotificationsReceived:(NSArray *)notifications {
    [DRLogicMainController richMessageNotificationsReceived:notifications];
}

+ (void)richMessageNotificationsReceived:(NSArray *)notifications {
    [DRLogicMainControllerHelper richMessageNotificationReceived:notifications
                                             backgroundNotifications:nil];
}

- (void)deleteAllExpiredMessages {
    [DRLogicMainController deleteAllExpiredMessages];
}

- (void)deleteMaxLifeRichMessages {
    [DRLogicMainController deleteMaxLifeRichMessages];
}

//Class methods:

+ (NSArray *)allRichMessagesAscending:(BOOL)ascending {
    return [DRLogicHelper allRichMessagesAscending:ascending];
}

+ (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending {
    return [DRLogicHelper richMessagesWithOffset:offset limit:limit ascending:ascending];
}

+ (NSArray *)allUnreadRichMessages {
    return [DRLogicHelper allUnreadRichMessages];
}

+ (void)deleteMessage:(DNRichMessage *)richMessage {
    [DRLogicHelper deleteRichMessage:richMessage];
}

+ (void)deleteAllMessages:(NSArray *)richMessages {
    [DRLogicHelper deleteAllRichMessages:richMessages];
}

+ (void)markMessageAsRead:(DNRichMessage *)message {
    [DRLogicHelper markMessageAsRead:message];
}

+ (void)markMessagesAsRead:(NSArray *)messages completion:(DNCompletionBlock)completion {
    [DRLogicHelper markMessagesAsRead:messages completion:completion];
}

+ (void)markAllRichMessagesAsRead:(DNCompletionBlock)completion {
    [DRLogicHelper markAllRichMessagesAsRead:completion];
}

+ (NSArray *)filterRichMessages:(NSString *)filter ascending:(BOOL)ascending {
    return [DRLogicHelper filteredRichMessage:filter ascendingOrder:ascending];
}

+ (BOOL)doesRichMessageExistForID:(NSString *)messageID {
    return [DRLogicHelper richMessageExistsForID:messageID];
}

+ (DNRichMessage *)richMessageWithID:(NSString *)messageID {
    return [DRLogicHelper richMessageWithID:messageID];
}

+ (void)deleteAllExpiredMessages {
    [DRLogicHelper deleteAllExpiredMessages];
}

+ (void)deleteMaxLifeRichMessages {
    [DRLogicHelper deleteMaxLifeRichMessages];
}

#pragma mark -
#pragma mark - Getters:

- (DNSubscriptionBatchHandler)richMessageHandler {
    if (!_richMessageHandler) {
        _richMessageHandler = [DRLogicMainControllerHelper richMessageHandler];
    }
    return _richMessageHandler;
}

- (DNSubscriptionBatchHandler)richMessageDeletedHandler {
    if (!_richMessageDeletedHandler) {
        _richMessageDeletedHandler = [DRLogicMainControllerHelper richMessageDeleted];
    }
    return _richMessageDeletedHandler;
}

- (DNSubscriptionBatchHandler)richMessageReadHandler {
    if (!_richMessageReadHandler) {
        _richMessageReadHandler = [DRLogicMainControllerHelper richMessageReadHandler];
    }
    return _richMessageReadHandler;
}

#pragma mark -
#pragma mark - Private Services

- (NSInteger)unreadMessageCount {
    return [[DRLogicMainController allUnreadRichMessages] count];
}

@end

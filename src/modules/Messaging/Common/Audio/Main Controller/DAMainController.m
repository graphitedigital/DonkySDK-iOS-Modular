//
//  DAMainController.m
//  DonkyCommonAudio
//
//  Created by Chris Watson on 31/07/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DAMainController.h"
#import "DNConstants.h"
#import "DNLoggingController.h"
#import "DNDonkyCore.h"

@interface DAMainController ()
@property (nonatomic, strong) DNLocalEventHandler audioFileHandler;
@property (nonatomic, strong) NSMutableDictionary *audioFiles;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation DAMainController

+(DAMainController *)sharedInstance
{
    static dispatch_once_t pred;
    static DAMainController *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DAMainController alloc] initPrivate];
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

        [self setAudioFiles:[[NSMutableDictionary alloc] init]];
        [self setVibrate:YES];

    }

    return self;
}

- (void)start {
    
    __weak typeof(self) weakSelf = self;
    [self setAudioFileHandler:^(DNLocalEvent *event) {
        [weakSelf playAudioFileForMessage:(DonkyAudioMessageTypes) [[event data] integerValue]];
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DAPlayFile handler:[self audioFileHandler]];

    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"];
    [[DNDonkyCore sharedInstance] registerModule:moduleDefinition];
    
    [[DNDonkyCore sharedInstance] registerService:NSStringFromClass([self class]) instance:self];

}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:DAPlayFile handler:[self audioFileHandler]];
}

- (void)playAudioFileForMessage:(DonkyAudioMessageTypes)messageType {

    NSURL *audioFile = nil;

    switch (messageType) {

        case DASimplePushMessage:
            audioFile = [self audioFiles][kDNDonkyNotificationSimplePush];
            break;
        case DARichMessage:
            audioFile = [self audioFiles][kDNDonkyNotificationRichMessage];
            break;
        case DACustomContent:
            audioFile = [self audioFiles][kDNDonkyNotificationCustomDataKey];
            break;
        case DAMisc:
            audioFile = [self audioFiles][@"DAMisc"];
        default:
            break;
    }

    if ([self shouldVibrate]) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    if (!audioFile) {
        DNErrorLog(@"cannot play audio for message type: %lu, have you saved the audio file name?", (unsigned long)messageType);
        return;
    }

    NSError *error;
    [self setAudioPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:audioFile error:&error]];
    [[self audioPlayer] play];

    if (error) {
        DNErrorLog(@"couldn't play audio file: %@", [error localizedDescription]);
    }
}

- (void)setAudioFile:(NSURL *)audioFile forMessageType:(DonkyAudioMessageTypes)messageType {
    if (messageType & DASimplePushMessage) {
        [self audioFiles][kDNDonkyNotificationSimplePush] = audioFile;
    }
    if (messageType & DARichMessage) {
        [self audioFiles][kDNDonkyNotificationRichMessage] = audioFile;
    }
    if (messageType & DACustomContent) {
        [self audioFiles][kDNDonkyNotificationCustomDataKey] = audioFile;
    }
    if (messageType & DAMisc) {
        [self audioFiles][@"DAMisc"] = audioFile;
    }
}

@end
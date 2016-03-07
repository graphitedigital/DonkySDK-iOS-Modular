//
//  DAMainController.h
//  DonkyCommonAudio
//
//  Created by Donky Networks on 31/07/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DonkyAudioMessageTypes)
{
    DASimplePushMessage = 1 << 0,
    DARichMessage = 1 << 1,
    DACustomContent = 1 << 2,
    DAMisc = 1 << 3,
};

@interface DAMainController : NSObject

/*!
 BOOL to determine if the device should vibrate when a sound is played. This will only happen if the message
 is of type: DASimplePush, DARichMessage, DAChatMessage or DACustomContent.
 
 @since 2.6.5.4
 */
@property (nonatomic, getter=shouldVibrate) BOOL vibrate;

/*!
 The shared instance that is used to manage the audio controller.
 
 @return the shared instance
 
 @since 2.6.5.4
 */
+ (DAMainController *)sharedInstance;

/*!
 Method to start the audio controller. This sets up any required properties and behaviour.
 
 @since 2.6.5.4
 */
- (void)start;

/*!
 Method to stop the audio controller, this stops and services or behaviour.
 
 @since 2.6.5.4
 */
- (void)stop;

/*!
 Method to play an audio file based on a type of message. You must set the audio file 
 using setAudioFile:forMessageType: before calling this method.
 
 @param messageType the type of message that is to be played.
 
 @since 2.6.5.4
 */
- (void)playAudioFileForMessage:(NSInteger)messageType;

/*!
 Class method that performs the same action as the playAudioFileForMessage:
 
 @param messageType the message type that is to be played.
 
 @since 2.6.5.4
 */
+ (void)playAuioFileForMessage:(NSInteger)messageType;

/*!
 Method to 'set' an audio file so that it can be played at a later date.
 
 @param audioFile   the URL to the audio file that should be played.
 @param messageType the message type to which this audio file is related.
 
 @since 2.6.5.4
 */
- (void)setAudioFile:(NSURL *)audioFile forMessageType:(DonkyAudioMessageTypes)messageType;

/*!
 Class method that performs the same action as setAudioFile:ForMessageType:
 
 @param audioFile   the URL to the audio file that should be played.
 @param messageType the message type to which this aduio file is related.
 
 @since 2.6.5.4
 */
+ (void)setAudioFile:(NSURL *)audioFile forMessageType:(DonkyAudioMessageTypes)messageType;

@end

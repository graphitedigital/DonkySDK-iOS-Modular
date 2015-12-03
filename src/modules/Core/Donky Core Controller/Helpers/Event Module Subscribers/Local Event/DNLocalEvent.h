//
//  DNLocalEvent.h
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 Class used by modules to register for local event alerts.
 
 @since 2.0.0.0
 */
@interface DNLocalEvent : NSObject

/*!
 The event type that the module is interested in.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *eventType;

/*!
 The time that the event was published.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSDate *timeStamp;

/*!
 The publisher of the event. Use this if you are only interested in events 
 published from one source.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *publisher;

/*!
 The data to be passed with this event.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) id data;

/*!
 Initialiser to create a new DNLocalEvent object.
 
 @param eventType the event type that should trigger this local event.
 @param handler   the handler to invoke when the event has been published.
 
 @return a new instance of DNLocalEvent with the provided details.
 
 @since 2.0.0.0
 */
- (instancetype)initWithEventType:(NSString *)eventType publisher:(NSString *)publisher timeStamp:(NSDate *)timeStamp data:(id)data;

@end

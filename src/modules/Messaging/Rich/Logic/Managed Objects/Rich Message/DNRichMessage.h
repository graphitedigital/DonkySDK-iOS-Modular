//
//  DNRichMessage.h
//  RichLogic
//
//  Created by Donky Networks on 08/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNMessage.h"


@interface DNRichMessage : DNMessage

@property (nonatomic, retain) NSNumber * canShare;
@property (nonatomic, retain) NSString * expiredBody;
@property (nonatomic, retain) NSString * messageDescription;
@property (nonatomic, retain) NSDate * messageReceivedTimestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlToShare;

@end

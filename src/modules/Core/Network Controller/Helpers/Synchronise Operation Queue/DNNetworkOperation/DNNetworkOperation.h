//
//  DNNetworkOperation.h
//  ChatUI
//
//  Created by Donky Networks on 24/09/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"

@interface DNNetworkOperation : NSOperation

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, readonly) NSDate *timeStarted;

- (instancetype)initWithSyncParams:(NSDictionary *)params successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure;

- (instancetype)initWithDataSend:(NSDictionary *)params completion:(DNSignalRCompletionBlock)completion;

@end

//
//  DNNetworkControllerQueue.h
//  ChatUI
//
//  Created by Donky Networks on 24/09/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"

@interface DNNetworkControllerQueue : NSOperationQueue

- (void)sendData:(NSDictionary *)params completion:(DNSignalRCompletionBlock) completion;

- (BOOL)synchroniseWithParams:(NSDictionary *)params successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure;

@end

//
//  DNSessionManager.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 02/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNSessionManager.h"
#import "DNConstants.h"
#import "DNDonkyNetworkDetails.h"
#import "DNLoggingController.h"

@interface DNSessionManager ()
@property (nonatomic, getter=isUsingSecure, readwrite) BOOL usingSecure;
@end

@implementation DNSessionManager

- (instancetype)initWithSecureURl:(BOOL)secure {

    if (secure && ![DNDonkyNetworkDetails secureServiceRootUrl]) {
        return nil;
    }

    self = [super initWithBaseURL:secure ? [NSURL URLWithString:[DNDonkyNetworkDetails secureServiceRootUrl]] : [NSURL URLWithString:kDNNetworkHostURL]];

    if (self) {

        [self setUsingSecure:secure];

        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [serializer setValue:@"DonkyiOSModularSdk" forHTTPHeaderField:@"DonkyClientSystemIdentifier"];
        
        if (![self isUsingSecure]) {
            [serializer setValue:[DNDonkyNetworkDetails apiKey] forHTTPHeaderField:@"ApiKey"];
        }

        if ([self isUsingSecure] && [DNDonkyNetworkDetails accessToken]) {
            [serializer setValue:[NSString stringWithFormat:@"Bearer %@", [DNDonkyNetworkDetails accessToken]] forHTTPHeaderField:@"Authorization"];
        }

        [self setRequestSerializer:serializer];
    }

    return self;
}

- (NSURLSessionDataTask *)performPostWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    return [self POST:route parameters:parameters success:successBlock failure:failureBlock];
}

- (NSURLSessionDataTask *)performPutWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    return [self PUT:route parameters:parameters success:successBlock failure:failureBlock];
}

- (NSURLSessionDataTask *)performDeleteWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    return [self DELETE:route parameters:parameters success:successBlock failure:failureBlock];
}

- (NSURLSessionDataTask *)performGetWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    return [self GET:route parameters:parameters success:successBlock failure:failureBlock];
}


@end

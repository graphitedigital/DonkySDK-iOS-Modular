//
//  DNAccountController.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNAccountController.h"
#import "DNDataController.h"
#import "DNNetworkController.h"
#import "DNConstants.h"
#import "DNLoggingController.h"
#import "DNUserAuthentication.h"
#import "DNDonkyCore.h"
#import "DNDonkyNetworkDetails.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNUserDefaultsHelper.h"
#import "DNAccountRegistrationResponse.h"
#import "DNDeviceDetailsHelper.h"
#import "DNConfigurationController.h"
#import "DNErrorController.h"
#import "DNTag.h"
#import "NSManagedObject+DNHelper.h"
#import "DNSignalRInterface.h"
#import "NSDate+DNDateHelper.h"

static NSString *const DNUserParameters = @"user";
static NSString *const DNClientParameters = @"client";
static NSString *const DNDeviceParameters = @"device";
static NSString *const DNFailureKey = @"failureKey";
static NSString *const DNMissingNetworkID = @"MissingNetworkId";

@implementation DNAccountController

+ (void)initialiseUserDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    //We register if there is no user registered OR if the device user we are registering with is different from the current user.
    //DO NOT use this to update user device details. Re-Registering the same user could potentially delete the user from the network and re add them.
    if (![DNDonkyNetworkDetails isDeviceRegistered]) {
        [DNAccountController registerDeviceUser:userDetails deviceDetails:deviceDetails isUpdate:NO success:successBlock failure:failureBlock];
    }
    else if ([DNDonkyNetworkDetails newUserDetails] || (![[[[DNAccountController registrationDetails] userDetails] userID] isEqualToString:[userDetails userID]] && [[[DNAccountController registrationDetails] userDetails] userID])) {
        [DNAccountController updateUserDetails:userDetails automaticallyHandleUserIDTaken:YES success:^(NSURLSessionDataTask *task, id responseData) {
            [DNAccountController updateNetworkDetails];
            if (successBlock) {
                successBlock(task, responseData);
            }
        } failure:failureBlock];
    }
    else if (![DNDonkyNetworkDetails hasValidAccessToken]) {
        [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task, id responseData) {
            [DNAccountController updateNetworkDetails];
            if (successBlock) {
                successBlock(task, responseData);
            }
        } failure:failureBlock];
    }
    else {
        [DNAccountController updateNetworkDetails];
        if (successBlock) {
            successBlock(nil, nil);
        }
    }
}

+ (DNAccountRegistrationResponse *)registrationResponseWithData:(id)responseData deviceDetails:(DNDeviceDetails *)deviceDetails clientDetails:(DNClientDetails *)clientDetails apiKey:(NSString *)apiKey {
    DNAccountRegistrationResponse *accountRegistrationResponse = [[DNAccountRegistrationResponse alloc] initWithRegistrationResponse:responseData];
    
    [DNDonkyNetworkDetails saveAccessToken:[accountRegistrationResponse accessToken]];
    [DNDonkyNetworkDetails saveSecureServiceRootUrl:[accountRegistrationResponse rootURL]];
    [DNDonkyNetworkDetails saveDeviceID:[accountRegistrationResponse deviceId]];
    [DNDonkyNetworkDetails saveNetworkID:[accountRegistrationResponse networkId]];
    [DNDonkyNetworkDetails saveTokenExpiry:[accountRegistrationResponse tokenExpiry]];
    [DNDonkyNetworkDetails saveNetworkProfileID:[accountRegistrationResponse networkProfileID]];
    [DNDonkyNetworkDetails saveDeviceSecret:[deviceDetails deviceSecret]];
    [DNDonkyNetworkDetails saveSDKVersion:[clientDetails sdkVersion]];
    [DNDonkyNetworkDetails saveOperatingSystemVersion:[deviceDetails operatingSystem]];
    [DNDonkyNetworkDetails saveAPIKey:apiKey];
    [DNDonkyNetworkDetails savePushEnabled:YES];
    [DNDonkyNetworkDetails saveSignalRURL:[accountRegistrationResponse signalRURL]];
    
    return accountRegistrationResponse;
}

+ (void)startAuthenticationWithCompletion:(DNAuthenticationRequestCompletion)completion {
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:NO route:kDNNetworkAuthenticationStart httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
       
        DNAuthResponse *authenticationResponse = [[DNAuthResponse alloc] initWithAuthenticationStartResponse:responseData];
        
        DNAuthenticationObject *authenticationObject = [[DNAuthenticationObject alloc] initWithUserID:[[[DNAccountController registrationDetails] userDetails] userID] nonce:[authenticationResponse nonce]];
        
        if (completion) {
            completion(authenticationResponse, authenticationObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNAuthenticationObject *authenticationObject = [[DNAuthenticationObject alloc] initWithUserID:[[[DNAccountController registrationDetails] userDetails] userID] nonce:nil];
        if (completion) {
            completion(nil, authenticationObject, error);
        }
    }];
}

+ (void)authenticatedRegistrationForUser:(DNUserDetails *)userDetails device:(DNDeviceDetails *)deviceDetails authenticationDetail:(DNAuthResponse *)authDetails token:(NSString *)token success:(DNNetworkSuccessBlock)success failure:(DNNetworkFailureBlock)failure {

    if (!deviceDetails) {
        deviceDetails = [[DNDeviceDetails alloc] init];
    }
    
    DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
    
    NSMutableDictionary *registrationParameters = [[NSMutableDictionary alloc] init];
    [registrationParameters dnSetObject:[deviceDetails parameters] forKey:DNDeviceParameters];
    [registrationParameters dnSetObject:[clientDetails parameters] forKey:DNClientParameters];
    [registrationParameters dnSetObject:[userDetails parameters] forKey:DNUserParameters];

    BOOL reReg = NO;

    if (![DNAccountController isRegistered] || ([DNAccountController isRegistered] && ![[userDetails userID] isEqualToString:[[[DNAccountController registrationDetails] userDetails] userID]])) {
        reReg = YES;
    }

    [registrationParameters dnSetObject:reReg ? @"true" : @"false" forKey:@"isReregistration"];

    NSMutableDictionary *authenticationDetails = [[authDetails parameters] mutableCopy];
    [authenticationDetails dnSetObject:token forKey:@"token"];
    [registrationParameters dnSetObject:authenticationDetails forKey:@"authenticationDetail"];

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:NO route:kDNNetworkAuthenticationRegistration httpMethod:DNPost parameters:registrationParameters success:^(NSURLSessionDataTask *task, id responseData) {

        NSString *apiKey = [DNDonkyNetworkDetails apiKey];
        [DNUserDefaultsHelper resetUserDefaults];
        
        DNAccountRegistrationResponse *accountRegistrationResponse = [DNAccountController registrationResponseWithData:responseData deviceDetails:deviceDetails clientDetails:clientDetails apiKey:apiKey];

        //Store Configuration items:
        [DNConfigurationController saveConfiguration:[accountRegistrationResponse configuration]];
        
        //We have an anonymous reg
        if ([userDetails isAnonymous]) {
            DNUserDetails *anonymousDetails = [[DNUserDetails alloc] initWithUserID:[accountRegistrationResponse userId]
                                                                        displayName:[accountRegistrationResponse userId]
                                                                       emailAddress:nil
                                                                       mobileNumber:nil
                                                                        countryCode:nil
                                                                          firstName:nil
                                                                           lastName:nil
                                                                           avatarID:nil
                                                                       selectedTags:nil
                                                               additionalProperties:nil
                                                                          anonymous:YES];
            [DNAccountController saveUserDetails:anonymousDetails];
        }
        else {
            if (!userDetails) {
                DNUserDetails *user = [[DNUserDetails alloc] initWithUserID:[accountRegistrationResponse userId]
                                                                displayName:[accountRegistrationResponse userId]
                                                               emailAddress:nil
                                                               mobileNumber:nil
                                                                countryCode:nil
                                                                  firstName:nil
                                                                   lastName:nil
                                                                   avatarID:nil
                                                               selectedTags:nil
                                                       additionalProperties:nil];
                [DNAccountController saveUserDetails:user];
            }
            else {
                [DNAccountController saveUserDetails:userDetails];
            }
        }

        [DNDeviceDetailsHelper saveAdditionalProperties:[deviceDetails additionalProperties]];
        [DNDeviceDetailsHelper saveDeviceName:[deviceDetails deviceName]];
        [DNDeviceDetailsHelper saveDeviceType:[deviceDetails type]];

        DNLocalEvent *registrationEvent = [[DNLocalEvent alloc] initWithEventType:kDNEventRegistration
                                                                        publisher:NSStringFromClass([self class])
                                                                        timeStamp:[NSDate date]
                                                                             data:@{@"IsUpdate" : @(!reReg)}];

        [[DNDonkyCore sharedInstance] publishEvent:registrationEvent];

        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventTokenRefreshed
                                                                 publisher:NSStringFromClass([DNAccountController class])
                                                                 timeStamp:[NSDate date]
                                                                      data:[accountRegistrationResponse configuration]];
        [[DNDonkyCore sharedInstance] publishEvent:localEvent];

        if (success) {
            success(responseData, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(nil, error);
        }
    }];
}

+ (void)refreshAuthentication:(DNCompletionBlock)completionBlock {

    if ([[DNDonkyCore sharedInstance] authenticationHandler]) {
        DNAuthenticationCompletion block = ^(NSString *token, DNAuthResponse *authResponse) {

            DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
            DNDeviceDetails *deviceDetails = [[DNAccountController registrationDetails] deviceDetails];

            NSMutableDictionary *parameters = [[clientDetails parameters] mutableCopy];

            NSMutableDictionary *authenticationDetails = [[authResponse parameters] mutableCopy];
            [authenticationDetails dnSetObject:token forKey:@"token"];
            [parameters dnSetObject:authenticationDetails forKey:@"authenticationDetail"];
            [parameters dnSetObject:[DNDonkyNetworkDetails networkId] forKey:@"networkId"];
            [parameters dnSetObject:[DNDonkyNetworkDetails deviceSecret] forKey:@"deviceSecret"];
            [parameters dnSetObject:[deviceDetails operatingSystem] forKey:@"operatingSystem"];

            [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:NO route:kDNNetworkAuthenticationAuthenticate httpMethod:DNPost parameters:parameters success:^(NSURLSessionDataTask *task, id responseData) {

                DNAccountRegistrationResponse *tokenResponse = [[DNAccountRegistrationResponse alloc] initWithRefreshTokenResponse:responseData];
                
                //Store Configuration items:
                [DNDonkyNetworkDetails saveAccessToken:[tokenResponse accessToken]];
                [DNDonkyNetworkDetails saveTokenExpiry:[tokenResponse tokenExpiry]];
                [DNDonkyNetworkDetails saveSecureServiceRootUrl:[tokenResponse rootURL]];

                [DNConfigurationController saveConfiguration:[tokenResponse configuration]];

                if (completionBlock) {
                    completionBlock(nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (completionBlock) {
                    if ([DNErrorController serviceReturned:401 error:error] || [DNErrorController serviceReturnedFailureKey:@"UserNotFound" error:error]) {
                         DNAuthenticationCompletion block2 = ^(NSString *token2, DNAuthResponse *authResponse2) {
                             completionBlock(@{@"token" : token2, @"error" : error, @"authResponse" : authResponse2});
                         };
                        [DNAccountController startAuthenticationWithCompletion:^(DNAuthResponse *authDetails, DNAuthenticationObject *expectedDetails,  NSError *error2) {
                            if ([[DNDonkyCore sharedInstance] authenticationHandler]) {
                                [[DNDonkyCore sharedInstance] authenticationHandler](block2, authDetails, expectedDetails);
                            }
                        }];
                    }
                    else {
                        completionBlock(nil);
                    }
                }
            }];
        };
        
        [DNAccountController startAuthenticationWithCompletion:^(DNAuthResponse *authDetails, DNAuthenticationObject *expectedDetails, NSError *error) {
            if ([[DNDonkyCore sharedInstance] authenticationHandler]) {
                [[DNDonkyCore sharedInstance] authenticationHandler](block, authDetails, expectedDetails);
            }
        }];
    }
}

+ (void)registerDeviceUser:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails isUpdate:(BOOL)update success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    if ([[DNDonkyCore sharedInstance] isUsingAuth]) {
        if (successBlock) {
            successBlock(nil, nil);
        }
        return;
    }

    DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
    NSMutableDictionary *registrationParameters = [[NSMutableDictionary alloc] init];
    [registrationParameters dnSetObject:[deviceDetails parameters] forKey:DNDeviceParameters];
    [registrationParameters dnSetObject:[clientDetails parameters] forKey:DNClientParameters];
    [registrationParameters dnSetObject:[userDetails parameters] forKey:DNUserParameters];

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:update route:kDNNetworkRegistration httpMethod:update ? DNPut : DNPost parameters:registrationParameters success:^(NSURLSessionDataTask *task, id responseData) {
        @try {

            NSString *apiKey = [DNDonkyNetworkDetails apiKey];
            [DNUserDefaultsHelper resetUserDefaults];
            
            DNAccountRegistrationResponse *accountRegistrationResponse = [DNAccountController registrationResponseWithData:responseData deviceDetails:deviceDetails clientDetails:clientDetails apiKey:apiKey];
            
            //Store Configuration items:
            [DNConfigurationController saveConfiguration:[accountRegistrationResponse configuration]];
            //We have an anonymous reg
            if ([userDetails isAnonymous]) {
                DNUserDetails *anonymousDetails = [[DNUserDetails alloc] initWithUserID:[accountRegistrationResponse userId]
                                                                            displayName:[accountRegistrationResponse userId]
                                                                           emailAddress:nil
                                                                           mobileNumber:nil
                                                                            countryCode:nil
                                                                              firstName:nil
                                                                               lastName:nil
                                                                               avatarID:nil
                                                                           selectedTags:nil
                                                                   additionalProperties:nil
                                                                              anonymous:YES];
                [DNAccountController saveUserDetails:anonymousDetails];
            }
            else {
                [DNAccountController saveUserDetails:userDetails];
            }

            [DNDeviceDetailsHelper saveAdditionalProperties:[deviceDetails additionalProperties]];
            [DNDeviceDetailsHelper saveDeviceName:[deviceDetails deviceName]];
            [DNDeviceDetailsHelper saveDeviceType:[deviceDetails type]];

            DNLocalEvent *registrationEvent = [[DNLocalEvent alloc] initWithEventType:kDNEventRegistration
                                                                            publisher:NSStringFromClass([self class])
                                                                            timeStamp:[NSDate date]
                                                                                 data:@{@"IsUpdate" : @(update)}];

            [[DNDonkyCore sharedInstance] publishEvent:registrationEvent];

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventTokenRefreshed
                                                                     publisher:NSStringFromClass([DNAccountController class])
                                                                     timeStamp:[NSDate date]
                                                                          data:[accountRegistrationResponse configuration]];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];

            if (successBlock) {
                successBlock(task, responseData);
            }
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            if (failureBlock) {
                failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

+ (void)refreshAccessTokenSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    if (![DNDonkyNetworkDetails isDeviceRegistered]) {
        failureBlock(nil, [DNErrorController errorCode:9000 userInfo:@{@"Reason" : @"Device isn't registered so cannot refresh token"}]);
        return;
    }
    
    if ([[DNDonkyCore sharedInstance] isUsingAuth]) {
        //We close the connection as our token is now invalid:
        [DNSignalRInterface closeConnection];
        
        [DNAccountController refreshAuthentication:^(id data) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSError *error = data[@"error"];
                NSString *token = data[@"token"];
                if ([DNErrorController serviceReturned:401 error:error] || [DNErrorController serviceReturnedFailureKey:@"UserNotFound" error:error]) {
                    DNErrorLog(@"User is unauthorised for token refresh. User details may have been deleted on the network...\nOR NetworkID is invalid.\nRe-registering user...");
                    [DNSignalRInterface closeConnection];
                    [DNDonkyNetworkDetails saveNetworkID:nil];
                    
                    DNAuthResponse *authResponse = data[@"authResponse"];
                    
                    [DNAccountController authenticatedRegistrationForUser:[[DNAccountController registrationDetails] userDetails]
                                                                   device:[[DNAccountController registrationDetails] deviceDetails]
                                                     authenticationDetail:authResponse
                                                                    token:token
                                                                  success:successBlock
                                                                  failure:failureBlock];
                }
                else if ([DNErrorController serviceReturned:403 error:error] && [DNAccountController isRegistered]) {
                    //We are suspended:
                    [DNAccountController setIsSuspended:YES];
                    if (failureBlock) {
                        failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKSuspendedUser]);
                    }
                }
                else if (error) {
                    if (failureBlock) {
                        failureBlock(nil, error);
                    }
                }
            }
            else if (successBlock) {
                [DNSignalRInterface openConnection];
                successBlock(nil, nil);
            }
        }];

        return;
    }

    if (![DNDonkyNetworkDetails hasValidAccessToken]) {

        //We close the connection as our token is now invalid:
        [DNSignalRInterface closeConnection];

        DNUserAuthentication *userAuthentication = [[DNUserAuthentication alloc] init];

        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:NO
                                                                      route:kDNNetworkAuthentication
                                                                 httpMethod:DNPost
                                                                 parameters:[userAuthentication parameters]
                                                                    success:^(NSURLSessionDataTask *task, id responseData) {
            @try {

                DNAccountRegistrationResponse *tokenResponse = [[DNAccountRegistrationResponse alloc] initWithRefreshTokenResponse:responseData];
                [DNDonkyNetworkDetails saveAccessToken:[tokenResponse accessToken]];
                [DNDonkyNetworkDetails saveTokenExpiry:[tokenResponse tokenExpiry]];

                //We open the connection:
                [DNSignalRInterface openConnection];

                DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventTokenRefreshed
                                                                         publisher:NSStringFromClass([DNAccountController class])
                                                                         timeStamp:[NSDate date]
                                                                              data:[tokenResponse configuration]];
                [[DNDonkyCore sharedInstance] publishEvent:localEvent];

                if ([DNDonkyNetworkDetails isSuspended]) {
                    //We were suspended so re-initialise:
                    [DNAccountController setIsSuspended:NO];
                    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:[DNDonkyNetworkDetails apiKey]
                                                           userDetails:[[DNAccountController registrationDetails] userDetails]
                                                         deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                                                               success:successBlock failure:failureBlock];
                }
                else if (successBlock) {
                    successBlock(task, responseData);
                }
            }
            @catch (NSException *exception) {
                DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                if(failureBlock) {
                    failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //Specific for this call:
            if ([DNErrorController serviceReturned:401 error:error]) {
                DNErrorLog(@"User is unauthorised for token refresh. User details may have been deleted on the network...\n OR NetworkID is invalid.\nRe-registering user...");
                [DNSignalRInterface closeConnection];
                [DNDonkyNetworkDetails saveNetworkID:nil];
                [DNAccountController registerDeviceUser:[[DNAccountController registrationDetails] userDetails]
                                          deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                                               isUpdate:NO
                                                success:successBlock
                                                failure:failureBlock];
            }
            else if ([DNAccountController isRegistered] || [[error userInfo][DNFailureKey] isEqualToString:DNMissingNetworkID]) {
                DNErrorLog(@"%@", task);
            }
            
            else if ([DNErrorController serviceReturned:403 error:error] && [DNAccountController isRegistered]) {
                //We are suspended:
                [DNAccountController setIsSuspended:YES];
                if (failureBlock) {
                    failureBlock(task, [DNErrorController errorWithCode:DNCoreSDKSuspendedUser]);
                }
            }
            else if (failureBlock) {
                failureBlock(task, error);
            }
        }];
    }
    else { //We have a valid token, so simply start a new timer.
        if (successBlock) {
            successBlock(nil, nil);
        }
    }
}

+ (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock {
    [DNAccountController registerDeviceUser:userDetails deviceDetails:deviceDetails isUpdate:YES success:^(NSURLSessionDataTask *task, id responseData) {
        DNLocalEvent *registrationChanged = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedDevice publisher:NSStringFromClass([DNAccountController class]) timeStamp:[NSDate date] data:deviceDetails];
        [[DNDonkyCore sharedInstance] publishEvent:registrationChanged];
        if (successBlock) {
            successBlock(task, responseData);
        }
    } failure:failureBlock];
}

+ (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [DNAccountController updateUserDetails:userDetails automaticallyHandleUserIDTaken:YES success:successBlock failure:failureBlock];
}

+ (void)updateUserDetails:(DNUserDetails *)userDetails automaticallyHandleUserIDTaken:(BOOL)autoHandleIDTaken success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock {
    
    if (![[userDetails userID] isEqualToString:[[[DNAccountController registrationDetails] userDetails] userID]] && [[DNDonkyCore sharedInstance] isUsingAuth]) {
        DNErrorLog(@"cannot change userID while in authenticated registration...");
        if (failureBlock) {
            failureBlock(nil, [DNErrorController errorCode:0000 additionalData:@{@"Reason" : @"Cannot change userID while in authenticated registration..."}]);
        }
        return;
    }
    
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES
                                                                  route:kDNNetworkRegistrationDeviceUser
                                                             httpMethod:DNPut
                                                             parameters:[userDetails parameters]
                                                                success:^(NSURLSessionDataTask *task, id responseData) {
        @try {

            [DNDonkyNetworkDetails saveAccessToken:nil];

            [DNAccountController saveUserDetails:userDetails];

            if (successBlock) {
                successBlock(task, responseData);
            }

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedUser
                                                                     publisher:NSStringFromClass([DNAccountController class])
                                                                     timeStamp:[NSDate date]
                                                                          data:userDetails];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];
        }

        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            if(failureBlock) {
                failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([DNErrorController serviceReturnedFailureKey:@"UserIdAlreadyTaken" error:error] && autoHandleIDTaken) {
            DNDebugLog(@"User ID already taken... automatically recovering...");
            [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task1, id responseData1) {
                [DNAccountController replaceRegistrationDetailsWithUserDetails:userDetails deviceDetails:[[DNAccountController registrationDetails] deviceDetails] success:^(NSURLSessionDataTask *task2, id responseData) {
                    @try {

                        [DNAccountController saveUserDetails:userDetails];

                        if (successBlock) {
                            successBlock(task, responseData);
                        }

                        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedUser
                                                                                 publisher:NSStringFromClass([DNAccountController class])
                                                                                 timeStamp:[NSDate date]
                                                                                      data:userDetails];
                        [[DNDonkyCore sharedInstance] publishEvent:localEvent];
                    }
                    @catch (NSException *exception) {
                        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                        if (failureBlock) {
                            failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
                        }
                    }
                } failure:failureBlock];
            } failure:failureBlock];
        }
        else if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

+ (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES
                                                                  route:kDNNetworkRegistrationDevice
                                                             httpMethod:DNPut
                                                             parameters:[deviceDetails parameters]
                                                                success:^(NSURLSessionDataTask *task, id responseData) {
        @try {
            [DNDeviceDetailsHelper saveAdditionalProperties:[deviceDetails additionalProperties]];
            [DNDeviceDetailsHelper saveDeviceName:[deviceDetails deviceName]];
            [DNDeviceDetailsHelper saveDeviceType:[deviceDetails type]];

            [DNDonkyNetworkDetails saveOperatingSystemVersion:[deviceDetails operatingSystem]];

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedDevice publisher:NSStringFromClass([DNAccountController class]) timeStamp:[NSDate date] data:deviceDetails];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];

            if (successBlock) {
                successBlock(task, responseData);
            }
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            if(failureBlock) {
                failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

+ (void)updateClient:(DNClientDetails *)clientDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    if (!clientDetails) {
        clientDetails = [[DNClientDetails alloc] init];
    }

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkRegistrationClient httpMethod:DNPut parameters:[clientDetails parameters] success:^(NSURLSessionDataTask *task, id responseData) {
        [DNDonkyNetworkDetails saveSDKVersion:[clientDetails sdkVersion]];
        if (successBlock) {
            successBlock(task, responseData);
        }

    } failure:failureBlock];
}

+ (void)replaceRegistrationDetailsWithUserDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    
    if ([[DNDonkyCore sharedInstance] isUsingAuth]) {
        [DNAccountController refreshAccessTokenSuccess:successBlock failure:failureBlock];
        return;
    }

    __block DNUserDetails *blockUserDetails = userDetails;
    __block DNDeviceDetails *blockDeviceDetails = deviceDetails;

    //Do a sync
    [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
        //Clear user details:
        if (!blockDeviceDetails) {
            blockDeviceDetails = [[DNDeviceDetails alloc] initWithDeviceType:nil name:nil additionalProperties:nil];
        }
        if (!blockUserDetails) {
            blockUserDetails = [DNAccountController userID:nil displayName:nil emailAddress:nil mobileNumber:nil countryCode:nil firstName:nil lastName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
        }

        [DNAccountController registerDeviceUser:blockUserDetails deviceDetails:blockDeviceDetails isUpdate:NO success:successBlock failure:failureBlock];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([error code] == DNCoreSDKErrorDuplicateSynchronise) {
            DNInfoLog(@"replace registration is retrying ...");
            [DNAccountController replaceRegistrationDetailsWithUserDetails:userDetails deviceDetails:deviceDetails success:successBlock failure:failureBlock];
        }
        else if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

+ (DNRegistrationDetails *)registrationDetails {
    DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
    DNUserDetails *userDetails = [DNAccountController currentDeviceUser];
    DNDeviceDetails *deviceDetails = [[DNDeviceDetails alloc] init];
    return [[DNRegistrationDetails alloc] initWithDeviceDetails:deviceDetails clientDetails:clientDetails userDetails:userDetails];
}

+ (DNUserDetails *)userID:(NSString *)userID
              displayName:(NSString *)displayName
             emailAddress:(NSString *)email
             mobileNumber:(NSString *)mobileNumber
              countryCode:(NSString *)countryCode
                firstName:(NSString *)firstName
                 lastName:(NSString *)lastName
                 avatarID:(NSString *)avatarID
             selectedTags:(NSMutableArray *)selectedTags
     additionalProperties:(NSDictionary *)additionalProperties {
    return [[DNUserDetails alloc] initWithUserID:userID
                                     displayName:displayName
                                    emailAddress:email
                                    mobileNumber:mobileNumber
                                     countryCode:countryCode
                                       firstName:firstName
                                        lastName:lastName
                                        avatarID:avatarID
                                    selectedTags:selectedTags
                            additionalProperties:additionalProperties
                                       anonymous:displayName == nil];
}

+ (BOOL)isRegistered {
    return [DNDonkyNetworkDetails isDeviceRegistered];
}

+ (BOOL)isSuspended {
    return [DNDonkyNetworkDetails isSuspended];
}

+ (void)setIsSuspended:(BOOL)suspended {
    [DNDonkyNetworkDetails saveIsSuspended:suspended];
}

+ (void)updateNetworkDetails {
    DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
    DNDeviceDetails *deviceDetails = [[DNDeviceDetails alloc] init];

    //The client details have changed, we therefore need to update the details on the network:
    if (![[clientDetails sdkVersion] isEqualToString:[DNDonkyNetworkDetails savedSDKVersion]]) {
        [DNAccountController updateClient:clientDetails success:nil failure:nil];
    }
    if (![[deviceDetails operatingSystem] isEqualToString:[DNDonkyNetworkDetails savedOperatingSystemVersion]]) {
        [DNAccountController updateDeviceDetails:deviceDetails success:nil failure:nil];
    }
}

+ (void)updateClientModules:(NSArray *)modules {

    @try {
        //Get current modules:
        DNClientDetails *clientDetails = [[DNClientDetails alloc] init];

        __block NSMutableDictionary *currentModules = [clientDetails moduleVersions];
        __block BOOL hasChanges = NO;

        [modules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[DNModuleDefinition class]]) {
                DNErrorLog(@"Something has gone wrong with. Expected DNModuleDefinition (or subclass thereof) got: %@ ... Bailing out", NSStringFromClass([obj class]));
                *stop = YES;
            }

            DNModuleDefinition *moduleDefinition = obj;
            NSString *version = currentModules[[moduleDefinition name]];
            //The version number is either different, or the module hasn't been registered yet (if version is nil). Either way, we need to save
            if (![version isEqualToString:[moduleDefinition version]]) {
                [currentModules dnSetObject:[moduleDefinition version] forKey:[moduleDefinition name]];
                hasChanges = YES;
            }
        }];

        [clientDetails saveModuleVersions:currentModules];

        if (hasChanges && [DNAccountController isRegistered]) {
            [DNAccountController updateClient:clientDetails success:nil failure:nil];
        }
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
    }
}

+ (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    if (!successBlock || !failureBlock) {
        DNErrorLog(@"All network calls are performed asynchronously, you have not set a success and/or failure block. Making another call to thsi API before the previous one has finished leave the data in an unpredictable state");
    }

    DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];
    [currentUser saveUserTags:tags];

    if ([tags count]) {
        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkUserTags httpMethod:DNPut parameters:[currentUser tagsForNetwork] success:^(NSURLSessionDataTask *task, id responseData) {
            [DNAccountController saveUserDetails:currentUser];
            if (successBlock) {
                successBlock(task, responseData);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failureBlock) {
                failureBlock(task, error);
            }
        }];
    }
    else
        DNInfoLog(@"No tags to save.");
}

+ (void)usersTags:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    if (!successBlock || !failureBlock) {
        DNErrorLog(@"All network calls are performed asynchronously, you have not set a success and/or failure block. Making another call to thsi API before the previous one has finished leave the data in an unpredictable state");
    }

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkUserTags httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];
        if ([responseData isKindOfClass:[NSArray class]]) {
            //Lets process these tags:
            @try {
                NSMutableArray *convertedTags = [[NSMutableArray alloc] init];
                [responseData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DNTag *tag = [[DNTag alloc] initWithValue:obj[@"value"] isSelected:[obj[@"isSelected"] boolValue]];
                    [convertedTags addObject:tag];
                }];

                [currentUser saveUserTags:convertedTags];
                [DNAccountController saveUserDetails:currentUser];

                if (successBlock) {
                    successBlock(task, convertedTags);
                }
            }
            @catch (NSException *exception) {
                DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            }
        }
        else {
            DNErrorLog(@"Whoops, something's gone wrong, the tags retrieved from the user are not in an array: %@ - %@", responseData, [responseData class]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

#pragma mark -
#pragma mark - Database Helpers

+ (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock) successBlock failure:(DNNetworkFailureBlock) failureBlock {

    if (!successBlock || !failureBlock) {
        DNErrorLog(@"All network calls are performed asynchronously, you have not set a success and/or failure block. Making another call to thsi API before the previous one has finished may leave the data in an unpredictable state");
    }

    //Update:
    NSMutableDictionary *originalUserProperties = [[[[DNAccountController registrationDetails] userDetails] additionalProperties] mutableCopy];
    [originalUserProperties setValuesForKeysWithDictionary:newAdditionalProperties];

    //Get the current user:
    DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];

    DNUserDetails *updatedUser = [DNAccountController userID:[currentUser userID]
                                                 displayName:[currentUser displayName]
                                                emailAddress:[currentUser emailAddress]
                                                mobileNumber:[currentUser mobileNumber]
                                                 countryCode:[currentUser countryCode]
                                                   firstName:[currentUser firstName]
                                                    lastName:[currentUser lastName]
                                                    avatarID:[currentUser avatarAssetID]
                                                selectedTags:[currentUser selectedTags]
                                        additionalProperties:originalUserProperties];

    [DNAccountController updateUserDetails:updatedUser automaticallyHandleUserIDTaken:NO success:successBlock failure:failureBlock];

}

+ (DNUserDetails *)currentDeviceUser {
    NSManagedObjectContext *context = [[DNDataController sharedInstance] mainContext];

    DNDeviceUser *deviceUser = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"]
                                                                withContext:context
                                                     includesPendingChanges:NO];
    if (!deviceUser) {
        deviceUser = [self newDevice];
    }
    
    DNUserDetails *dnUserDetails = [[DNUserDetails alloc] initWithDeviceUser:deviceUser];
    return dnUserDetails;
}

+ (void)saveUserDetails:(DNUserDetails *)details {
    NSManagedObjectContext *context = nil;

    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }

    [context performBlockAndWait:^{
        DNDeviceUser *deviceUser = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"]
                                                                    withContext:context
                                                         includesPendingChanges:NO] ? : [self newDevice];
        if (deviceUser && (![deviceUser lastUpdated] || [[deviceUser lastUpdated] donkyHasDateExpired])) {
            [deviceUser setIsAnonymous:@([details isAnonymous])];
            [deviceUser setFirstName:[details firstName]];
            [deviceUser setLastName:[details lastName]];
            [deviceUser setDisplayName:[details displayName]];
            [deviceUser setMobileNumber:[details mobileNumber]];
            [deviceUser setEmailAddress:[details emailAddress]];
            [deviceUser setAvatarAssetID:[details avatarAssetID]];
            [deviceUser setCountryCode:[details countryCode]];
            [deviceUser setUserID:[details userID]];
            [deviceUser setSelectedTags:[details selectedTags]];
            [deviceUser setAdditionalProperties:[details additionalProperties]];
            [deviceUser setNetworkProfileID:[DNDonkyNetworkDetails networkProfileID]];

            [deviceUser setLastUpdated:[NSDate date]];
            [[DNDataController sharedInstance] saveContext:context];
        }
    }];
}

+ (DNDeviceUser *)newDevice {
    NSManagedObjectContext *context = nil;

    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }

    DNDeviceUser *device = nil;
    device = [DNDeviceUser insertNewInstanceWithContext:context];
    [device setIsDeviceUser:@(YES)];
    [device setIsAnonymous:@(YES)];
    [[DNDataController sharedInstance] saveContext:context];

    return device;
}


@end
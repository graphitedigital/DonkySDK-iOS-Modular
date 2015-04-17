//
//  DNAccountController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <MacTypes.h>
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
#import "NSManagedObject+DNHelper.h"
#import "DNTag.h"

static NSString *const DNUserParameters = @"user";
static NSString *const DNClientParameters = @"client";
static NSString *const DNDeviceParameters = @"device";
static NSString *const DNFailureKey = @"failureKey";
static NSString *const DNMissingNetworkID = @"MissingNetworkId";

@implementation DNAccountController

+ (void)initialiseUserDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    //We register if there is no user registered OR if the device user we are registering with is different from the current user.
    //DO NOT use this to update user device details. Re-Registering the same user could potentially delete the user from the network and re add them.
    if (![DNDonkyNetworkDetails isDeviceRegistered])
        [DNAccountController registerDeviceUser:userDetails deviceDetails:deviceDetails isUpdate:NO success:successBlock failure:failureBlock];
    else if ([DNDonkyNetworkDetails newUserDetails])
        [DNAccountController updateUserDetails:userDetails success:successBlock failure:failureBlock];
    else if (![DNDonkyNetworkDetails hasValidAccessToken])
        [DNAccountController refreshAccessTokenSuccess:successBlock failure:failureBlock];
    else if (successBlock)
        successBlock(nil, nil);
}

+ (void)registerDeviceUser:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails isUpdate:(BOOL)update success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
    NSMutableDictionary *registrationParameters = [[NSMutableDictionary alloc] init];
    [registrationParameters dnSetObject:[deviceDetails parameters] forKey:DNDeviceParameters];
    [registrationParameters dnSetObject:[clientDetails parameters] forKey:DNClientParameters];
    [registrationParameters dnSetObject:[userDetails parameters] forKey:DNUserParameters];

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:update route:kDNNetworkRegistration httpMethod:update ? DNPut : DNPost parameters:registrationParameters success:^(NSURLSessionDataTask *task, id responseData) {
        @try {
            NSString *apiKey = [DNDonkyNetworkDetails apiKey];
            [DNUserDefaultsHelper resetUserDefaults];
            DNAccountRegistrationResponse *accountRegistrationResponse = [[DNAccountRegistrationResponse alloc] initWithRegistrationResponse:responseData];
            [DNDonkyNetworkDetails saveAccessToken:[accountRegistrationResponse accessToken]];
            [DNDonkyNetworkDetails saveSecureServiceRootUrl:[accountRegistrationResponse rootURL]];
            [DNDonkyNetworkDetails saveDeviceID:[accountRegistrationResponse deviceId]];
            [DNDonkyNetworkDetails saveNetworkID:[accountRegistrationResponse networkId]];
            [DNDonkyNetworkDetails saveTokenExpiry:[accountRegistrationResponse tokenExpiry]];
            [DNDonkyNetworkDetails saveDeviceSecret:[deviceDetails deviceSecret]];
            [DNDonkyNetworkDetails saveAPIKey:apiKey];
            [DNDonkyNetworkDetails savePushEnabled:YES];

            //Store Configuration items:
            [DNConfigurationController saveConfiguration:[accountRegistrationResponse configuration]];

            //We have an anonymous reg
            if ([userDetails isAnonymous]) {
                DNUserDetails *anonymousDetails = [[DNUserDetails alloc] initWithUserID:[accountRegistrationResponse userId] displayName:[accountRegistrationResponse userId] emailAddress:nil mobileNumber:nil countryCode:nil lastName:nil firstName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
                [[DNDataController sharedInstance] saveUserDetails:anonymousDetails];
            }
            else
                [[DNDataController sharedInstance] saveUserDetails:userDetails];

            [DNDeviceDetailsHelper saveAdditionalProperties:[deviceDetails additionalProperties]];
            [DNDeviceDetailsHelper saveDeviceName:[deviceDetails deviceName]];
            [DNDeviceDetailsHelper saveDeviceType:[deviceDetails type]];

            DNLocalEvent *registrationEvent = [[DNLocalEvent alloc] initWithEventType:kDNEventRegistration
                                                                            publisher:NSStringFromClass([self class])
                                                                            timeStamp:[NSDate date]
                                                                                 data:nil];

            [[DNDonkyCore sharedInstance] publishEvent:registrationEvent];

            if (successBlock)
                successBlock(task, responseData);
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            if (failureBlock)
                failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock)
            failureBlock(task, error);
    }];
}

+ (void)refreshAccessTokenSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    //Has the token expired ?
    if (![DNDonkyNetworkDetails hasValidAccessToken]) {
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

                if ([DNDonkyNetworkDetails isSuspended]) {
                    //We were suspended so re-initialise:
                    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:[DNDonkyNetworkDetails apiKey]
                                                           userDetails:[[DNAccountController registrationDetails] userDetails]
                                                         deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                                                               success:^(NSURLSessionDataTask *task2, id responseData2) {
                        [DNDonkyNetworkDetails saveIsSuspended:NO];
                    } failure:failureBlock];
                }

                if (successBlock)
                    successBlock(task, responseData);
            }
            @catch (NSException *exception) {
                DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
                [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                if(failureBlock)
                    failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //Specific for this call:
            if (([DNErrorController serviceReturned:401 error:error] && [DNAccountController isRegistered]) || [[error userInfo][DNFailureKey] isEqualToString:DNMissingNetworkID]) {
                DNErrorLog(@"User is unauthroised for token refresh. User details may have been deleted on the network...\nRe-registering user...");
                [DNAccountController registerDeviceUser:[[DNAccountController registrationDetails] userDetails]
                                          deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                                               isUpdate:NO
                                                success:successBlock
                                                failure:failureBlock];
            }
            else if ([DNErrorController serviceReturned:403 error:error] && [DNAccountController isRegistered]) {
                //We are suspended:
                [DNDonkyNetworkDetails saveIsSuspended:YES];
                if (failureBlock)
                    failureBlock(task, [DNErrorController errorWithCode:DNCoreSDKSuspendedUser]);
            }
            else if (failureBlock)
                failureBlock(task, error);
        }];
    }
    else { //We have a valid token, so simply start a new timer.
        if (successBlock)
            successBlock(nil, nil);
    }
}

+ (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock {
    [DNAccountController registerDeviceUser:userDetails deviceDetails:deviceDetails isUpdate:YES success:^(NSURLSessionDataTask *task, id responseData) {
        DNLocalEvent *registrationChanged = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedDevice publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:userDetails];
        [[DNDonkyCore sharedInstance] publishEvent:registrationChanged];
        if (successBlock)
            successBlock(task, responseData);

    } failure:failureBlock];
}

+ (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES
                                                                  route:kDNNetworkRegistrationDeviceUser
                                                             httpMethod:DNPut
                                                             parameters:[userDetails parameters]
                                                                success:^(NSURLSessionDataTask *task, id responseData)
    {
        @try {
            [[DNDataController sharedInstance] saveUserDetails:userDetails];
            if (successBlock)
                successBlock(task, responseData);

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedUser
                                                                     publisher:NSStringFromClass([self class])
                                                                     timeStamp:[NSDate date]
                                                                          data:userDetails];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            if(failureBlock)
                failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock)
            failureBlock(task, error);
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

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedDevice publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:deviceDetails];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];

            if (successBlock)
                successBlock(task, responseData);
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            if(failureBlock)
                failureBlock(task, [DNErrorController errorCode:DNCoreSDKFatalException userInfo:@{@"Exception: " : [exception description]}]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock)
            failureBlock(task, error);
    }];
}

+ (void)updateClient:(DNClientDetails *)clientDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    if (!clientDetails)
        clientDetails = [[DNClientDetails alloc] init];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES
                                                                  route:kDNNetworkRegistrationClient
                                                             httpMethod:DNPut
                                                             parameters:[clientDetails parameters]
                                                                success:successBlock
                                                                failure:failureBlock];
}

+ (void)replaceRegistrationDetailsWithUserDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    __block DNUserDetails *blockDevice = userDetails;
    __block DNDeviceDetails *blockDetails = deviceDetails;

    //Do a sync
    [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
        //Clear user details:
        if (!blockDetails)
            blockDetails = [[DNDeviceDetails alloc] initWithDeviceType:nil name:nil additionalProperties:nil];
        if (!blockDevice)
            blockDevice = [DNAccountController userID:nil displayName:nil emailAddress:nil mobileNumber:nil countryCode:nil firstName:nil lastName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
        [DNAccountController registerDeviceUser:blockDevice deviceDetails:blockDetails isUpdate:NO success:successBlock failure:failureBlock];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([error code] == DNCoreSDKErrorDuplicateSynchronise) {
            DNInfoLog(@"retrying ...");
            [DNAccountController replaceRegistrationDetailsWithUserDetails:userDetails deviceDetails:deviceDetails success:successBlock failure:failureBlock];
        }
        else if (failureBlock)
            failureBlock(task, error);
    }];
}

+ (DNRegistrationDetails *)registrationDetails {
    DNClientDetails *clientDetails = [[DNClientDetails alloc] init];
    DNUserDetails *userDetails = [[DNDataController sharedInstance] currentDeviceUser];
    DNDeviceDetails *deviceDetails = [[DNDeviceDetails alloc] init];
    return [[DNRegistrationDetails alloc] initWithDeviceDetails:deviceDetails clientDetails:clientDetails userDetails:userDetails];
}

+ (DNUserDetails *)userID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)email mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSMutableArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties {
    return [[DNUserDetails alloc] initWithUserID:userID displayName:displayName emailAddress:email mobileNumber:mobileNumber countryCode:countryCode lastName:lastName firstName:firstName avatarID:avatarID selectedTags:selectedTags additionalProperties:additionalProperties];
}

+ (BOOL)isRegistered {
    return [DNDonkyNetworkDetails isDeviceRegistered];
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

        if (hasChanges && [DNAccountController isRegistered]) {
            [DNAccountController updateClient:clientDetails success:^(NSURLSessionDataTask *task, id responseData) {
                //Save the new details:
                [clientDetails saveModuleVersions:currentModules];
            }                         failure:nil];
        }
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
    }
}

+ (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];
    [currentUser saveUserTags:tags];

    if ([tags count]) {
        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkUserTags httpMethod:DNPut parameters:[currentUser tagsForNetwork] success:^(NSURLSessionDataTask *task, id responseData) {
            [[DNDataController sharedInstance] saveUserDetails:currentUser];
            if (successBlock)
                successBlock(task, responseData);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failureBlock)
                failureBlock(task, error);
        }];
    }
    else
        DNInfoLog(@"No tags to save.");
}

+ (void)usersTags:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
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
                [[DNDataController sharedInstance] saveUserDetails:currentUser];

                if (successBlock)
                    successBlock(task, convertedTags);
            }
            @catch (NSException *exception) {
                DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
                [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            }
        }
        else
            DNErrorLog(@"Whoops, something's gone wrong, the tags retrieved from the user are not in an array: %@ - %@", responseData, [responseData class]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock)
            failureBlock(task, error);
    }];
}

@end

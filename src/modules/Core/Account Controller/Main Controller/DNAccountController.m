//
//  DNAccountController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

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
    else if ([DNDonkyNetworkDetails newUserDetails]) {
        [DNAccountController updateUserDetails:userDetails success:^(NSURLSessionDataTask *task, id responseData) {
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
            [DNDonkyNetworkDetails saveNetworkProfileID:[accountRegistrationResponse networkProfileID]];
            [DNDonkyNetworkDetails saveDeviceSecret:[deviceDetails deviceSecret]];
            [DNDonkyNetworkDetails saveSDKVersion:[clientDetails sdkVersion]];
            [DNDonkyNetworkDetails saveOperatingSystemVersion:[deviceDetails operatingSystem]];
            [DNDonkyNetworkDetails saveAPIKey:apiKey];
            [DNDonkyNetworkDetails savePushEnabled:YES];

            //Store Configuration items:
            [DNConfigurationController saveConfiguration:[accountRegistrationResponse configuration]];

            //We have an anonymous reg
            if ([userDetails isAnonymous]) {
                DNUserDetails *anonymousDetails = [[DNUserDetails alloc] initWithUserID:[accountRegistrationResponse userId] displayName:[accountRegistrationResponse userId] emailAddress:nil mobileNumber:nil countryCode:nil firstName:nil lastName:nil avatarID:nil selectedTags:nil additionalProperties:nil anonymous:YES];
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
                    [DNDonkyNetworkDetails saveIsSuspended:NO];
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
        DNLocalEvent *registrationChanged = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedDevice publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:userDetails];
        [[DNDonkyCore sharedInstance] publishEvent:registrationChanged];
        if (successBlock) {
            successBlock(task, responseData);
        }
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
            
            [DNAccountController saveUserDetails:userDetails];
            
            if (successBlock) {
                successBlock(task, responseData);
            }

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedUser
                                                                     publisher:NSStringFromClass([self class])
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
        if ([DNErrorController serviceReturnedFailureKey:@"UserIdAlreadyTaken" error:error]) {
            [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task1, id responseData1) {
                [DNAccountController replaceRegistrationDetailsWithUserDetails:userDetails deviceDetails:[[DNAccountController registrationDetails] deviceDetails] success:^(NSURLSessionDataTask *task2, id responseData) {
                    @try {

                        [DNAccountController saveUserDetails:userDetails];

                        if (successBlock) {
                            successBlock(task, responseData);
                        }

                        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedUser
                                                                                 publisher:NSStringFromClass([self class])
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
            } failure:nil];
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

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventRegistrationChangedDevice publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:deviceDetails];
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
            DNInfoLog(@"Retrying ...");
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

+ (DNUserDetails *)userID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)email mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSMutableArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties {
    return [[DNUserDetails alloc] initWithUserID:userID displayName:displayName emailAddress:email mobileNumber:mobileNumber countryCode:countryCode firstName:firstName lastName:lastName avatarID:avatarID selectedTags:selectedTags additionalProperties:additionalProperties anonymous:displayName == nil];
}

+ (BOOL)isRegistered {
    return [DNDonkyNetworkDetails isDeviceRegistered];
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

    [DNAccountController updateUserDetails:updatedUser success:successBlock failure:failureBlock];

}

+ (DNUserDetails *)currentDeviceUser {

    DNDeviceUser *deviceUser = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"] withContext:[[DNDataController sharedInstance] mainContext]] ? : [self newDevice];

    DNUserDetails *dnUserDetails = [[DNUserDetails alloc] initWithDeviceUser:deviceUser];

    return dnUserDetails;
}

+ (void)saveUserDetails:(DNUserDetails *)details {
    DNDeviceUser *deviceUser = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"] withContext:[[DNDataController sharedInstance] mainContext]] ? : [self newDevice];
    [deviceUser setIsAnonymous:@([details isAnonymous])];
    [deviceUser setDisplayName:[details displayName]];
    [deviceUser setMobileNumber:[details mobileNumber]];
    [deviceUser setEmailAddress:[details emailAddress]];
    [deviceUser setAvatarAssetID:[details avatarAssetID]];
    [deviceUser setCountryCode:[details countryCode]];
    [deviceUser setUserID:[details userID]];
    [deviceUser setSelectedTags:[details selectedTags]];
    [deviceUser setAdditionalProperties:[details additionalProperties]];
    [[DNDataController sharedInstance] saveAllData];
}

+ (DNDeviceUser *)newDevice {
    DNDeviceUser *device = [DNDeviceUser insertNewInstanceWithContext:[[DNDataController sharedInstance] mainContext]];
    [device setIsDeviceUser:@(YES)];
    [device setIsAnonymous:@(YES)];
    return device;
}


@end

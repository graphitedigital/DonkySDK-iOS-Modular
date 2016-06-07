//
//  DNConstants.m
//  Logging
//
//  Created by Donky Networks on 13/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNConstants.h"

#pragma mark -
#pragma mark - Network API

NSString * const kDNNetworkHostURL = @"https://client-api.mobiledonky.com/";

NSString * const kDNNetworkRegistration = @"api/registration";

NSString * const kDNNetworkAuthenticationStart = @"api/authentication/start";

NSString * const kDNNetworkAuthenticationRegistration = @"api/authenticatedregistration";

NSString * const kDNNetworkAuthenticationAuthenticate = @"api/authentication/reauthenticate";

NSString * const kDNNetworkRegistrationDeviceUser = @"api/registration/user";

NSString * const kDNNetworkRegistrationPush = @"api/registration/push";

NSString * const kDNNetworkRegistrationDevice = @"api/registration/device";

NSString * const kDNNetworkRegistrationClient = @"api/registration/client";

NSString * const kDNNetworkAuthentication = @"api/authentication/gettoken";

NSString * const kDNNetworkNotificationSynchronise = @"api/notification/synchronise";

NSString * const kDNNetworkGetNotification = @"api/notification/";

NSString * const kDNNetworkSendDebugLog = @"api/debugLog";

NSString * const kDNNetworkUserTags = @"api/registration/user/tags";

NSString * const kDNNetworkIsValidPlatformUser = @"api/contact/";

NSString * const kDNNetworkSearchUsers = @"api/contact/search";

NSString * const kDNNetworkGetActiveRegions = @"api/locationservices/geofence/active";

NSString * const kDNNetworkGetActiveTriggers = @"api/trigger/clientconfiguration";

NSString * const kDNNetworkUploadAsset = @"api/asset";

NSString * const kDNNetworkConversationHistory = @"api/messagehistory/conversation";

#pragma mark -
#pragma mark - Donky Notification Types

//
NSString * const kDNDonkyNotificationTransmitDebugLog = @"TransmitDebugLog";

//
NSString * const kDNDonkyNotificationSimplePush = @"SimplePushMessage";

//
NSString * const kDNDonkyNotificationSyncMessageRead = @"SyncMessageRead";

//
NSString * const kDNDonkyNotificationSyncMessageDeleted = @"SyncMessageDeleted";

//
NSString * const kDNDonkyNotificationRichMessage = @"RichMessage";

//
NSString * const kDNDonkyNotificationNewDeviceMessage = @"NewDeviceAddedToUser";

//
NSString * const kDNDonkyNotificationLocationRequest = @"LocationRequest";

//
NSString * const kDNDonkyNotificationLocationReceived = @"UserLocation";

#pragma mark -
#pragma mark - Donky Event Types

//
NSString * const kDNDonkyEventRegistrationChangedUser = @"DonkyRegistrationEventUserChanged";

//
NSString * const kDNDonkyEventRegistrationChangedDevice = @"DonkyRegistrationEventDeviceChanged";

//
NSString * const kDNDonkyEventNetworkStateChanged = @"DonkyNetworkStateEvent";

//
NSString * const kDNEventRegistration = @"DonkyRegistrationEvent";

//
NSString * const kDNDonkyEventAppOpen = @"DonkyAppOpen";

//
NSString * const kDNDonkyEventAppClose = @"DonkyAppClose";

//
NSString * const kDNDonkyEventNotificationLoaded = @"DonkyNotificationLoadedEvent";

//
NSString * const kDNDonkySetBadgeCount = @"DonkySetBadgeCountEevnt";

//
NSString * const kDNDonkyEventTokenRefreshed = @"DonkyEventTokenRefresh";

//
NSString * const kDNDonkyEventLocationReceived = @"DonkyEventLocationReceived";

//
NSString * const kDNDonkyEventLocationRequestReceived = @"DonkyEventLocationRequestReceived";

#pragma mark -
#pragma mark - Donky Config Items

//
NSString * const kDNConfigPlistFileName = @"DNConfiguration";

//
NSString * const kDNConfigSDKVersion = @"SDK Version";

//
NSString * const kDNConfigLoggingOptions = @"Logging Options";

//
NSString * const kDNConfigLoggingEnabled = @"Logging Enabled";

//
NSString * const kDNConfigOutputWarningLogs = @"Output Warning Logs";

//
NSString * const kDNConfigOutputErrorLogs = @"Output Error Logs";

//
NSString * const kDNConfigOutputInfoLogs = @"Output Info Logs";

//
NSString * const kDNConfigOutputDebugLogs = @"Output Debug Logs";

//
NSString * const kDNConfigOutputSensitiveLogs = @"Output Sensitive Logs";

//
NSString * const kDNConfigDisplayNoInternetAlert = @"Display No Internet Alert";

//
NSString * const kDNDebugLogSubmissionInterval = @"Debug Log Submission Interval";

#pragma mark -
#pragma mark - Debug Logging Constants

//
NSString * const kDNLoggingFileName = @"DNDebugLog.log";

//
NSString * const kDNLoggingDirectoryName = @"DonkyDebugLogs";

//
NSString * const kDNLoggingArchiveFileName = @"DNDebugArchivedLog.log";

//
NSString * const kDNLoggingArchiveDirectoryName = @"DonkyDebugLogs/ArchivedLogs";

//
NSString * const kDNLoggingDateFormat = @"dd-MM-yyyy 'at' HH:mm:ss";

#pragma mark -
#pragma mark - Keychain & Security

//
NSString * const kDNKeychainDeviceSecret = @"DonkyDeviceSecret";

//
NSString * const kDNKeychainDevicePassword = @"DonkyDeviceUserPassword";

//
NSString * const kDNKeychainAccessToken = @"DonkyDeviceUserToken";

#pragma mark -
#pragma mark - Misc

//
NSString * const kDNMiscOperatingSystem = @"iOS";

//
NSString * const kDonkyErrorDomain = @"com.dynmark.donkyNetworkSDK";

//
CGFloat  const kDonkyLogFileSizeLimit = 2000000.0f; //this is in bytes, default is 2mb

//
NSString * const kDNTempDirectory = @"DonkyTempDirectory";

//
NSInteger const kDonkyMaxNumberOfSavedChatMessages = 2000;

#pragma mark -
#pragma mark - Donky Notification Keys

NSString * const kDNDonkyNotificationCustomDataKey = @"CustomData";

#pragma mark -
#pragma mark - Donky Module Versions

//
NSString * const kDNDonkyCoreVersion = @"1.1.0.1";

//
NSString * const kDNDonkyNetworkVersion = @"1.1.2.3";

//
NSString * const kDNDonkyNotificationVersion = @"1.1.0.1";


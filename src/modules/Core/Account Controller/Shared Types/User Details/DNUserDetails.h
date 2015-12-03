//
//  DNUserDetails.h
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNDeviceUser.h"

/*!
 Class to create a new devie user details. When requested the device use from the Registration Details in DNAccountController, it will be returned as this object.
 
 @since 2.0.0.0
 */
@interface DNUserDetails : NSObject

/*!
 The user ID of the device user. This is used to identify the user on the network.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *userID;

/*!
 Thet network profile ID of the user, this is an immutable value on both client and 
 network. As such it can be relied upon to always reach the correct user, where the userIDs
 can be changed (depending on integrator decisions) and therefor can be out of sync.
 
 @since 2.6.6.5
 */
@property (nonatomic, readonly) NSString *networkProfileID;

/*!
 Bool to determine if this device was registered using the Anonymous user registration.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly, getter=isAnonymous) BOOL anonymous;

/*!
 The display name of the user.

 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString *displayName;

/*!
 The email address of the user.
 
 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString *emailAddress;

/*!
 The mobile number of the user. NOTE: ISO country code is required if setting mobile number.

 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString *mobileNumber;

/*!
 The country code of the user. NOTE: This is required IF setting the mobile number. Failure to provide an ISO country code will result in server validation failures.
 
 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString * countryCode;

/*!
 Avatar ID of the current user.
 
 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString *avatarAssetID;

/*!
 The users selected tags, this can be used for segmentation when deploying campaigns.
 
 @since 2.0.0.0
 */
@property (nonatomic, copy) NSMutableArray *selectedTags;

/*!
 Any additional properties to store against the user on the network. Maximum of 50 key/value pairs.
 
 @since 2.0.0.0
 */
@property (nonatomic, copy) NSDictionary *additionalProperties;

/*!
 First name of the user.

 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString *firstName;

/*!
 Last name of the user.

 @since 2.0.0.0
 */
@property (nonatomic, copy) NSString *lastName;

/*!
 Basic initialiser method
 
 @return returned a new instance of the DNUserDetails
 
 @since 2.4.3.1
 */
- (instancetype)init;

/*!
 Initialise method to create and set the properties of a new device user.
 
 @param userID               the user ID to use for this user.
 @param displayName          the users display name
 @param emailAddress         the users email address. Must be a valid email address, if not any updates to the network will result in validation failures.
 @param countryCode          the ISO country code of the user, only required if setting the mobile phone number.
 @param mobileNumber         the mobile number of the user.
 @param firstName            the first name of the user.
 @param lastName             the last name of the user.
 @param avatarAssetID        the avatar ID of the user.
 @param additionalProperties any additional key/value properties to store against this user.
 
 @return returns a new instance of the DNUserDetails class with the provided details.
 
 @since 2.0.0.0
 */
- (instancetype)initWithUserID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)emailAddress mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (instancetype)initWithUserID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)emailAddress mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSMutableArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties anonymous:(BOOL)isAnonymous;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (NSMutableDictionary *)parameters;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (instancetype)initWithDeviceUser:(DNDeviceUser *) deviceUser;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour

 @warning Private, please do not use
 */
- (NSMutableArray *)tagsForNetwork;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)saveUserTags:(NSMutableArray *) tags;

@end

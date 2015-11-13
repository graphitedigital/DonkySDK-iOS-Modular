//
//  DNUser.h
//  DonkyCore
//
//  Created by Donky Networks on 08/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DNUser : NSManagedObject

@property (nonatomic, retain) id additionalProperties;
@property (nonatomic, retain) NSString * avatarAssetID;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * mobileNumber;
@property (nonatomic, retain) id selectedTags;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * networkProfileID;

@end

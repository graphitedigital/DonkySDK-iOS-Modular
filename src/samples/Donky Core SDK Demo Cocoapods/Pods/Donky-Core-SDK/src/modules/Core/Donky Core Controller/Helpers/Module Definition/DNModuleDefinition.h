//
//  DNModuleDefinition.h
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The class to create Module Definition objects. This is used to link the DNSubscription objects and also to register the availability of Modules within the SDK. These details are also automatically sent to the Network to aid with debugging and analytics.
 */
@interface DNModuleDefinition : NSObject

/*!
 The name of the module.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *name;

/*!
 The module version number.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *version;

/*!
 Initialiser to create a new DNModule object.
 
 @param name    the name to assign to the module.
 @param version the version to assign to the module.
 
 @return a new instance of DNModuleDefinition
 
 @since 2.0.0.0
 */
- (instancetype)initWithName:(NSString *)name version:(NSString *)version;

@end

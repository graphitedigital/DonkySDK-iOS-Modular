//
//  DNDeviceDetails.h
//  Core Container
//
//  Created by Chris Watson on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Object to store all of the device details. Create a new DNDeviceDetails object with the provided options and then use this to update the details on the network.
 
 @since 2.0.0.0
 */
@interface DNDeviceDetails : NSObject

/*!
 The additional properties of this device, maximum of 50 key/value pairs.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSDictionary *additionalProperties;

/*!
 The name of the current device.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSString *deviceName;

/*!
 The type of device.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSString *type;

/*!
 The device secret for the network.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) NSString *deviceSecret;

/*!
 The operating system of the current device.
 
 @since 2.4.3.1
 */
@property(nonatomic, readonly) NSString *operatingSystem;

/*!
 Initialiser method to create a new DNDeviceDetails object with the provided user configurable properties.
 
 @param type                 the type of device.
 @param deviceName           the name of the device.
 @param additionalProperties any additional properties to store against the device on the network.
 
 @return a new DNDeviceDetails object.
 
 @since 2.0.0.0
 */
- (instancetype)initWithDeviceType:(NSString *)type name:(NSString *)deviceName additionalProperties:(NSDictionary *)additionalProperties;

#pragma mark -

#pragma mark - Private... Not for public consumption. Public use of these APIs is unsupported.

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
- (NSMutableDictionary *)parameters;

@end

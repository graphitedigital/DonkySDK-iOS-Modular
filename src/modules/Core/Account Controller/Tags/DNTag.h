//
//  DNTag.h
//  DonkyCore
//
//  Created by Chris Watson on 12/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNTag : NSObject

/*!
 Initialiser method to create a new tag object.
 
 @param value    the value of the tag.
 @param selected if the tag is selected or not.
 
 @return a new instance of DNTag.
 
 @since 2.0.0.0
 */
- (instancetype)initWithValue:(NSString *)value isSelected:(BOOL)selected;

/*!
 The value of the tag.
 
 @since 2.0.0.0
 */
@property (nonatomic, readonly) NSString *value;

/*!
 Whether the tag has been selected by the user.
 
 @since 2.0.0.0
 */
@property (nonatomic, getter=isSelected) BOOL selected;

@end

//
//  NSDictionary+DKDictionary.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 19/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Category to guard against exceptions when inserting objects from the network that may be nil.
 
 @since 2.0.0.0
 */
@interface NSMutableDictionary (DNDictionary)

/*!
 Category to protect against exceptions raised from inserting a nil object into a Dictionary.
 
 @param object to be set in the dictionary.
 @param key    the key for the object.
 
 @since 2.0.0.0
 */
- (void)dnSetObject:(id)object forKey:(id <NSCopying>)key;

/*!
 Helper method to remove all nil values from a dictionary, this is used for response data from the server.
 
 @since 2.0.0.0
 */
- (NSMutableDictionary *)donkyRemoveNullValues;

@end

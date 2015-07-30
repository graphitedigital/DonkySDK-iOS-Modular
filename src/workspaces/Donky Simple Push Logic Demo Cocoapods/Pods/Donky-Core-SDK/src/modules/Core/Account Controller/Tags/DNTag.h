//
//  DNTag.h
//  DonkyCore
//
//  Created by Chris Watson on 12/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNTag : NSObject

- (instancetype)initWithValue:(NSString *)value isSelected:(BOOL)selected;

@property (nonatomic, readonly) NSString *value;

@property (nonatomic, getter=isSelected) BOOL selected;

@end

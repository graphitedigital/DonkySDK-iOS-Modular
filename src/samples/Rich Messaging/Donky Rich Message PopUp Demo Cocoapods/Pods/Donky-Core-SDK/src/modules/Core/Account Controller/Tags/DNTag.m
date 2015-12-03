//
//  DNTag.m
//  DonkyCore
//
//  Created by Chris Watson on 12/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNTag.h"

@interface DNTag ()
@property(nonatomic, readwrite) NSString *value;
@end

@implementation DNTag

- (instancetype)initWithValue:(NSString *)value isSelected:(BOOL)selected {

    self = [super init];

    if (self) {

        [self setValue:value];
        [self setSelected:selected];

    }

    return self;
}


@end

//
//  DNTag.m
//  DonkyCore
//
//  Created by Donky Networks on 12/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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

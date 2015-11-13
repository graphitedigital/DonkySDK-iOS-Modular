//
//  UIResponder+FirstResponder.m
//  Donky Demo
//
//  Created by Donky Networks on 19/08/2014.
//  Copyright (c) 2014 Dynmark. All rights reserved.
//

#import "DNResponder+FirstResponder.h"

static __weak id currentFirstResponder;

@implementation UIResponder (FirstResponder)

+(id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

-(void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

+ (void)closeResponder {
    id currentResponder = [UIResponder currentFirstResponder];
    if ([currentResponder respondsToSelector:@selector(resignFirstResponder)]) {
        [currentResponder resignFirstResponder];
    }
}

@end

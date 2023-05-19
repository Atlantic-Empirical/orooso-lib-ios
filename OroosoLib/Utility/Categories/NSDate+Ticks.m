//
//  NSDate+Ticks.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 11/3/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "NSDate+Ticks.h"

@implementation NSDate (Ticks)

- (long long)toTicks{
	return [self timeIntervalSince1970] * 1000;
}

@end

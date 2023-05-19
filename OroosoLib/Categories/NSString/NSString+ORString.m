//
//  NSString+ORString.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/1/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "NSString+ORString.h"

@implementation NSString (ORString)

- (BOOL)containsString:(NSString*)substring
{
    NSRange range = [self rangeOfString:substring];
    return ( range.location != NSNotFound );
}

@end

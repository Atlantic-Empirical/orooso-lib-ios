//
//  FacebookPostGenerator.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/1/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "FacebookPostGenerator.h"

@implementation FacebookPostGenerator

+ (NSString*) generatePost:(TDWork*)aWork{
    // Watching <title>.
    NSString *out = [NSString stringWithFormat:@"Watching %@ with @Orooso", aWork.title];
    return out;
}

@end

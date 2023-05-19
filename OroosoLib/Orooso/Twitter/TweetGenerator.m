//
//  TweetGenerator.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/1/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "TweetGenerator.h"

@implementation TweetGenerator

- (TweetGenerator*) init{
    self = [super init];
    return self;
}

+ (NSString*) generateTweet:(OREntity *)aTitle{
    // Watching <title>.
    NSString *out = [NSString stringWithFormat:@"Watching %@ with @Orooso", aTitle.name];
    return out;
}

@end

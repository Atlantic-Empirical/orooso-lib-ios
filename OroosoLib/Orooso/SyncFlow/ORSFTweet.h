//
//  ORSFTweet.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/12/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@class ORTweet;

@interface ORSFTweet : ORSFItem

@property (nonatomic, strong) ORTweet *tweet;
@property (nonatomic, copy) NSString *fullContent;
@property (nonatomic, assign) BOOL fromStreaming;

- (id)initWithTweet:(ORTweet *)tweet andEntity:(OREntity *)entity;

@end

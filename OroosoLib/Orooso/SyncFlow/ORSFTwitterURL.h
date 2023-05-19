//
//  ORSFTweetURL.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 03/05/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@class ORTweet;

@interface ORSFTwitterURL : ORSFItem

@property (nonatomic, strong) ORTweet *tweet;
@property (nonatomic, strong) NSMutableOrderedSet *tweets;
@property (nonatomic, strong) NSDate *lastActivity;
@property (nonatomic, assign) BOOL firstOldItem;

- (id)initWithTweet:(ORTweet *)tweet andEntity:(OREntity *)entity;
- (id)initEmptyWithId:(NSString *)itemID;
- (void)addTweet:(ORTweet *)tweet;

@end

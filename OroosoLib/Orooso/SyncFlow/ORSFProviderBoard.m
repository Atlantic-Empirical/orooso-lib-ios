//
//  ORSFProviderBoard.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/07/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderBoard.h"
#import "ORApiEngine.h"

@interface ORSFProviderBoard()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderBoard

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.page = 0;
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    self.page = 0;
}

- (void)stop
{
    [super stop];
    
    if (self.op) {
        [self.op cancel];
        self.op = nil;
    }
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (self.page > 0) {
        if (completion) completion(nil, 0);
        return;
    }
    
    ORApiEngine *engine = [ORApiEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    BOOL defaultBoard = NO;
    
    if ([self.entity.entityId isEqualToString:engine.currentClientID] || [self.entity.entityId isEqualToString:engine.currentUserID]) {
        defaultBoard = YES;
    }
    
    ORArrayCompletion resultsBlock = ^(NSError *error, NSArray *result) {
        dispatch_async(queue, ^{
            self.op = nil;
            
            if (error) {
                if (completion) completion(error, 0);
                return;
            }
            
            // Create the item set, if needed
            if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
            
            NSUInteger added = 0;
            self.page++;
            
            for (ORBoardItem *i in result) {
                ORSFItem *item = i.item;
                item.parentEntity = self.entity;
                item.scoreBlendedNormalized = ([i.created timeIntervalSince1970] * -1);
                
                // Only add item if it's not already in the set
                if (![self.items containsObject:item]) {
					item.taken = NO;
                    [self.items addObject:item];
                    self.itemsAvailable++;
                    added++;
                }
            }
            
            // New items? Sort the item set
            if (added > 0) {
				[self sortItems];
			}
            
            // Return to caller
            if (completion) completion(nil, added);
        });
    };
    
    if ([self.entity.entityId isEqualToString:@"activity_feed"]) {
        NSLog(@"Fetching Activity Feed...");
        self.op = [engine activityFeedWithCompletion:resultsBlock];
    } else {
        NSLog(@"Fetching Board Items...");
        self.op = [engine getBoardItems:self.entity.entityId cb:resultsBlock];
    }
}

@end

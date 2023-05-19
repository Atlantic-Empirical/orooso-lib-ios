//
//  ORSFProviderTVNZ.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 13/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderTVNZ.h"
#import "ORApiEngine.h"
#import "ORTVNZArticle.h"

#define ITEM_COUNT 25

@interface ORSFProviderTVNZ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderTVNZ

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
    NSLog(@"Fetching TVNZ Videos...");
    
    ORApiEngine *engine = [ORApiEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    self.op = [engine tvnzVideos:self.page count:ITEM_COUNT cb:^(NSError *error, NSArray *result) {
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
            
            for (ORTVNZArticle *video in result) {
                
                ORSFVideo *item = [[ORSFVideo alloc] initWithTVNZArticle:video andEntity:self.entity];
                
                // Only add item if it's not already in the set
                if (![self.items containsObject:item]) {
					item.taken = NO;
					[item setRawScores];
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
    }];
}

@end

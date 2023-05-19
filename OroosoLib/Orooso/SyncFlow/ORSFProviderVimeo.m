//
//  ORSFProviderVimeo.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderVimeo.h"
#import "ORVimeoEngine.h"
#import "ORVimeoVideo.h"
#import "ORSFVideo.h"
#import "OREntity.h"

#define ITEM_COUNT 25
#define SCORE_CUTOFF -1.0f

@interface ORSFProviderVimeo ()

@property (atomic, strong) NSArray *queries;
@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, strong) NSMutableDictionary *operations;
@property (atomic, copy) ORSFProviderIntBlock fetchCompletion;
@property (atomic, strong) NSError *lastError;
@property (atomic, assign) NSUInteger itemsAdded;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderVimeo

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.queries = nil;
        self.page = 0;
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    
    self.queries = [self searchQueries];
    self.page = 0;
}

- (NSArray *)searchQueries
{
    NSMutableArray *queries = [NSMutableArray arrayWithCapacity:1];
    [queries addObject:self.entity.name];
    
    return queries;
}

- (void)handleNewItems:(NSArray *)items error:(NSError *)error query:(NSString *)query
{
    [self.operations removeObjectForKey:query];
    
    if (error) {
        self.lastError = error;
    } else {
        // Create the item set, if needed
        if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:items.count];
        
        NSUInteger added = 0;
        
        for (ORVimeoVideo *v in items) {
            ORSFVideo *item = [[ORSFVideo alloc] initWithVimeoVideo:v andEntity:self.entity];
            
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
            [self normalizeSubscores];
            [self normalizeBlendedScoresToFinalScore:SCORE_CUTOFF];
            [self sortItems];
            self.itemsAdded += added;
        }
    }
    
    if (!self.operations || [self.operations count] == 0) {
        if (self.fetchCompletion) {
            self.fetchCompletion(self.lastError, self.itemsAdded);
            self.fetchCompletion = nil;
            self.page++;
        }
        
        self.operations = nil;
        self.lastError = nil;
    }
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    ORVimeoEngine *engine = [ORVimeoEngine sharedInstance];
    
    if (!self.entity || !engine.isAuthenticated || !self.queries) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching Vimeo items...");
    
    dispatch_queue_t queue = dispatch_get_current_queue();
    engine.delegate = nil;
    
    self.fetchCompletion = completion;
    self.operations = [NSMutableDictionary dictionaryWithCapacity:[self.queries count]];
    self.lastError = nil;
    self.itemsAdded = 0;
    
    for (NSString *query in self.queries) {
        MKNetworkOperation *op = [engine fetchVideosForString:query page:self.page count:ITEM_COUNT cb:^(NSError *error, NSArray *items) {
            dispatch_async(queue, ^{
                [self handleNewItems:items error:error query:query];
            });
        }];
        
        [self.operations setObject:op forKey:query];
    }
}

@end

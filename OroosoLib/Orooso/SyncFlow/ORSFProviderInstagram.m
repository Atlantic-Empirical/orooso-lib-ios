//
//  ORSFProviderInstagram.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderInstagram.h"
#import "ORInstagramEngine.h"
#import "ORSFInstagramImage.h"
#import "ORInstagramImage.h"
#import "ORInstagramUser.h"
#import "OREntity.h"

#define SCORE_CUTOFF -1.0f

@interface ORSFProviderInstagram ()

@property (atomic, strong) NSArray *queries;
@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, strong) NSMutableDictionary *operations;
@property (atomic, strong) NSMutableDictionary *lastIDs;
@property (atomic, copy) ORSFProviderIntBlock fetchCompletion;
@property (atomic, strong) NSError *lastError;
@property (atomic, assign) NSUInteger itemsAdded;

@end

@implementation ORSFProviderInstagram

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.queries = nil;
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    
    self.queries = [self searchQueries];
    self.lastIDs = [NSMutableDictionary dictionaryWithCapacity:self.queries.count];
}

- (NSArray *)searchQueries
{
    if (!self.entity.hashtags) return nil;

    NSMutableArray *queries = [NSMutableArray arrayWithCapacity:self.entity.hashtags];

    for (NSString *obj in self.entity.hashtags) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        keyword = [keyword stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if (keyword && ![keyword isEqualToString:@""]) [queries addObject:keyword];
    }
    
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
        
        for (ORInstagramImage *ig in items) {
            ORSFInstagramImage *item = [[ORSFInstagramImage alloc] initWithIGImage:ig andEntity:self.entity];
            
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
        }
        
        self.operations = nil;
        self.lastError = nil;
    }
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    ORInstagramEngine *engine = [ORInstagramEngine sharedInstance];
    
    if (!self.entity || !engine.isAuthenticated || !self.queries) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching Instagram items...");
    
    dispatch_queue_t queue = dispatch_get_current_queue();
    engine.delegate = nil;
    
    self.fetchCompletion = completion;
    self.operations = [NSMutableDictionary dictionaryWithCapacity:[self.queries count]];
    self.lastError = nil;
    self.itemsAdded = 0;
    
    for (NSString *query in self.queries) {
        NSString *maxID = [self.lastIDs objectForKey:query];
        
        MKNetworkOperation *op = [engine getImagesForTag:query minID:nil maxID:maxID completion:^(NSError *error, NSArray *items, NSString *nextID) {
            dispatch_async(queue, ^{
                [self.lastIDs setValue:nextID forKey:query];
                [self handleNewItems:items error:error query:query];
            });
        }];
        
        [self.operations setObject:op forKey:query];
    }
    
    if (self.entity.latitude != 0 && self.entity.longitude != 0) {
        MKNetworkOperation *op = [engine getImagesForLat:self.entity.latitude Lng:self.entity.longitude completion:^(NSError *error, NSArray *items, NSString *nextID) {
            dispatch_async(queue, ^{
                [self handleNewItems:items error:error query:@"location"];
            });
        }];
        
        [self.operations setObject:op forKey:@"location"];
    }
}

@end

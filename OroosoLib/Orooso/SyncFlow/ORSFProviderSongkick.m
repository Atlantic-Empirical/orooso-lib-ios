//
//  ORSFProviderSongkick.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderSongkick.h"
#import "ORSongkickEngine.h"
#import "ORSongkickEvent.h"
#import "ORSFSongkickEvent.h"
#import "OREntity.h"

@interface ORSFProviderSongkick ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderSongkick

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.page = 0;
    }
    
    return self;
}

- (NSString *)searchQuery
{
    return self.entity.name;
}

- (void)reset
{
    [super reset];
    
    self.page = 0;
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (!self.entity || self.secondTry || self.page > 0 ||
        self.entity.entityType != OREntityType_RecordingArtist ||
        self.currentLatitude == 0 || self.currentLongitude == 0) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching Songkick items...");
    
    ORSongkickEngine *engine = [ORSongkickEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    self.op = [engine findConcertsForArtist:[self searchQuery] lat:self.currentLatitude lng:self.currentLongitude completion:^(NSError *error, NSArray *items) {
        dispatch_async(queue, ^{
            self.op = nil;
            
            if (error) {
                if (completion) completion(error, 0);
                return;
            }
            
            // Create the item set, if needed
            if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:items.count];
            
            NSUInteger added = 0;
            self.page++;
            
            for (ORSongkickEvent *event in items) {
                ORSFSongkickEvent *item = [[ORSFSongkickEvent alloc] initWithSKEvent:event andEntity:self.entity];
                
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

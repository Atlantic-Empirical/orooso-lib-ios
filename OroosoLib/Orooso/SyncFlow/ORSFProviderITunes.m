//
//  ORSFProviderITunes.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 22/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderITunes.h"
#import "ORApiEngine.h"

#define ITEM_COUNT 25

@interface ORSFProviderITunes ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderITunes

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
    if (!self.entity || self.secondTry) {
        if (completion) completion(nil, 0);
        return;
    }

    NSLog(@"Fetching iTunes items...");
    
    ORApiEngine *engine = [ORApiEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    // Set "explicit" if maturity level is higher than 0
    BOOL explicit = (self.maturityLevel > 0) ? NO : YES;
    
    self.op = [engine itunesSearch:[self searchQuery] entityType:self.entity.entityType page:self.page count:ITEM_COUNT explicit:explicit cb:^(NSError *error, NSArray *items) {
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
            
            for (ORITunesObject *item in items) {
                ORSFITunes *itunes = [[ORSFITunes alloc] initWithITunesObject:item andEntity:self.entity];
                
                // Only add item if it's not already in the set
                if (![self.items containsObject:itunes]) {
					itunes.taken = NO;
					[itunes setRawScores];
                    [self.items addObject:itunes];
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

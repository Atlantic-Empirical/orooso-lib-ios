//
//  ORSFProviderSuggestions.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 16/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderSuggestions.h"
#import "ORFreebaseEngine.h"
#import "ORUtility.h"
#import "ORSFEntity.h"
#import "OREntity.h"
#import "ORInstantResult.h"

#define ITEM_COUNT 25

@interface ORSFProviderSuggestions ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderSuggestions

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
    if (!self.entity || self.page > 0) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching Freebase suggestions...");
    
    ORFreebaseEngine *engine = [ORFreebaseEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    self.op = [engine searchFor:[self searchQuery] cb:^(NSError *error, NSArray *items) {
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
            
            for (ORInstantResult *item in items) {
                OREntity *en = [[OREntity alloc] init];
                en.entityId = [ORUtility newGuidString];
                en.freebaseID = item.freebaseID;
                en.name = item.name;
                en.subtitle = item.typeName;
                en.isDynamic = NO;
                
                ORSFEntity *item = [[ORSFEntity alloc] initWithEntity:en parentEntity:self.entity];
                item.taken = NO;
                
                [self.items addObject:item];
                self.itemsAvailable++;
                added++;
            }
            
            // Return to caller
            if (completion) completion(nil, added);
        });
    }];
}

@end

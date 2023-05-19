//
//  ORSFProviderRelated.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 29/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderRelated.h"
#import "ORUtility.h"
#import "ORSFEntity.h"
#import "OREntity.h"
#import "OREntityFilm.h"
#import "ORSFItemFacts.h"
#import "ORIDValue.h"

@interface ORSFProviderRelated ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderRelated

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

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (self.page > 0) {
        if (completion) completion(nil, 0);
        return;
    }
    
    // Create the item set, if needed
    if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:5];
    
    NSUInteger added = 0;
    self.page++;

    // Add specialized content
    switch (self.entity.entityType) {
        case OREntityType_Movie:
            added += [self addEntityFilmContent];
            break;
        default:
            break;
    }
    
    // Associated People
    for (NSString *obj in self.entity.associatedPeople) {
        NSString *name = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (name && ![name isEqualToString:@""]) {
            OREntity *en = [[OREntity alloc] init];
            en.entityId = [ORUtility newGuidString];
            en.name = name;
            en.subtitle = @"Associated Topic";
            en.hashtags = @[[en.name stringByReplacingOccurrencesOfString:@" " withString:@""]];
            en.isDynamic = YES;
            
            ORSFEntity *item = [[ORSFEntity alloc] initWithEntity:en parentEntity:self.entity];
            item.scoreBlendedNormalized = [ORUtility randomFloatBetween:0 and:9999];
            item.taken = NO;
            
            [self.items addObject:item];
            self.itemsAvailable++;
            added++;
        }
    }
    
    if (added > 0) [self sortItems];
    
    // Return to caller
    if (completion) completion(nil, added);
}

- (NSUInteger)addEntityFilmContent
{
    if (![self.entity isKindOfClass:[OREntityFilm class]]) return 0;
    
    OREntityFilm *film = (OREntityFilm *)self.entity;
    NSUInteger added = 0;
    
    // Movie Cast
    for (ORIDValue *item in film.starring) {
        [self addItemWithIDValue:item type:@"Movie Cast"];
        added++;
    }

    // Directors
    for (ORIDValue *item in film.directors) {
        [self addItemWithIDValue:item type:@"Director"];
        added++;
    }
    
    // Executive Producers
    for (ORIDValue *item in film.executiveProducers) {
        [self addItemWithIDValue:item type:@"Executive Producer"];
        added++;
    }
    
    // Producer
    for (ORIDValue *item in film.producers) {
        [self addItemWithIDValue:item type:@"Producer"];
        added++;
    }
    
    // Writers
    for (ORIDValue *item in film.writers) {
        [self addItemWithIDValue:item type:@"Writer"];
        added++;
    }
    
    return added;
}

- (void)addItemWithIDValue:(ORIDValue *)iv type:(NSString *)type
{
    OREntity *en = [[OREntity alloc] init];
    en.entityId = [ORUtility newGuidString];
    en.freebaseID = iv.id;
    en.name = iv.value;
    en.subtitle = type;
    en.isDynamic = YES;
    
    ORSFEntity *item = [[ORSFEntity alloc] initWithEntity:en parentEntity:self.entity];
    item.scoreBlendedNormalized = [ORUtility randomFloatBetween:0.0f and:9999.0f];
    item.taken = NO;
    
    [self.items addObject:item];
    self.itemsAvailable++;
}

@end

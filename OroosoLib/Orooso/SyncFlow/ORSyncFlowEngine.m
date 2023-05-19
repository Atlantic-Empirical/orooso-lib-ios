 //
//  TPFViewable.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 6/13/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORSyncFlowEngine.h"
#import "ORStrings.h"
#import "ORSFItem.h"
#import "ORSFMainEntity.h"
#import "ORUtility.h"

#import "ORSFProviderTwitterTimeline.h"
#import "ORSFProviderTwitterNews.h"
#import "ORSFProviderContent.h"
#import "ORSFProviderTwitter.h"
#import "ORSFProviderInstagram.h"
#import "ORSFProviderSongkick.h"
#import "ORSFProviderYTL.h"
#import "ORSFProviderVimeo.h"
#import "ORSFProviderTVNZ.h"
#import "ORSFProviderBoard.h"
#import "ORSFProviderPairings.h"
#import "ORSFProviderRelated.h"
#import "ORSFProviderSuggestions.h"
#import "ORSFProviderReddit.h"
#import "ORSFProviderRedditSearch.h"

#define EVENTS_INITIAL_BUFFER 5

const char * kSFEQueueName = "com.orooso.sfequeue";

@interface ORSyncFlowEngine ()

// SyncFlow Datasource
@property (nonatomic, assign) NSUInteger totalItemCount;
@property (nonatomic, assign) NSUInteger totalFeaturedItemCount;
@property (nonatomic, assign) NSUInteger syncFlowItemCount;
@property (nonatomic, assign) NSUInteger syncFlowFeaturedItemCount;
@property (nonatomic, assign) NSUInteger removedItemCount;
@property (nonatomic, strong) NSMutableArray *syncFlowItems;
@property (nonatomic, strong) NSMutableArray *syncFlowFeaturedItems;
@property (nonatomic, assign) NSUInteger lastIndex;
@property (nonatomic, assign) NSUInteger lastIndexFeatured;

// Providers Management
@property (nonatomic, assign) NSUInteger providerCount;
@property (nonatomic, assign) NSUInteger currentProvider;
@property (nonatomic, assign) NSUInteger currentFeaturedProvider;
@property (nonatomic, strong) NSMutableArray *providers;
@property (nonatomic, strong) NSMapTable *providersMT;
@property (assign, nonatomic) BOOL isStartingProviders;

// Entities Management
@property (strong, nonatomic) NSMutableArray *entities;
@property (assign, atomic) BOOL isPreloadingCanceled;

@end

@implementation ORSyncFlowEngine

- (void)dealloc
{
    if (_queue) {
        dispatch_release(_queue);
        _queue = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ORSyncFlowEngine*) init
{
	self = [super init];

	if (self) {
        _queue = dispatch_queue_create(kSFEQueueName, NULL);
        _isStartingProviders = NO;
		_entities = [NSMutableArray array];
        _currentLatitude = 0;
        _currentLongitude = 0;
        _lastIndex = NSNotFound;
        _lastIndexFeatured = NSNotFound;
        _syncFlowItemCount = 0;
        _syncFlowFeaturedItemCount = 0;
        _removedItemCount = 0;
        _totalItemCount = 0;
        _totalFeaturedItemCount = 0;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackground:) name:sfeEnterBackground object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResumeFromBackground:) name:sfeResumeFromBackground object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationUpdated:) name:sfeLocationUpdated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImageFailed:) name:sfeSummaryCellImageFailed object:nil];
	}
    
    return self;
}

- (void)setMaturityLevel:(NSUInteger)maturityLevel
{
    if (maturityLevel == _maturityLevel) return;
    _maturityLevel = maturityLevel;
    
    for (ORSFProvider *provider in self.providers) {
        provider.maturityLevel = maturityLevel;
    }
}

#pragma mark - Entities

- (void)addEntity:(OREntity*)entity online:(BOOL)online
{
    dispatch_async(_queue, ^{
        // If the entity was already preloaded, just switch it to online
        if (self.preloadingEntity && [self.preloadingEntity.entityId isEqualToString:entity.entityId]) {
            if (!online) return;
            
            self.currentEntity = self.preloadingEntity;
            self.currentEntity.isOnline = YES;
            self.preloadingEntity = nil;
            
            [self.entities addObject:self.currentEntity];
            [self startProviders:entity reset:NO];
            
            if (self.currentEntity.isLoading) {
                [self checkIfEntityIsLoaded:self.currentEntity];
            } else {
                [self addEntityToSF:self.currentEntity];
            }
            
            return;
        }
        
        // If we're trying to add the same entity again...
        if (self.currentEntity && [self.currentEntity.entityId isEqualToString:entity.entityId]) {
            if (online) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:sfeEntityAdded object:entity];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:sfeEntityPreloaded object:entity];
                });
            }
            
            return;
        }
        
        entity.isLoading = YES;
        entity.isOnline = online;
        [self configureProviders:entity];
        
        if (online) {
            NSLog(@"Loading Entity: %@", entity.name);
            [self.entities addObject:entity];
            self.currentEntity = entity;
        } else {
            NSLog(@"Preloading Entity: %@", entity.name);
            self.isPreloadingCanceled = NO;
            self.preloadingEntity = entity;
        }
        
        [self startProviders:entity reset:YES];
    });
}

- (void)removeEntity:(OREntity *)entity
{
    // It was preloading, just cancel it
    if (!entity.isOnline) {
        NSLog(@"Canceling Entity Preload: %@", entity.name);
        [self stopProviders];
        self.preloadingEntity = nil;

        return;
    }
    
    NSLog(@"Removing Entity: %@", entity.name);

    [self stopProviders];
    
    // Clear the Item Array
    self.totalItemCount = 0;
    self.totalFeaturedItemCount = 0;
    self.removedItemCount = 0;
    self.syncFlowItems = nil;
    self.syncFlowFeaturedItems = nil;
    self.lastIndex = NSNotFound;
    self.lastIndexFeatured = NSNotFound;
    
    [self reloadSyncFlow];
    
    [self.entities removeObject:entity];
    if (self.currentEntity == entity) self.currentEntity = nil;
}

- (void)removeEntityById:(NSString*)entityId
{
    dispatch_async(_queue, ^{
        if (self.preloadingEntity && [self.preloadingEntity.entityId isEqualToString:entityId]) {
            [self removeEntity:self.preloadingEntity];
            return;
        }
        
        __block OREntity *entity = nil;

        for (OREntity *ent in self.entities) {
            if ([ent.entityId isEqualToString:entityId]) {
                entity = ent;
                break;
            }
        }
        
        if (entity) [self removeEntity:entity];
    });
}

- (void)removeAllEntities
{
    dispatch_async(_queue, ^{
        NSLog(@"Removing ALL Entities");
        
        [self stopProviders];
        
        // Clear the Item Array
        self.totalItemCount = 0;
        self.totalFeaturedItemCount = 0;
        self.removedItemCount = 0;
        self.syncFlowItems = nil;
        self.syncFlowFeaturedItems = nil;
        self.lastIndex = NSNotFound;
        self.lastIndexFeatured = NSNotFound;
        
        [self reloadSyncFlow];

        [self.entities removeAllObjects];
        self.currentEntity = nil;
    });
}

- (void)cancelPreloadById:(NSString *)entityId
{
    self.isPreloadingCanceled = YES;
    
    dispatch_async(_queue, ^{
        if (self.preloadingEntity && [self.preloadingEntity.entityId isEqualToString:entityId]) {
            [self removeEntity:self.preloadingEntity];
            return;
        }
    });
}

- (BOOL)isEntityAlreadyActive:(NSString *)entityId
{
    for (OREntity* ent in self.entities) {
        if ([ent.entityId isEqualToString:entityId] && ent.isOnline) return YES;
    }
    
    return NO;
}

- (OREntity *)entityWithId:(NSString *)entityId
{
    for (OREntity* ent in self.entities) {
        if ([ent.entityId isEqualToString:entityId]) return ent;
    }
    
    return nil;
}

- (void)checkIfEntityIsLoaded:(OREntity *)entity
{
    if (!entity || !entity.isLoading) return;
    entity.isLoading = NO;
    
    if (entity.isOnline) {
        [self addEntityToSF:entity];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isPreloadingCanceled) {
                NSLog(@"Entity Finished Preloading: %@", entity.name);
                [[NSNotificationCenter defaultCenter] postNotificationName:sfeEntityPreloaded object:entity];
            }
        });
    }
}

- (void)addEntityToSF:(OREntity *)entity
{
    // Initialize the Events Array
    [self updateItemCount];
    self.syncFlowItems = [NSMutableArray arrayWithCapacity:self.totalItemCount];
    self.syncFlowFeaturedItems = [NSMutableArray arrayWithCapacity:self.totalFeaturedItemCount];
    self.lastIndex = NSNotFound;
    self.lastIndexFeatured = NSNotFound;
    
    if (self.totalItemCount > 0) [self itemAtIndex:MIN(EVENTS_INITIAL_BUFFER, self.totalItemCount - 1)];
    if (self.totalFeaturedItemCount > 0) [self featuredItemAtIndex:MIN(EVENTS_INITIAL_BUFFER, self.totalFeaturedItemCount - 1)];
    
    [self reloadSyncFlow];
    
    NSLog(@"Entity Finished Loading: %@", entity.name);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:sfeEntityAdded object:entity];
    });
}

#pragma mark - SyncFlow Datasource

- (NSUInteger)itemCount
{
    return self.syncFlowItemCount;
}

- (NSUInteger)featuredItemCount
{
    return self.syncFlowFeaturedItemCount;
}

- (ORSFItem *)itemAtIndex:(NSUInteger)index
{
    if (self.lastIndex != NSNotFound && index <= self.lastIndex) {
        return self.syncFlowItems[index];
    }
    
    if (!self.syncFlowItems) self.syncFlowItems = [NSMutableArray arrayWithCapacity:1];
    NSUInteger start = (self.lastIndex == NSNotFound) ? 0 : self.lastIndex + 1;
    
    for (NSUInteger i = start; i <= index; i++) {
        [self.syncFlowItems addObject:[self fetchItemFromProviders]];
    }
    
    self.lastIndex = index;
    return self.syncFlowItems[index];
}

- (ORSFItem *)featuredItemAtIndex:(NSUInteger)index
{
    if (self.lastIndexFeatured != NSNotFound && index <= self.lastIndexFeatured) {
        return self.syncFlowFeaturedItems[index];
    }
    
    if (!self.syncFlowFeaturedItems) self.syncFlowFeaturedItems = [NSMutableArray arrayWithCapacity:1];
    NSUInteger start = (self.lastIndexFeatured == NSNotFound) ? 0 : self.lastIndexFeatured + 1;
    
    for (NSUInteger i = start; i <= index; i++) {
        [self.syncFlowFeaturedItems addObject:[self fetchFeaturedItemFromProviders]];
    }
    
    self.lastIndexFeatured = index;
    return self.syncFlowFeaturedItems[index];
}

- (void)reloadSyncFlow
{
    NSLog(@"Reloading SyncFlow");
    
    if ([NSThread isMainThread]) {
        self.syncFlowItemCount = self.totalItemCount;
        self.syncFlowFeaturedItemCount = self.totalFeaturedItemCount;
        [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsReloaded object:self];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.syncFlowItemCount = self.totalItemCount;
            self.syncFlowFeaturedItemCount = self.totalFeaturedItemCount;
            [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsReloaded object:self];
        });
    }
}

- (void)newItemsArrived
{
    [self updateItemCount];
    
    if (self.totalItemCount > self.syncFlowItemCount) {
        NSUInteger startIndex = self.syncFlowItemCount;
        NSUInteger count = self.totalItemCount - startIndex;
        
        NSMutableArray *insertedPaths = [NSMutableArray arrayWithCapacity:count];
        for (int i = startIndex; i < (startIndex + count); i++) {
            [insertedPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        NSLog(@"Adding %d items to SyncFlow", count);
        
        if ([NSThread isMainThread]) {
            self.syncFlowItemCount += count;
            [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsChanged
                                                                object:self
                                                              userInfo:@{@"insertedPaths": insertedPaths}];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.syncFlowItemCount += count;
                [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsChanged
                                                                    object:self
                                                                  userInfo:@{@"insertedPaths": insertedPaths}];
            });
        }
    }
}

- (void)handleImageFailed:(NSNotification *)n
{
    if (!n.object || ![n.object isKindOfClass:[NSIndexPath class]]) return;
    
    NSIndexPath *ip = (NSIndexPath *)n.object;
    
    [self.syncFlowItems removeObjectAtIndex:ip.row];
    
    self.lastIndex--;
    self.totalItemCount--;
    self.syncFlowItemCount--;
    self.removedItemCount++;

    NSLog(@"Removing 1 item from SyncFlow");
    
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsChanged
                                                            object:self
                                                          userInfo:@{@"removedPaths": @[ip]}];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsChanged
                                                                object:self
                                                              userInfo:@{@"removedPaths": @[ip]}];
        });
    }
}

#pragma mark - Content Providers

- (void)addProvider:(ORSFProvider *)provider key:(NSString *)key
{
    provider.name = key;
    provider.sfeQueue = self.queue;
    provider.maturityLevel = self.maturityLevel;
    provider.currentLatitude = self.currentLatitude;
    provider.currentLongitude = self.currentLongitude;
    
    [self.providers addObject:provider];
    [self.providersMT setObject:provider forKey:key];
    
    self.providerCount++;
}

- (void)configureProviders:(OREntity *)entity
{
    [self stopProviders];
    
    [self.providers removeAllObjects];
    [self.providersMT removeAllObjects];
    
    self.providers = [NSMutableArray arrayWithCapacity:7];
    self.providersMT = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    self.providerCount = 0;
    self.currentProvider = 0;
    self.currentFeaturedProvider = 0;
    
    if (entity.entityType == OREntityType_Twitter) {
        // Twitter Timeline Provider
        [self addProvider:[[ORSFProviderTwitterTimeline alloc] initWithFrequency:1] key:@"twitter_timeline"];
    } else if (entity.entityType == OREntityType_TwitterNews) {
        // Twitter News Provider
        [self addProvider:[[ORSFProviderTwitterNews alloc] initWithFrequency:1] key:@"twitter_news"];
    } else if (entity.entityType == OREntityType_YouTubeLive) {
        // YouTube Live Events Provider
        [self addProvider:[[ORSFProviderYTL alloc] initWithFrequency:1] key:@"ytl"];
    } else if (entity.entityType == OREntityType_TVNewZealand) {
        // TVNZ Provider
        [self addProvider:[[ORSFProviderTVNZ alloc] initWithFrequency:1] key:@"tvnz"];
    } else if (entity.entityType == OREntityType_Board) {
        // Board Provider
        [self addProvider:[[ORSFProviderBoard alloc] initWithFrequency:1] key:@"board"];
    } else {
        // Suggestions only for Dynamic entities
        if (entity.isDynamic && !entity.freebaseID) {
            [self addProvider:[[ORSFProviderSuggestions alloc] initWithFrequency:4] key:@"suggestions"];
        }
        
        // Content Provider
        [self addProvider:[[ORSFProviderContent alloc] initWithFrequency:1] key:@"content"];
        
        // Twitter Provider
        [self addProvider:[[ORSFProviderTwitter alloc] initWithFrequency:2] key:@"twitter"];
        
        // Instagram Provider
        [self addProvider:[[ORSFProviderInstagram alloc] initWithFrequency:3] key:@"instagram"];

        // Songkick Provider
        [self addProvider:[[ORSFProviderSongkick alloc] initWithFrequency:3] key:@"songkick"];

        // Vimeo Provider
        [self addProvider:[[ORSFProviderVimeo alloc] initWithFrequency:4] key:@"vimeo"];

        // Pairings Provider
        [self addProvider:[[ORSFProviderPairings alloc] initWithFrequency:8] key:@"pairings"];

        // Related Provider
        [self addProvider:[[ORSFProviderRelated alloc] initWithFrequency:5] key:@"related"];

        // Reddit Provider
        [self addProvider:[[ORSFProviderReddit alloc] initWithFrequency:2] key:@"reddit"];

        // Reddit Search Provider
        [self addProvider:[[ORSFProviderRedditSearch alloc] initWithFrequency:3] key:@"reddit_search"];
    }
}

- (void)startProviders:(OREntity *)entity reset:(BOOL)reset
{
    __weak ORSyncFlowEngine *weakSelf = self;
    __weak OREntity *weakEntity = entity;
    
    NSLog(@"Starting Providers");
    self.isStartingProviders = YES;
    
    // Load data from all providers
    for (ORSFProvider *provider in self.providers) {
        __weak ORSFProvider *weakProvider = provider;
        provider.entity = entity;
        if (reset) [provider reset];
        
        provider.newItemsBlock = ^(NSError *error, NSInteger added) {
            if (error) {
                NSLog(@"Error (%@): %@", weakProvider, error);
            }
            
            // Notify everyone that we have new items
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:sfeItemsArrived
                                                                    object:self
                                                                  userInfo:@{@"provider": weakProvider.name,
                                                                             @"items": @(added)}];
            });
            
            if (!weakSelf.isStartingProviders) {
                if (weakEntity.isLoading) {
                    if (![weakSelf allProvidersDone]) return;
                    [weakSelf checkIfEntityIsLoaded:weakEntity];
                } else if (added > 0) {
                    [weakSelf newItemsArrived];
                }
            }
        };
        
        [provider start];
    }
    
    self.isStartingProviders = NO;
}

- (void)stopProviders
{
    NSLog(@"Stopping Providers");
    
    for (ORSFProvider *provider in self.providers) {
        provider.entity = nil;
        provider.newItemsBlock = nil;
        [provider stop];
    }
}

- (ORSFItem *)fetchItemFromProviders
{
    ORSFItem *item = nil;
    NSUInteger cycles = 0;
    
    while (!item && cycles <= self.providerCount) {
        ORSFProvider *provider = self.providers[self.currentProvider];
        
        if (provider.currentCycle == provider.frequency && provider.itemsAvailable > 0) {
            item = [provider takeItemAndReloadIfNeeded:YES];
        }

        if (provider.frequency > 1) {
            provider.currentCycle++;
            if (provider.currentCycle > provider.frequency) provider.currentCycle = 1;
        }
        
        self.currentProvider++;
        if (self.currentProvider == self.providerCount) self.currentProvider = 0;
        
        cycles++;
    }
    
    if (item) return item;

    // Oops, scrolling fast probably, get the first item we can find
    for (ORSFProvider *provider in self.providers) {
        if (provider.itemsAvailable > 0) {
            item = [provider takeItemAndReloadIfNeeded:YES];
            if (item) break;
        }
    }

    if (item) return item;

    // Panic! Last chance, return anything
    static NSUInteger lastChancePos = 0;
    ORSFProvider *provider = self.providers[0];
    item = provider.items[lastChancePos++];
    if (lastChancePos >= provider.items.count) lastChancePos = 0;

    return item;
}

- (ORSFItem *)fetchFeaturedItemFromProviders
{
    ORSFItem *item = nil;
    NSUInteger cycles = 0;
    
    while (!item && cycles <= self.providerCount) {
        ORSFProvider *provider = self.providers[self.currentFeaturedProvider];
        
        if (provider.currentFeaturedCycle == provider.frequency && provider.itemsAvailable > 0) {
            item = [provider takeFeaturedItemAndReloadIfNeeded:YES];
        }
        
        if (provider.frequency > 1) {
            provider.currentFeaturedCycle++;
            if (provider.currentFeaturedCycle > provider.frequency) provider.currentFeaturedCycle = 1;
        }
        
        self.currentFeaturedProvider++;
        if (self.currentFeaturedProvider == self.providerCount) self.currentFeaturedProvider = 0;
        
        cycles++;
    }
    
    if (item) return item;
    
    // Oops, scrolling fast probably, get the first item we can find
    for (ORSFProvider *provider in self.providers) {
        if (provider.itemsAvailable > 0) {
            item = [provider takeFeaturedItemAndReloadIfNeeded:YES];
            if (item) break;
        }
    }
    
    if (item) return item;
    
    // Panic! Last chance, return anything
    static NSUInteger lastChancePos = 0;
    ORSFProvider *provider = self.providers[0];
    item = provider.featuredItems[lastChancePos++];
    if (lastChancePos >= provider.featuredItems.count) lastChancePos = 0;
    
    return item;
}

- (NSArray *)allItemsFromProvider:(NSString *)provider type:(SFItemType)type
{
    // For board items, the provider is always "board"
    if (self.currentEntity.entityType == OREntityType_Board) provider = @"board";
    
    ORSFProvider *p = [self.providersMT objectForKey:provider];
    if (!p) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:p.items.count];

    for (ORSFItem *item in p.featuredItems) {
        if (item.type == type) [items addObject:item];
    }
    
    for (ORSFItem *item in p.items) {
        if (item.type == type) [items addObject:item];
    }
    
    return items;
}

- (BOOL)allProvidersDone
{
    BOOL allDone = YES;
    
    // Check if all providers are done
    for (ORSFProvider *provider in self.providers) {
        if (provider.isWorking) {
            allDone = NO;
            break;
        }
    }
    
    // TODO: we could add a timeout here
    return allDone;
}

- (void)updateItemCount
{
    NSUInteger count = 0, featuredCount = 0;
    
    for (ORSFProvider *provider in self.providers) {
        count += provider.items.count;
        featuredCount += provider.featuredItems.count;
    }
    
    NSLog(@"%d - %d", count, featuredCount);
    
    self.totalItemCount = count - self.removedItemCount;
    self.totalFeaturedItemCount = featuredCount;
}

#pragma mark - Enter/Resume From Background

- (void)handleEnterBackground:(NSNotification *)notification
{
    NSLog(@"SFE: Entering Background");
    [self stopProviders];
}

- (void)handleResumeFromBackground:(NSNotification *)notification
{
    NSLog(@"SFE: Resuming From Background");
    [self startProviders:self.currentEntity reset:NO];
}

#pragma mark - Location

- (void)handleLocationUpdated:(NSNotification *)notification
{
    self.currentLatitude = [[notification.userInfo valueForKey:@"latitude"] doubleValue];
    self.currentLongitude = [[notification.userInfo valueForKey:@"longitude"] doubleValue];
    
    for (ORSFProvider *provider in self.providers) {
        provider.currentLatitude = self.currentLatitude;
        provider.currentLongitude = self.currentLongitude;
    }
    
    NSLog(@"Location Updated: %f, %f", self.currentLatitude, self.currentLongitude);
}

@end

//
//  ORSFProvider.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 19/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OREntity, ORSFItem;

typedef void (^ORSFProviderIntBlock)(NSError *error, NSInteger added);

@interface ORSFProvider : NSObject

@property (atomic, copy) NSString *name;
@property (atomic, weak) OREntity *entity;
@property (atomic, copy) ORSFProviderIntBlock newItemsBlock;
@property (atomic, assign) dispatch_queue_t sfeQueue;
@property (atomic, assign) NSUInteger currentCycle;
@property (atomic, assign) NSUInteger currentFeaturedCycle;
@property (atomic, assign) NSUInteger frequency;
@property (atomic, assign) NSUInteger minimumThreshold;
@property (atomic, assign) NSUInteger maturityLevel;

@property (readonly) NSMutableOrderedSet *items;
@property (readonly) NSMutableOrderedSet *featuredItems;
@property (readonly) NSUInteger itemsAvailable;
@property (readonly) NSUInteger featuredItemsAvailable;
@property (readonly) MKNetworkOperation *op;
@property (readonly) BOOL isWorking;
@property (readonly) BOOL secondTry;

@property (nonatomic, assign) double currentLatitude;
@property (nonatomic, assign) double currentLongitude;

// Public Methods
- (id)initWithFrequency:(NSUInteger)frequency;
- (ORSFItem *)takeItemAndReloadIfNeeded:(BOOL)reload;
- (ORSFItem *)takeFeaturedItemAndReloadIfNeeded:(BOOL)reload;
- (void)reset;
- (void)stop;
- (void)start;

// Protected Methods (should not be called externally)
- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion;
- (void)fetchMoreItems;
- (void)sortItems;

// Scoring
- (void)normalizeSubscores;
- (void)normalizeBlendedScoresToFinalScore:(float)cutoff;

@end

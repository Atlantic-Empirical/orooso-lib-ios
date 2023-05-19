//
//  TPFViewable.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 6/13/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORTwitterEngine.h"
#import "OREntity.h"
#import "ORSFItem.h"

@class ORImage, ORBoard;

@interface ORSyncFlowEngine : NSObject

@property (readonly) dispatch_queue_t queue;
@property (assign, nonatomic) NSUInteger maturityLevel;
@property (nonatomic, assign) double currentLatitude;
@property (nonatomic, assign) double currentLongitude;
@property (strong, nonatomic) OREntity *currentEntity;
@property (strong, nonatomic) OREntity *preloadingEntity;
@property (strong, nonatomic) ORBoard *currentBoard;

@property (nonatomic, copy) NSString *itemIdToFocus;

- (NSUInteger)itemCount;
- (NSUInteger)featuredItemCount;
- (ORSFItem *)itemAtIndex:(NSUInteger)index;
- (ORSFItem *)featuredItemAtIndex:(NSUInteger)index;

- (void)addEntity:(OREntity *)entity online:(BOOL)online;
- (void)removeEntityById:(NSString *)entityId;
- (void)removeAllEntities;
- (void)cancelPreloadById:(NSString *)entityId;
- (BOOL)isEntityAlreadyActive:(NSString *)entityId;
- (OREntity *)entityWithId:(NSString *)entityId;
- (NSArray *)allItemsFromProvider:(NSString *)provider type:(SFItemType)type;

@end

//
//  ORSFItem.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/12/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@class UIImage, OREntity, ORURL;

typedef enum _SFItemType {
    SFItemTypeGeneric,
    SFItemTypeTweet,
    SFItemTypeImage,
    SFItemTypeVideo,
    SFItemTypeITunes,
    SFItemTypeWebsite,
    SFItemTypeEntity,
    SFItemTypeTwitterURL,
    SFItemTypeNYTArticle,
    SFItemTypeSongkickEvent,
    SFItemTypeIGImage,
    SFItemTypeWikipedia,
    SFItemTypePairPrompt,
    SFItemTypeMainEntity,
    SFItemTypeFacts,
} SFItemType;

@protocol ORSFItemDelegate;

@interface ORSFItem : NSObject <NSCoding>

// Serializable Properties
@property (nonatomic, assign)   SFItemType type;
@property (nonatomic, copy)     NSString *itemID;
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, copy)     NSString *content;
@property (atomic, strong)      ORURL *detailURL;
@property (atomic, copy)        NSURL *imageURL;
@property (atomic, copy)        NSURL *avatarURL;
@property (atomic, strong)      NSMutableArray *otherURLs; // ORURL
@property (nonatomic, strong)   NSString *provider;

// Other Properties
@property (nonatomic, readonly) NSString *cellIdentifier;
@property (nonatomic, strong)   OREntity *parentEntity;
@property (nonatomic, assign)   BOOL toggled;
@property (atomic, weak)        id<ORSFItemDelegate> delegate;
@property (nonatomic, assign)   BOOL inserted;
@property (nonatomic, assign)   BOOL removed;
@property (nonatomic, assign)   BOOL taken;

// Boards
@property (nonatomic, assign)   BOOL loadedBoards;
@property (nonatomic, assign)   BOOL favorited;
@property (nonatomic, assign)   BOOL pinned;
@property (nonatomic, strong)   NSMutableSet *boards;

// Scoring
@property (nonatomic, assign) CGFloat scoreBlendedWeighted;
@property (nonatomic, assign) CGFloat scoreBlendedNormalized;
@property (nonatomic, strong) NSMutableDictionary *rawSubscores;
@property (nonatomic, strong) NSMutableDictionary *normalizedSubscores;
@property (nonatomic, strong) NSMutableDictionary *weightedSubscores;
@property (nonatomic, strong) NSMutableDictionary *subscoreWeights; // must have same keys as .rawSubscores

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (id)initWithEntity:(OREntity *)entity itemID:(NSString *)itemID;

- (UIImage *)mainImage;
- (UIImage *)avatarImage;

- (void)searchForImages;
- (void)parseOtherURLsForImages:(BOOL)resolve;
- (void)setDetailURL:(ORURL *)detailURL resolve:(BOOL)resolve;
- (void)cancelPendingOperations;
- (void)setRawScores;
- (void)weightAndBlendSubscores;
- (void)fallbackToPlaceholderImage;

// Boards
- (void)pinnedBoardsWithCompletion:(void (^)(ORSFItem *item))completion;
- (void)addBoard:(NSString *)boardId;
- (void)removeBoard:(NSString *)boardId;

@end

@protocol ORSFItemDelegate <NSObject>

- (void)item:(ORSFItem *)item avatarLoaded:(UIImage *)image local:(BOOL)local;
- (void)item:(ORSFItem *)item imageLoaded:(UIImage *)image local:(BOOL)local;
- (void)itemDetailURLResolved:(ORSFItem *)item;
- (void)itemImageIsLoading:(ORSFItem *)item;

@optional

- (void)itemDetailURLFailedToResolve:(ORSFItem *)item;
- (void)itemImageFailedToLoad:(ORSFItem *)item;

@end

//
//  ORSFItem.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/12/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"
#import "ORApiEngine.h"
#import "ORCachedEngine.h"
#import "ORURLResolver.h"
#import "ORImage.h"
#import "ORURL.h"
#import "OREntity.h"

// Child Classes
#import "ORSFEntity.h"
#import "ORSFMainEntity.h"
#import "ORSFVideo.h"
#import "ORSFImage.h"
#import "ORSFITunes.h"
#import "ORSFTweet.h"
#import "ORSFTwitterURL.h"
#import "ORSFInstagramImage.h"
#import "ORSFSongkickEvent.h"
#import "ORSFWebsite.h"
#import "ORSFPairPrompt.h"
#import "ORSFItemFacts.h"

#define LOG_SCORING NO

@interface ORSFItem ()
{
    BOOL _isLoadingImage, _isLoadingAvatar, _isResolvingURLs, _alreadySearchedForImages;
}

@property (atomic, strong) NSMutableArray *pendingOperations;

@end

@implementation ORSFItem

+ (id)instanceWithJSON:(NSDictionary *)json
{
    // Usually this is inside initWithJSON, but this is a special case
    // because we need to check the item type to instance the child class
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    SFItemType type = [[json valueForKey:@"Type"] integerValue];
    bool useGeneric = ([json valueForKey:@"UseGeneric"]) ? [[json valueForKey:@"UseGeneric"] boolValue] : true;
    
    switch (type) {
        case SFItemTypeEntity:
            return [[ORSFEntity alloc] initWithJSON:json];
        case SFItemTypeMainEntity:
            return [[ORSFMainEntity alloc] initWithJSON:json];
        case SFItemTypeVideo:
            return [[ORSFVideo alloc] initWithJSON:json];
        case SFItemTypeImage:
            return [[ORSFImage alloc] initWithJSON:json];
        case SFItemTypeITunes:
            return [[ORSFITunes alloc] initWithJSON:json];
        case SFItemTypeTweet:
            return [[ORSFTweet alloc] initWithJSON:json];
        case SFItemTypeTwitterURL:
            return [[ORSFTwitterURL alloc] initWithJSON:json];
        case SFItemTypeIGImage:
            return [[ORSFInstagramImage alloc] initWithJSON:json];
        case SFItemTypeSongkickEvent:
            return [[ORSFSongkickEvent alloc] initWithJSON:json];
        case SFItemTypeWebsite:
            return [[ORSFWebsite alloc] initWithJSON:json];
        case SFItemTypePairPrompt:
            return [[ORSFPairPrompt alloc] initWithJSON:json];
        case SFItemTypeFacts:
            return [[ORSFItemFacts alloc] initWithJSON:json];
        default:
            if (!useGeneric) {
                NSLog(@"Generic item discarded");
                return nil;
            }
            
            return [[self alloc] initWithJSON:json];
    }
}

+ (id)arrayWithJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (NSString *)cellIdentifier
{
    switch (self.type) {
        case SFItemTypeEntity:
            return @"ORSFCardEntity";
        case SFItemTypeMainEntity:
            return @"OREntityCardMain";
        case SFItemTypeVideo:
            return @"ORSFCardVideo";
        case SFItemTypeImage:
            return @"ORSFCardImage";
        case SFItemTypeITunes:
            return @"ORSFCardiTunes";
        case SFItemTypeTweet:
            return @"ORSFCardTweet";
        case SFItemTypeTwitterURL:
            return @"ORSFCardTwitterURL";
        case SFItemTypeSongkickEvent:
            return @"ORSFCardSongKick";
        case SFItemTypeWebsite:
            return @"ORSFCardWebsite";
        case SFItemTypePairPrompt:
            return @"ORSFCardPairPrompt";
        case SFItemTypeFacts:
            return @"ORSFCardFacts";
        default:
            return @"ORSFCardGeneric";
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _type = SFItemTypeGeneric;
        _scoreBlendedWeighted = 0;
        _scoreBlendedNormalized = 0;
        _inserted = NO;
        _removed = NO;
        _taken = NO;
        _alreadySearchedForImages = NO;
        self.pendingOperations = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithEntity:(OREntity *)entity itemID:(NSString *)itemID
{
	self = [self init];
    if (!self) return nil;
    
    self.parentEntity = entity;
    self.imageURL = [NSURL URLWithString:entity.urlRepresentativeImage];
    self.title = entity.name;
    self.itemID = itemID;
    
	return self;
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [self init];
    if (!self) return nil;
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self.type = [[json valueForKey:@"Type"] integerValue];
    self.itemID = [json valueForKey:@"ItemID"];
    self.title = [json valueForKey:@"Title"];
    self.content = [json valueForKey:@"Content"];
    self.provider = [json valueForKey:@"Provider"];
    self.detailURL = [ORURL instanceWithJSON:[json valueForKey:@"DetailURL"]];
    self.imageURL = [NSURL URLWithString:[json valueForKey:@"ImageURL"]];
    self.avatarURL = [NSURL URLWithString:[json valueForKey:@"AvatarURL"]];
    self.otherURLs = [ORURL arrayWithJSON:[json valueForKey:@"OtherURLs"]];
    
    if (self.avatarURL) {
        if ([self.avatarURL.absoluteString rangeOfString:@"s3.amazonaws.com/portl-static"].location != NSNotFound) {
            // Convert the URL to @2x
            if ([[UIScreen mainScreen] scale] > 1.0f) {
                NSLog(@"SCALE: %f", [[UIScreen mainScreen] scale]);
                NSString *extension = [NSString stringWithFormat:@".%@", [self.avatarURL.absoluteString pathExtension]];
                NSString *newExtension =[NSString stringWithFormat:@"@2x%@", extension];
                NSString *newURL = [self.avatarURL.absoluteString stringByReplacingOccurrencesOfString:extension withString:newExtension];
                self.avatarURL = [NSURL URLWithString:newURL];
            }
        }
    }
    
    if (!self.imageURL && !self.otherURLs && self.detailURL) {
        self.otherURLs = [NSMutableArray arrayWithCapacity:1];
        [self.otherURLs addObject:self.detailURL];
    }
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:9];

    [d setValue:@(self.type) forKey:@"Type"];
    [d setValue:self.itemID forKey:@"ItemID"];
    [d setValue:self.title forKey:@"Title"];
    [d setValue:self.content forKey:@"Content"];
    [d setValue:self.provider forKey:@"Provider"];
    [d setValue:[self.detailURL proxyForJson] forKey:@"DetailURL"];
    [d setValue:self.imageURL.absoluteString forKey:@"ImageURL"];
    [d setValue:self.avatarURL.absoluteString forKey:@"AvatarURL"];
    [d setValue:[ORURL proxyForJsonWithArray:self.otherURLs] forKey:@"OtherURLs"];
    
    return d;
}

- (UIImage *)mainImage
{
    if (_isLoadingImage || _isResolvingURLs || !self.delegate) return nil;
    
    if (!self.imageURL) {
        if (self.otherURLs) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self parseOtherURLsForImages:YES];
            });
        } else {
            /* This code is not used anymore, kept for reference
            if (self.type != SFItemTypePerson && self.type != SFItemTypeTweet && !_alreadySearchedForImages) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self searchForImages];
                });
            }
            */
        }
        
        return nil;
    }
    
    _isLoadingImage = YES;
    if (self.delegate) [self.delegate itemImageIsLoading:self];
    
    __weak ORSFItem *weakSelf = self;
    CGSize size = ([self.itemID isEqualToString:self.parentEntity.entityId]) ? L_CARD_SIZE_DOUBLE : L_CARD_SIZE;
    
    MKNetworkOperation *op = [[ORCachedEngine sharedInstance] imageAtURL:self.imageURL size:size completion:^(NSError *error, MKNetworkOperation *op, UIImage *image, BOOL cached) {
        _isLoadingImage = NO;
        if (op) [weakSelf.pendingOperations removeObject:op];
        if (!weakSelf.delegate) NSLog(@"WARNING: Item without delegate (image): %@", weakSelf.itemID);

        if (error) {
            NSLog(@"[%@] Error Loading Image: %@", weakSelf.itemID, error);
            if (weakSelf.delegate) [weakSelf.delegate itemImageFailedToLoad:weakSelf];
            return;
        }
        
        if (weakSelf.delegate && image) [weakSelf.delegate item:weakSelf imageLoaded:image local:cached];
        if (weakSelf.delegate && !image) [weakSelf.delegate itemImageFailedToLoad:weakSelf];
    }];
    
    if (op) [self.pendingOperations addObject:op];
    
    // A placeholder image could be returned here
    return nil;
}

- (UIImage *)avatarImage
{
    if (!self.avatarURL || _isLoadingAvatar) return nil;
    _isLoadingAvatar = YES;

    __weak ORSFItem *weakSelf = self;
    
    MKNetworkOperation *op = [[ORCachedEngine sharedInstance] imageAtURL:self.avatarURL size:AVATAR_SIZE completion:^(NSError *error, MKNetworkOperation *op, UIImage *image, BOOL cached) {
        _isLoadingAvatar = NO;
        if (op) [weakSelf.pendingOperations removeObject:op];
        if (!weakSelf.delegate) NSLog(@"WARNING: Item without delegate (avatar): %@", weakSelf.itemID);
        
        if (error) {
            NSLog(@"[%@] Error Loading Avatar: %@", weakSelf.itemID, error);
            return;
        }
        
        [weakSelf.delegate item:weakSelf avatarLoaded:image local:cached];
    }];
    
    if (op) [self.pendingOperations addObject:op];
    
    // A placeholder avatar could be returned here
    return nil;
}

- (void)searchForImages
{
    _alreadySearchedForImages = YES;
    NSLog(@"[%@] Querying Images: %@", self.itemID, self.title);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) [self.delegate itemImageIsLoading:self];
    });
    
    [[ORApiEngine sharedInstance] imageQuery:self.title page:0 count:50 maturityLevel:1 cb:^(NSError *error, NSArray *orImages) {
        if (!self.delegate) NSLog(@"WARNING: Item without delegate (search): %@", self.itemID);
        
        if (error) {
            NSLog(@"[%@] Error Querying Images: %@", self.itemID, error);

            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate) [self.delegate itemImageFailedToLoad:self];
            });

            return;
        }
        
        if (orImages.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.otherURLs = [NSMutableArray arrayWithCapacity:orImages.count];
                for (ORImage *obj in orImages) {
                    [self.otherURLs addObject:[ORURL URLWithORImage:obj]];
                }
                
                [self parseOtherURLsForImages:NO];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate) [self.delegate itemImageFailedToLoad:self];
            });
        }
    }];
}

- (void)fallbackToPlaceholderImage
{
    if (self.type == SFItemTypeNYTArticle) {
        if ([[UIScreen mainScreen] scale] > 1.0f) {
            self.imageURL = [NSURL URLWithString:@"http://s3.amazonaws.com/portl-static/nyt-sf-placeholder-400x300@2x.png"];
        } else {
            self.imageURL = [NSURL URLWithString:@"http://s3.amazonaws.com/portl-static/nyt-sf-placeholder-400x300.png"];
        }

        UIImage *image = self.mainImage;
        if (image && self.delegate) [self.delegate item:self imageLoaded:image local:YES];
    }
}

- (void)parseOtherURLsForImages:(BOOL)resolve
{
    if (!self.otherURLs || self.otherURLs.count <= 0 || self.imageURL || !self.delegate) {
        _isResolvingURLs = NO;
        
        if (!self.imageURL && self.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fallbackToPlaceholderImage];
            });
        }
        
        return;
    }

    ORURL *url = [self.otherURLs objectAtIndex:0];
    [self.otherURLs removeObjectAtIndex:0];
    
    if (resolve) {
        _isResolvingURLs = YES;
        
        MKNetworkOperation *op = [[ORURLResolver sharedInstance] resolveORURL:url completion:^(NSError *error, ORURL *finalURL) {
            if (!self.delegate) NSLog(@"WARNING: Item without delegate (resolve): %@", self.itemID);
            
            if (error) {
                NSLog(@"[%@] Couldn't resolve URL: %@", self.itemID, error);
                [self cancelPendingOperations];
                [self parseOtherURLsForImages:resolve];
                return;
            }
            
            if (finalURL.resolveOperation) {
                [self.pendingOperations removeObject:finalURL.resolveOperation];
                finalURL.resolveOperation = nil;
            }
            
            if (finalURL.imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _isResolvingURLs = NO;
                    
                    self.otherURLs = nil;
                    self.imageURL = finalURL.imageURL;
                    self.detailURL = finalURL;
                    
                    if (self.delegate) {
                        [self.delegate itemDetailURLResolved:self];
                        
                        UIImage *image = self.mainImage;
                        if (image) [self.delegate item:self imageLoaded:image local:YES];
                    }
                });
            } else {
                if (!self.otherURLs || self.otherURLs.count <= 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _isResolvingURLs = NO;
                        self.detailURL = finalURL;
                        if (self.delegate) [self.delegate itemDetailURLResolved:self];
                        
                        [self fallbackToPlaceholderImage];
                    });
                } else {
                    [self parseOtherURLsForImages:resolve];
                }
            }
        }];
        
        if (op) [self.pendingOperations addObject:op];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isResolvingURLs = NO;
            
            self.otherURLs = nil;
            self.imageURL = url.imageURL;
            
            if (self.delegate) {
                UIImage *image = self.mainImage;
                if (image) [self.delegate item:self imageLoaded:image local:YES];
            }
        });
    }
}

- (void)setDetailURL:(ORURL *)detailURL resolve:(BOOL)resolve
{
    self.detailURL = detailURL;
    
    if (resolve) {
        MKNetworkOperation *op = [[ORURLResolver sharedInstance] resolveORURL:self.detailURL completion:^(NSError *error, ORURL *finalURL) {
            if (!self.delegate) NSLog(@"WARNING: Item without delegate (resolve_detail): %@", self.itemID);
            
            self.detailURL.isResolving = NO;
            
            if (error) {
                NSLog(@"[%@] Couldn't resolve URL: %@", self.itemID, error);
                [self cancelPendingOperations];
                if ([self.delegate respondsToSelector:@selector(itemDetailURLFailedToResolve:)]) {
                    [self.delegate itemDetailURLFailedToResolve:self];
                }
                return;
            }
            
            if (finalURL.resolveOperation) {
                [self.pendingOperations removeObject:finalURL.resolveOperation];
                finalURL.resolveOperation = nil;
            }
            
            self.detailURL = finalURL;
            if (self.delegate) [self.delegate itemDetailURLResolved:self];
        }];
        
        if (op) [self.pendingOperations addObject:op];
    }
}

- (void)cancelPendingOperations
{
    for (MKNetworkOperation *op in self.pendingOperations) {
        [op cancel];
    }

    self.pendingOperations = [NSMutableArray array];

    _isLoadingImage = NO;
    _isLoadingAvatar = NO;
    _isResolvingURLs = NO;
}

- (NSUInteger)hash
{
    return [self.itemID hash];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (!self.itemID) return NO;
    if (![object isKindOfClass:[self class]]) return NO;
    
    return [self.itemID isEqual:[object itemID]];
}

- (void)setRawScores
{
	NSLog(@"remember to override this");
}

- (void)weightAndBlendSubscores
{
	if (LOG_SCORING) NSLog(@"\n ***** \n SCORING: WEIGHT & BLEND SUBSCORES FOR %@ \n *****", self.title);

	self.weightedSubscores = [NSMutableDictionary dictionaryWithCapacity:self.rawSubscores.count];
	
	float normScore, weighting, weightedScore;
	
	for (NSString *key in self.rawSubscores) {

		normScore = ((NSNumber*)[self.normalizedSubscores objectForKey:key]).floatValue;
		weighting = ((NSNumber*)[self.subscoreWeights objectForKey:key]).floatValue;
		weightedScore = normScore * weighting;
		[self.weightedSubscores setObject:[NSNumber numberWithFloat:weightedScore] forKey:key];
		if (LOG_SCORING) NSLog(@"%@ Normalized = %f", key, normScore);
		if (LOG_SCORING) NSLog(@"%@ Weighting = %f", key, weighting);
		if (LOG_SCORING) NSLog(@"%@ Weighted = %f", key, weightedScore);
		if (LOG_SCORING) NSLog(@"");

	}
	
	// Now calc the blended weighted score
	float aggregateWeightedScore = 0;
	
	for (NSString *key in self.weightedSubscores)
		aggregateWeightedScore += ((NSNumber*)[self.weightedSubscores objectForKey:key]).floatValue;
	
	self.scoreBlendedWeighted = aggregateWeightedScore / self.weightedSubscores.count;
	
	if (LOG_SCORING) NSLog(@" ***");
	if (LOG_SCORING) NSLog(@" ***");
	if (LOG_SCORING) NSLog(@" BLENDED-WEIGHTED-NORMALIZED (aka final) SCORE for %@ = %f", self.title, self.scoreBlendedWeighted);
	if (LOG_SCORING) NSLog(@" ***");
	if (LOG_SCORING) NSLog(@" ***");
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeInt:self.type forKey:@"type"];
    [c encodeBool:self.toggled forKey:@"toggled"];
    [c encodeObject:self.itemID forKey:@"itemID"];
    [c encodeObject:self.title forKey:@"title"];
    [c encodeObject:self.content forKey:@"content"];
    [c encodeObject:self.provider forKey:@"provider"];
    [c encodeObject:self.detailURL forKey:@"detailURL"];
    [c encodeObject:self.imageURL forKey:@"imageURL"];
    [c encodeObject:self.avatarURL forKey:@"avatarURL"];
    [c encodeObject:self.otherURLs forKey:@"otherURLs"];
    [c encodeBool:self.inserted forKey:@"inserted"];
    [c encodeBool:self.removed forKey:@"removed"];
    [c encodeBool:self.taken forKey:@"taken"];
    [c encodeDouble:self.scoreBlendedWeighted forKey:@"scoreBlendedWeighted"];
    [c encodeDouble:self.scoreBlendedNormalized forKey:@"scoreBlendedNormalized"];
    [c encodeObject:self.rawSubscores forKey:@"rawSubscores"];
    [c encodeObject:self.normalizedSubscores forKey:@"normalizedSubscores"];
    [c encodeObject:self.weightedSubscores forKey:@"weightedSubscores"];
    [c encodeObject:self.subscoreWeights forKey:@"subscoreWeights"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.type = [d decodeIntForKey:@"type"];
    self.toggled = [d decodeBoolForKey:@"toggled"];
    self.itemID = [d decodeObjectForKey:@"itemID"];
    self.title = [d decodeObjectForKey:@"title"];
    self.content = [d decodeObjectForKey:@"content"];
    self.provider = [d decodeObjectForKey:@"provider"];
    self.detailURL = [d decodeObjectForKey:@"detailURL"];
    self.imageURL = [d decodeObjectForKey:@"imageURL"];
    self.avatarURL = [d decodeObjectForKey:@"avatarURL"];
    self.otherURLs = [d decodeObjectForKey:@"otherURLs"];
    self.inserted = [d decodeBoolForKey:@"inserted"];
    self.removed = [d decodeBoolForKey:@"removed"];
    self.taken = [d decodeBoolForKey:@"taken"];
    self.scoreBlendedWeighted = [d decodeDoubleForKey:@"scoreBlendedWeighted"];
    self.scoreBlendedNormalized = [d decodeDoubleForKey:@"scoreBlendedNormalized"];
    self.rawSubscores = [d decodeObjectForKey:@"rawSubscores"];
    self.normalizedSubscores = [d decodeObjectForKey:@"normalizedSubscores"];
    self.weightedSubscores = [d decodeObjectForKey:@"weightedSubscores"];
    self.subscoreWeights = [d decodeObjectForKey:@"subscoreWeights"];

    self.pendingOperations = [NSMutableArray array];
    self.parentEntity = nil;
    self.delegate = nil;
    
    return self;
}

- (void)pinnedBoardsWithCompletion:(void (^)(ORSFItem *item))completion
{
    if (self.loadedBoards) {
        if (completion) completion(self);
        return;
    }
    
    self.loadedBoards = YES;
    [[ORApiEngine sharedInstance] boardsForItem:self.itemID cb:^(NSError *error, NSArray *result) {
        if (error) NSLog(@"Error: %@", error);
        
        NSString *defaultBoardId = [ORApiEngine sharedInstance].defaultBoardId;
        
        self.favorited = NO;
        self.boards = [NSMutableSet setWithArray:result];
        
        for (NSString *boardId in self.boards) {
            if ([boardId isEqualToString:defaultBoardId]) self.favorited = YES;
        }
        
        if (self.favorited) [self.boards removeObject:defaultBoardId];
        self.pinned = (self.boards.count > 0);
        
        if (completion) completion(self);
    }];
}

- (void)addBoard:(NSString *)boardId
{
    if (!self.boards) self.boards = [NSMutableSet setWithCapacity:1];
    [self.boards addObject:boardId];
    self.pinned = YES;
}

- (void)removeBoard:(NSString *)boardId
{
    [self.boards removeObject:boardId];
    self.pinned = (self.boards.count > 0);
}

@end

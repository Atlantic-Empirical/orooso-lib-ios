//
//  ORSFYouTubeProvider.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 19/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderVideos.h"
#import "ORYouTubeEngine.h"
#import "ORYouTubeVideo.h"
#import "OREntity.h"
#import "ORSFVideo.h"

#define ITEM_COUNT 50
#define SCORE_CUTOFF -0.5f

@interface ORSFProviderVideos()

@property (atomic, strong) NSMutableArray *cachedQueries;
@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, strong) NSMutableDictionary *operations;
@property (atomic, copy) ORSFProviderIntBlock fetchCompletion;
@property (atomic, strong) NSError *lastError;
@property (atomic, assign) NSUInteger itemsAdded;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderVideos

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.page = 0;
    }
    
    return self;
}

- (NSArray *)searchQueries
{
    // If already built, return it
    if (self.cachedQueries && !self.secondTry) return self.cachedQueries;
    
    // Format Strings
    NSString *format = (self.secondTry) ? @"%@" : @"\"%@\"";
    NSString *exclusionFormat = @"-\"%@\"";
    
    // Build entity queries array
    NSMutableArray *queries = [NSMutableArray arrayWithCapacity:4];
    
    // Entity Name
    [queries addObject:[NSString stringWithFormat:format, self.entity.name]];
    
    // Hashtags
    for (NSString *obj in self.entity.hashtags) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [queries addObject:[NSString stringWithFormat:format, keyword]];
    }
    
    // Keywords
    for (NSString *obj in self.entity.keywords) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [queries addObject:[NSString stringWithFormat:format, keyword]];
    }
    
//    // Associated People
//    for (NSString *obj in self.entity.associatedPeople) {
//        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if (keyword && ![keyword isEqualToString:@""]) [self.cachedQueries addObject:[NSString stringWithFormat:@"\"%@\"", keyword]];
//    }
    
    NSMutableArray *exclusions = [NSMutableArray arrayWithCapacity:self.entity.exclusionStrings.count];

    for (NSString *obj in self.entity.exclusionStrings) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [exclusions addObject:[NSString stringWithFormat:exclusionFormat, keyword]];
    }
    
    NSString *exclusionString = [exclusions componentsJoinedByString:@" "];
    
    self.cachedQueries = [NSMutableArray arrayWithCapacity:queries.count];

    // Add exclusion strings to individual queries
    for (NSString *query in queries) {
        NSString *fullQuery = [NSString stringWithFormat:@"%@ %@", query, exclusionString];
        fullQuery = [fullQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.cachedQueries addObject:fullQuery];
    }
    
    if (!self.secondTry) {
        NSString *compoundQuery = [NSString stringWithFormat:@"%@ %@", [queries componentsJoinedByString:@"|"], exclusionString];
        return @[compoundQuery];
    } else {
        return self.cachedQueries;
    }
}

- (void)reset
{
    [super reset];
    
    self.page = 0;
    self.cachedQueries = nil;
    self.fetchCompletion = nil;
    self.lastError = nil;
}

- (void)stop
{
    [super stop];
    
    for (NSString *key in self.operations) {
        MKNetworkOperation *op = [self.operations objectForKey:key];
        [op cancel];
    }
    
    self.operations = nil;
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (!self.entity) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching YouTube videos...");
    
    ORYouTubeEngine *engine = [ORYouTubeEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();

    BOOL firstTime = (self.cachedQueries == nil);
    NSArray *queries = [self searchQueries];
    
    self.fetchCompletion = completion;
    self.operations = [NSMutableDictionary dictionaryWithCapacity:[queries count]];
    self.lastError = nil;
    self.itemsAdded = 0;
    
    for (NSString *query in queries) {
        MKNetworkOperation *op = [engine fetchVideosForString:query page:self.page count:ITEM_COUNT maturityLevel:self.maturityLevel cb:^(NSError *error, NSArray *items) {
            dispatch_async(queue, ^{
                [self.operations removeObjectForKey:query];
                
                if (error) {
                    self.lastError = error;
                } else {
                    // Create the item set, if needed
                    if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:items.count];
                    
                    NSUInteger added = 0;
                    
                    for (ORYouTubeVideo *item in items) {
                        ORSFVideo *video = [[ORSFVideo alloc] initWithYouTubeVideo:item andEntity:self.entity];
                        
                        // Only add item if it's not already in the set
                        if (![self.items containsObject:video]) {
                            video.taken = NO;
                            //[video setRawScores];
                            [self.items addObject:video];
                            self.itemsAvailable++;
                            added++;
                        }
                    }
                    
                    // New items? Sort the item set
                    if (added > 0) {
                        //[self normalizeSubscores];
                        //[self normalizeBlendedScoresToFinalScore:SCORE_CUTOFF];
                        //[self sortItems];
                        self.itemsAdded += added;
                    }
                }
                
                if (!self.operations || [self.operations count] == 0) {
                    if (self.fetchCompletion) {
                        self.fetchCompletion(self.lastError, self.itemsAdded);
                        self.fetchCompletion = nil;
                        if (!firstTime || [self.cachedQueries count] == 1) self.page++;
                    }
                    
                    self.operations = nil;
                    self.lastError = nil;
                }
            });
        }];
        
        [self.operations setObject:op forKey:query];
    }
}

@end

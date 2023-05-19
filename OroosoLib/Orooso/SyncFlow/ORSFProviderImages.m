//
//  ORSFProviderImages.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 22/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderImages.h"
#import "ORApiEngine.h"
#import "ORSFImage.h"

#define ITEM_COUNT 50
#define SCORE_CUTOFF -100.0f

@interface ORSFProviderImages ()

@property (atomic, strong) NSMutableArray *cachedQueries;
@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, strong) NSMutableDictionary *operations;
@property (atomic, copy) ORSFProviderIntBlock fetchCompletion;
@property (atomic, strong) NSError *lastError;
@property (atomic, assign) NSUInteger itemsAdded;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderImages

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
    NSString *format = (self.secondTry) ? @"%@ %@" : @"\"%@\" %@";
    NSString *exclusionFormat = @"-\"%@\"";

    // Build the exclusion array
    NSMutableArray *exclusions = [NSMutableArray arrayWithCapacity:self.entity.exclusionStrings.count];
    
    for (NSString *obj in self.entity.exclusionStrings) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [exclusions addObject:[NSString stringWithFormat:exclusionFormat, keyword]];
    }
    
    NSString *exclusionString = [exclusions componentsJoinedByString:@" "];
    
    // Build entity queries array
    self.cachedQueries = [NSMutableArray arrayWithCapacity:4];
    
    // Entity Name
    NSString *name = [self.entity.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    name = [NSString stringWithFormat:format, name, exclusionString];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.cachedQueries addObject:name];
    
    // Hashtags
    for (NSString *obj in self.entity.hashtags) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) {
            keyword = [NSString stringWithFormat:format, keyword, exclusionString];
            keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.cachedQueries addObject:keyword];
        }
    }
    
    // Keywords
    for (NSString *obj in self.entity.keywords) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) {
            keyword = [NSString stringWithFormat:format, keyword, exclusionString];
            keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.cachedQueries addObject:keyword];
        }
    }
    
//    // Associated People
//    for (NSString *obj in self.entity.associatedPeople) {
//        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if (keyword && ![keyword isEqualToString:@""]) [self.cachedQueries addObject:[NSString stringWithFormat:@"\"%@\"", keyword]];
//    }
    
    return self.cachedQueries;
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

    NSLog(@"Fetching Bing images...");
    
    ORApiEngine *engine = [ORApiEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    NSArray *queries = [self searchQueries];
    
    self.fetchCompletion = completion;
    self.operations = [NSMutableDictionary dictionaryWithCapacity:[queries count]];
    self.lastError = nil;
    self.itemsAdded = 0;
    
    for (NSString *query in queries) {
        MKNetworkOperation *op = [engine imageQuery:query page:self.page count:ITEM_COUNT maturityLevel:self.maturityLevel cb:^(NSError *error, NSArray *items) {
            dispatch_async(queue, ^{
                [self.operations removeObjectForKey:query];
                
                if (error) {
                    self.lastError = error;
                } else {
                    // Create the item set, if needed
                    if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:items.count];
                    
                    NSUInteger added = 0;
                    
                    for (ORImage *item in items) {
                        ORSFImage *image = [[ORSFImage alloc] initWithImage:item andEntity:self.entity];
                        
                        // Only add item if it's not already in the set
                        if (![self.items containsObject:image]) {
                            image.taken = NO;
                            [image setRawScores];
                            [self.items addObject:image];
                            self.itemsAvailable++;
                            added++;
                        }
                    }
                    
                    // New items? Sort the item set
                    if (added > 0) {
                        [self normalizeSubscores];
                        [self normalizeBlendedScoresToFinalScore:SCORE_CUTOFF];
                        [self sortItems];
                        self.itemsAdded += added;
                    }
                }
                
                if (!self.operations || [self.operations count] == 0) {
                    if (self.fetchCompletion) {
                        self.fetchCompletion(self.lastError, self.itemsAdded);
                        self.fetchCompletion = nil;
                        self.page++;
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

//
//  ORSFProviderTwitter.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 23/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderTwitter.h"
#import "ORTwitterEngine.h"
#import "ORSFTweet.h"
#import "ORTweet.h"
#import "ORTwitterHashtag.h"
#import "ORTwitterUser.h"
#import "ORLanguageIdentifier.h"
#import "OREntity.h"

#define ITEM_COUNT 100
#define SCORE_CUTOFF -1.0f

@interface ORSFProviderTwitter () <ORTwitterEngineDelegate>

@property (atomic, strong) ORTwitterEngine *engine;
@property (atomic, strong) NSString *cachedQuery;
@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) dispatch_queue_t queue;

@property (atomic, assign) u_int64_t twitterNewestID;
@property (atomic, assign) u_int64_t twitterOldestID;
@property (atomic, strong) NSDate *lastRequest;

@end

@implementation ORSFProviderTwitter

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.queue = nil;
        self.minimumThreshold = 5;
        self.engine = [ORTwitterEngine sharedInstance];
        self.lastRequest = nil;
    }
    
    return self;
}

- (NSString *)searchQuery
{
    // If already built, return it
    if (self.cachedQuery && !self.secondTry) return self.cachedQuery;
    
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
    
    NSMutableArray *exclusions = [NSMutableArray arrayWithCapacity:self.entity.exclusionStrings.count];
    for (NSString *obj in self.entity.exclusionStrings) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [exclusions addObject:[NSString stringWithFormat:exclusionFormat, keyword]];
    }
    
    NSString *fullQuery = [NSString stringWithFormat:@"%@ %@", [queries componentsJoinedByString:@" OR "], [exclusions componentsJoinedByString:@" "]];
    self.cachedQuery = [fullQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return self.cachedQuery;
}

- (void)reset
{
    [super reset];
    
    self.cachedQuery = nil;
    self.lastRequest = nil;
    self.twitterNewestID = NSNotFound;
    self.twitterOldestID = NSNotFound;
}

- (void)stop
{
    [super stop];
    
    // Stop Streaming (if currently running)
    [self stopStreaming];
}

- (void)start
{
    // Provider runs in the queue it's called from
    self.queue = dispatch_get_current_queue();

    [super start];
    
    // Start streaming only if we have an entity
    if (self.entity && self.entity.isOnline) [self startStreaming];
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (!self.entity || !self.engine.isAuthenticated) {
        if (completion) completion(nil, 0);
        return;
    }
    
    if (self.lastRequest) {
        if ([[NSDate date] timeIntervalSinceDate:self.lastRequest] < 10) {
            NSLog(@"Less than 10 seconds before last Twitter request, aborting...");
            if (completion) completion(nil, -1);
            return;
        }
    }

    NSLog(@"Fetching Twitter items...");
    
    if (!self.queue) self.queue = dispatch_get_current_queue();
    self.engine.delegate = self;

    self.lastRequest = [NSDate date];
    self.op = [self.engine searchTweets:[self searchQuery] count:ITEM_COUNT maxID:self.twitterOldestID sinceID:NSNotFound completion:^(NSError *error, NSArray *items) {
        dispatch_async(self.queue, ^{
            self.op = nil;
            
            if (error) {
                if (completion) completion(error, 0);
                return;
            }
            
            // Create the item set, if needed
            if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:items.count];
            
            NSUInteger added = 0;
            
            for (ORTweet *item in items) {
                // Update the pointers to the max and min tweet IDs
                self.twitterNewestID = (self.twitterNewestID == NSNotFound) ? item.tweetID : MAX(self.twitterNewestID, item.tweetID);
                self.twitterOldestID = (self.twitterOldestID == NSNotFound) ? item.tweetID : MIN(self.twitterOldestID, item.tweetID);

                // Discard sensitive tweets if maturity level is higher than 0
                if (self.maturityLevel > 0 && item.possiblySensitive) continue;
                
                // Validate the Tweet first
                if (![self.engine validateTweet:item]) continue;
                
                ORSFTweet *tweet = [[ORSFTweet alloc] initWithTweet:item andEntity:self.entity];
                
                // Only add item if it's not already in the set
                if (![self.items containsObject:tweet]) {
					tweet.taken = NO;
                    [self.items addObject:tweet];
                    self.itemsAvailable++;
                    added++;
                }
            }
            
            // New items? Sort the item set
            if (added == 0) {
                // Reset lastRequest before the second try
                if (!self.secondTry) self.lastRequest = nil;
            }
            
            // Return to caller
            if (completion) completion(nil, added);
        });
    }];
}

- (void)startStreaming
{
    if (!self.engine.isAuthenticated) return;
    self.engine.delegate = self;
    
    // Stop streaming first
    if (self.engine.isStreaming) [self.engine stopStreaming];
    
    NSMutableArray *hashtags = [NSMutableArray arrayWithCapacity:self.entity.hashtags.count];
    NSMutableArray *userNames = [NSMutableArray arrayWithCapacity:self.entity.twitterAccounts.count];

    // Hashtags
    for (NSString *obj in self.entity.hashtags) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [hashtags addObject:keyword];
    }

    // Twitter Accounts
    for (NSString *obj in self.entity.twitterAccounts) {
        NSString *keyword = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (keyword && ![keyword isEqualToString:@""]) [userNames addObject:keyword];
    }
    
    if ([hashtags count] == 0 && [userNames count] == 0) return;
    NSString *query = [hashtags componentsJoinedByString:@","];
    if (!self.queue) self.queue = dispatch_get_current_queue();
    
    if ([userNames count] > 0) {
        [self.engine fetchUserProfilesForScreenNames:userNames completion:^(NSError *error, NSArray *users) {
            dispatch_async(self.queue, ^{
                NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:users.count];
                
                for (ORTwitterUser *obj in users) {
                    [userIds addObject:[NSString stringWithFormat:@"%lld", obj.userID]];
                }
                
                NSString *users = [userIds componentsJoinedByString:@","];
            
                [self.engine startStreamingStatuses:query andAccountIds:users completion:^(NSError *error) {
                    if (error) {
                        NSLog(@"Streaming stopped (or failed to start). Error: %@", error);
                    } else {
                        NSLog(@"Streaming finished.");
                    }
                }];
            });
        }];
    } else {
        [self.engine startStreamingStatuses:query andAccountIds:nil completion:^(NSError *error) {
            if (error) {
                NSLog(@"Streaming stopped (or failed to start). Error: %@", error);
            } else {
                NSLog(@"Streaming finished.");
            }
        }];
    }
}

- (void)stopStreaming
{
    self.engine.delegate = self;
    if (self.engine.isStreaming) [self.engine stopStreaming];
}

#pragma mark - ORTwitterEngine Delegate

- (void)twitterEngine:(ORTwitterEngine *)engine statusUpdate:(NSString *)message
{
	NSLog(@"%@", message);
}

- (void)twitterEngine:(ORTwitterEngine *)engine needsToOpenURL:(NSURL *)url
{
	NSLog(@"%@", [url absoluteString]);
}

- (void)twitterEngine:(ORTwitterEngine *)engine newTweet:(ORTweet *)tweet
{
    __weak ORSFProviderTwitter *weakSelf = self;
    
    dispatch_async(self.queue, ^{
        if (!tweet) return;
        if (!weakSelf.engine) return;
        
        NSLog(@"New tweet arrived");
        
        // Discard sensitive tweets if maturity level is higher than 0
        if (weakSelf.maturityLevel > 0 && tweet.possiblySensitive) return;
        
        // Validate tweet first
		if (![weakSelf.engine validateTweet:tweet]) return;
        
        // TWEET ACCEPTED, CONTINUE
        ORSFTweet *tweetItem = [[ORSFTweet alloc] initWithTweet:tweet andEntity:weakSelf.entity];

        // Only add item if it's not already in the set
        if (![weakSelf.items containsObject:tweetItem]) {
            tweetItem.taken = NO;
            tweetItem.fromStreaming = YES;
            
            NSUInteger idx = 0;
            BOOL foundOneFromSearch = NO;
            
            for (ORSFTweet *item in weakSelf.items) {
                if (!item.taken && !item.fromStreaming) {
                    if (foundOneFromSearch) break;
                    foundOneFromSearch = YES;
                } else {
                    foundOneFromSearch = NO;
                }
                
                idx++;
            }
            
            if (idx < weakSelf.items.count) {
                [weakSelf.items insertObject:tweetItem atIndex:idx];
            } else {
                [weakSelf.items addObject:tweetItem];
            }
            
            weakSelf.itemsAvailable++;
        }
	});
}

@end

//
//  ORSFProviderTwitterNews.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 03/05/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderTwitterNews.h"
#import "ORTwitterEngine.h"
#import "ORSFTwitterURL.h"
#import "ORTweet.h"

#define CACHE_LIMIT_SECONDS 75 // 75 seconds

@interface ORSFProviderTwitterNews ()

@property (atomic, assign) BOOL isWorking;
@property (atomic, strong) ORTwitterEngine *engine;
@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) dispatch_queue_t queue;

@property (atomic, strong) NSTimer* tmrTwitter;
@property (atomic, assign) u_int64_t twitterNewestID;
@property (atomic, assign) u_int64_t twitterOldestID;

@property (atomic, copy) NSString *cacheFile;
@property (atomic, strong) NSDate *lastUpdate;

@end

@implementation ORSFProviderTwitterNews

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.queue = nil;
        self.minimumThreshold = 5;
        self.engine = [ORTwitterEngine sharedInstance];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = paths[0];
        self.cacheFile = [cachesDirectory stringByAppendingPathComponent:@"TwitterNews.dat"];
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    
    self.twitterNewestID = NSNotFound;
    self.twitterOldestID = NSNotFound;

    [self loadCacheFile];
}

- (void)stop
{
    [super stop];
    
    if (self.tmrTwitter) {
        if (![NSThread isMainThread]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tmrTwitter invalidate];
                self.tmrTwitter = nil;
            });
        } else {
            [self.tmrTwitter invalidate];
            self.tmrTwitter = nil;
        }
    }
}

- (void)start
{
    // Provider runs in the queue it's called from
    self.queue = dispatch_get_current_queue();
    
    [self stop];
    
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.tmrTwitter = [NSTimer scheduledTimerWithTimeInterval:75.0f
                                                               target:self
                                                             selector:@selector(fetchNewTweets)
                                                             userInfo:nil
                                                              repeats:YES];

            dispatch_async(self.queue, ^{
                if (self.itemsAvailable == 0 || !self.lastUpdate || [[NSDate date] timeIntervalSinceDate:self.lastUpdate] > CACHE_LIMIT_SECONDS) {
                    [self fetchNewTweets];
                } else {
                    if (self.newItemsBlock) self.newItemsBlock(nil, self.itemsAvailable);
                }
            });
        });
    } else {
        self.tmrTwitter = [NSTimer scheduledTimerWithTimeInterval:75.0f
                                                           target:self
                                                         selector:@selector(fetchNewTweets)
                                                         userInfo:nil
                                                          repeats:YES];

        dispatch_async(self.queue, ^{
            if (self.itemsAvailable == 0 || !self.lastUpdate || [[NSDate date] timeIntervalSinceDate:self.lastUpdate] > CACHE_LIMIT_SECONDS) {
                [self fetchNewTweets];
            } else {
                    if (self.newItemsBlock) self.newItemsBlock(nil, self.itemsAvailable);
            }
        });
    }
}

- (void)fetchMoreItems
{
    // Does nothing here, since this provider fetches using a timer
}

- (void)fetchNewTweets
{
    if (self.isWorking) return;
    
    dispatch_async(self.queue, ^{
        if (self.isWorking) return;
        self.isWorking = YES;
        
        if (self.twitterOldestID != NSNotFound) {
            NSLog(@"Loading Twitter news until ID %lli", self.twitterOldestID);
        } else {
            NSLog(@"Loading Twitter news");
        }
        
        self.engine.delegate = nil;
        self.lastUpdate = [NSDate date];
        
        self.op = [self.engine homeTimeline:200 maxID:self.twitterOldestID sinceID:NSNotFound completion:^(NSError *error, NSArray *tweets) {
            dispatch_async(self.queue, ^{
                self.op = nil;
                
                if (error) {
                    self.isWorking = NO;
                    if (self.newItemsBlock) self.newItemsBlock(error, 0);
                }
                
                // Create the item set, if needed
                if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:tweets.count];
                
                NSUInteger added = 0;
                BOOL changed = NO;
                
                for (ORTweet *item in tweets) {
                    // Update the pointers to the max and min tweet IDs
                    self.twitterNewestID = (self.twitterNewestID == NSNotFound) ? item.tweetID : MAX(self.twitterNewestID, item.tweetID);
                    self.twitterOldestID = (self.twitterOldestID == NSNotFound) ? item.tweetID : MIN(self.twitterOldestID, item.tweetID);
                    
                    // Discard tweets without URLs
                    if (item.urls.count <= 0) continue;

                    // Discard sensitive tweets if maturity level is higher than 0
                    if (self.maturityLevel > 0 && item.possiblySensitive) continue;
                    
                    ORSFTwitterURL *tweet = [[ORSFTwitterURL alloc] initWithTweet:item andEntity:self.entity];

                    NSUInteger idx = [self.items indexOfObject:tweet];

                    if (idx != NSNotFound) {
                        // Existing item? Add the RT count
                        tweet = [self.items objectAtIndex:idx];
                        [tweet addTweet:item];
                        [tweet setRawScores];
                        changed = YES;
                    } else {
                        // New item? Add to the set
                        tweet.taken = NO;
                        [tweet setRawScores];
                        [self.items addObject:tweet];
                        self.itemsAvailable++;
                        added++;
                    }
                }
                
                // New items? Sort the item set
                if (added > 0 || changed) {
                    [self sortItems];
                }
                
                [self storeCacheFile];
                
                self.isWorking = NO;
                if ((added > 0 || changed) && self.newItemsBlock) self.newItemsBlock(nil, added);
            });
        }];
    });
}

#pragma mark - Cache

- (void)storeCacheFile
{
    // Create the item set, if needed
    if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:1];
    
    NSDictionary *data = @{@"account": self.engine.screenName,
                           @"lastUpdate": self.lastUpdate,
                           @"items": self.items};
    
    [NSKeyedArchiver archiveRootObject:data toFile:self.cacheFile];
}

- (void)loadCacheFile
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFile]){
        NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithFile:self.cacheFile];
        
        if (data && [self.engine.screenName isEqualToString:data[@"account"]]) {
            self.lastUpdate = data[@"lastUpdate"];
            self.items = [data[@"items"] mutableCopy];
            
            for (ORSFTwitterURL *item in self.items) {
                item.taken = NO;
                item.parentEntity = self.entity;
                self.itemsAvailable++;
            }
        }
    }
}

@end

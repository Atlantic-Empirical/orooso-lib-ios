//
//  ORSFProvider.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 19/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProvider.h"
#import "MKNetworkOperation.h"
#import "OREntity.h"
#import "ORSFItem.h"

#define LOG_SCORING NO

@interface ORSFProvider()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, strong) NSMutableOrderedSet *featuredItems;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, assign) NSUInteger featuredItemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) BOOL isWorking;
@property (atomic, assign) BOOL isStalled;
@property (atomic, assign) BOOL secondTry;

@end

@implementation ORSFProvider

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super init];
    
    if (self) {
        self.itemsAvailable = 0;
        self.featuredItemsAvailable = 0;
        self.isWorking = NO;
        self.isStalled = NO;
        self.secondTry = NO;
        self.frequency = frequency;
        self.currentCycle = self.frequency;
        self.minimumThreshold = 5;
    }
    
    return self;
}

- (void)reset
{
    [self stop];
    
    self.newItemsBlock = nil;
    self.isWorking = NO;
    self.isStalled = NO;
    self.secondTry = NO;
    self.items = nil;
    self.featuredItems = nil;
    self.itemsAvailable = 0;
    self.featuredItemsAvailable = 0;
}

- (void)stop
{
    if (self.op) [self.op cancel];
    self.op = nil;
}

- (void)start
{
    if (!self.isWorking && self.itemsAvailable < self.minimumThreshold && !self.isStalled) {
        [self fetchMoreItems];
    }
}

- (ORSFItem *)takeItemAndReloadIfNeeded:(BOOL)reload
{
    // Are we running out of items? Fetch more
    if (!self.isWorking && self.itemsAvailable <= self.minimumThreshold && !self.isStalled && reload) {
        [self fetchMoreItems];
    }
    
    // Take items from set and mark as such
    for (ORSFItem *item in self.items) {
        if (!item.taken) {
            item.taken = YES;
            self.itemsAvailable--;
            return item;
        }
    }
    
    return nil;
}

- (ORSFItem *)takeFeaturedItemAndReloadIfNeeded:(BOOL)reload
{
    // Take items from set and mark as such
    for (ORSFItem *item in self.featuredItems) {
        if (!item.taken) {
            item.taken = YES;
            self.featuredItemsAvailable--;
            return item;
        }
    }
    
    return nil;
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    // This method should be overriden by other classes
    if (completion) completion(nil, 0);
    return;
}

- (void)fetchMoreItems
{
    dispatch_async(self.sfeQueue, ^{
        self.isWorking = YES;
        
        [self fetchNewItemsWithCompletion:^(NSError *error, NSInteger added) {
            self.isWorking = NO;
            if (self.newItemsBlock) self.newItemsBlock(error, (added > 0) ? added : 0);
            
            // No items returned?
            if (!error && added >= 0 && added < self.minimumThreshold) {
                if (!self.secondTry) {
                    // Will try again
                    self.secondTry = YES;
                } else {
                    // Stalled, stop trying
                    self.isStalled = YES;
                    self.isWorking = NO;
                    NSLog(@"%@: Stalled", self);
                }
            }
        }];
    });
}

- (void)sortItems
{
    [self.items sortUsingComparator:^NSComparisonResult(ORSFItem *obj1, ORSFItem *obj2) {
        // 1. Already taken items should go first
        if (obj1.taken && !obj2.taken) {
            return NSOrderedAscending;
        } else if (!obj1.taken && obj2.taken) {
            return NSOrderedDescending;
        }

        // 2. Score (descending)
        if (obj1.scoreBlendedNormalized > obj2.scoreBlendedNormalized) {
            return NSOrderedAscending;
        } else if (obj1.scoreBlendedNormalized < obj2.scoreBlendedNormalized) {
            return NSOrderedDescending;
        }

        return NSOrderedSame;
    }];
}

- (void)normalizeSubscores
{
	if (LOG_SCORING) NSLog(@"\n ***** \n SCORING: NORMALIZE SUBSCORES \n *****");

	float tmpCount = self.items.count;
	NSNumber *tmpNum;

	// 0) Calc means
	if (LOG_SCORING) NSLog(@"Calculating Mean Scores");
	
	NSMutableDictionary *meanScores = [NSMutableDictionary dictionaryWithCapacity:10];

	// a) put all the scores of each type into their own array
	NSMutableArray *tmpArray;
	
	for (ORSFItem *itm in self.items) {

		for (NSString *key in itm.rawSubscores) {
		
			tmpArray = [meanScores objectForKey:key];
			if (!tmpArray) {
				tmpArray = [NSMutableArray array];
				[meanScores setObject:tmpArray forKey:key];
			}
			[tmpArray addObject:[itm.rawSubscores objectForKey:key]];

		}
	}
	
	// b) sort the arrays
	for (NSString *key in meanScores) {

		[[meanScores objectForKey:key] sortUsingComparator:^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
			if (num1.floatValue <= num2.floatValue)
				return NSOrderedAscending;
			else
				return NSOrderedDescending;
		}];

		if (LOG_SCORING) NSLog(@"Mean score array for: %@: %@", key, [((NSArray*)[meanScores objectForKey:key]) debugDescription]);

	}
	
	// c) get the middle value (mean) for each array & store this value in meanscores
	int tmpIndex;
	
	for (NSString *key in meanScores.allKeys) {

		tmpArray = [meanScores objectForKey:key];
		tmpIndex = ceil(tmpArray.count/2);
		if (LOG_SCORING) NSLog(@"Mean score middle index for %@ = %d", key, tmpIndex);
		tmpNum = [tmpArray objectAtIndex:tmpIndex];
		if (LOG_SCORING) NSLog(@"Mean score for %@ = %f", key, tmpNum.floatValue);
		[meanScores setObject:tmpNum forKey:key];
		if (LOG_SCORING) NSLog(@"\n ***");

	}
	
//	// 1) calc averages
//	NSMutableDictionary *averageScores = [NSMutableDictionary dictionaryWithCapacity:10];
//	float tmpAvg = 0;
//	
//	for (ORSFItem *itm in self.items) {
//
//		for (NSString *key in itm.rawSubscores) {
//		
//			tmpAvg = ((NSNumber*)[averageScores objectForKey:key]).floatValue;
//			tmpAvg += ((NSNumber*)[itm.rawSubscores objectForKey:key]).floatValue;
//			[averageScores setObject:[NSNumber numberWithFloat:tmpAvg] forKey:key];
//
//		}
//	}
//
//	for (NSString *key in averageScores.allKeys) {
//		
//		tmpAvg = ((NSNumber*)[averageScores objectForKey:key]).floatValue;
//		tmpAvg /= tmpCount;
//		[averageScores setObject:[NSNumber numberWithFloat:tmpAvg] forKey:key];
//
//	}
	
	// 2) calc standard deviation
	NSMutableDictionary *standardDeviations = [NSMutableDictionary dictionaryWithCapacity:self.items];
	float stdDev, rawScore, avgScore;

	for (ORSFItem *itm in self.items) {
	
		for (NSString *key in itm.rawSubscores) {
		
			rawScore = ((NSNumber*)[itm.rawSubscores objectForKey:key]).floatValue;
			avgScore = ((NSNumber*)[meanScores objectForKey:key]).floatValue;
//			avgScore = ((NSNumber*)[averageScores objectForKey:key]).floatValue;
			stdDev = ((NSNumber*)[standardDeviations objectForKey:key]).floatValue;
			stdDev += fabsf(rawScore - avgScore);
			[standardDeviations setObject:[NSNumber numberWithFloat:stdDev] forKey:key];

		}
	}

	for (NSString *key in standardDeviations.allKeys) {
	
		stdDev = ((NSNumber*)[standardDeviations objectForKey:key]).floatValue;
		stdDev /= tmpCount;
		[standardDeviations setObject:[NSNumber numberWithFloat:stdDev] forKey:key];
		if (LOG_SCORING) NSLog(@"Standard deviation for %@ = %f", key, stdDev);
		
	}
	
	// 3) set normalized score values
	NSMutableDictionary *normalizedSubscores = [NSMutableDictionary dictionaryWithCapacity:10];
	float scoreNorm;

	for (ORSFItem *itm in self.items) {

		if (LOG_SCORING) NSLog(@"\n ***\n Normalize Subscores for %@\n ***", itm.title);

		for (NSString *key in itm.rawSubscores) {
	
			rawScore = ((NSNumber*)[itm.rawSubscores objectForKey:key]).floatValue;
			avgScore = ((NSNumber*)[meanScores objectForKey:key]).floatValue;
//			avgScore = ((NSNumber*)[averageScores objectForKey:key]).floatValue;
			stdDev = ((NSNumber*)[standardDeviations objectForKey:key]).floatValue;
			scoreNorm = (rawScore - avgScore) / ((stdDev == 0) ? 1 : stdDev);
			[normalizedSubscores setObject:[NSNumber numberWithFloat:scoreNorm] forKey:key];
			if (!itm.normalizedSubscores) itm.normalizedSubscores = [NSMutableDictionary dictionaryWithCapacity:10];
			[itm.normalizedSubscores setObject:[NSNumber numberWithFloat:scoreNorm] forKey:key];
			if (LOG_SCORING) NSLog(@"Normalized subscore %@ = %f for %@", key, scoreNorm, itm.title);
			
		}
		
		// set weighted scores
		[itm weightAndBlendSubscores];
	}
	
}

- (void)normalizeBlendedScoresToFinalScore:(float)cutoff
{
	if (LOG_SCORING) NSLog(@"\n ***** \n SCORING: NORMALIZE BLENDED-WEIGHTED ITEM SCORES TO FINAL SCORE \n *****");

	float meanScore = 0;
	float sdScore = 0;
	
	// 0) Calc means
	if (LOG_SCORING) NSLog(@"Calculating Mean Scores");
		
	// a) put all the scores of each type into their own array
	NSMutableArray *scoresForMeaning = [NSMutableArray arrayWithCapacity:self.items.count];
	
	for (ORSFItem *itm in self.items)
		[scoresForMeaning addObject:[NSNumber numberWithFloat:itm.scoreBlendedWeighted]];
	
	// b) sort the array
	[scoresForMeaning sortUsingComparator:^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
		if (num1.floatValue <= num2.floatValue)
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}];
	if (LOG_SCORING) NSLog(@"Array for mean score calc:\n%@", scoresForMeaning.debugDescription);
		
	// c) get the middle value (mean) for each array & store this value in meanscores
	int tmpIndex;
	NSNumber *tmpNum;
	tmpIndex = ceil(scoresForMeaning.count/2);
	if (LOG_SCORING) NSLog(@"Mean score middle index = %d", tmpIndex);
	tmpNum = [scoresForMeaning objectAtIndex:tmpIndex];
	if (LOG_SCORING) NSLog(@"Mean score = %f", tmpNum.floatValue);
	if (LOG_SCORING) NSLog(@"");
	
//	// 1) calc averages
//#warning TPF: convert this to mean dammit	
//	
//	for (ORSFItem *item in self.items) {
//	
//		avgScore += item.scoreBlendedWeighted;
//		tmpCount++;
////		NSLog(@"Blended-Weighted score for %@ = %f", item.title, item.scoreBlendedWeighted);
//
//	}
//	avgScore /= tmpCount;
//	NSLog(@"\n ***\n AVERAGE (median) Blended-Weighted score = %f\n ***", avgScore);
	

	// 2) calc standard deviation

//	for (ORSFItem *item in self.items)
//		sdScore += fabsf(item.scoreBlendedWeighted - avgScore);
	for (ORSFItem *item in self.items)
		sdScore += fabsf(item.scoreBlendedWeighted - meanScore);
	
	sdScore /= scoresForMeaning.count;
	if (LOG_SCORING) NSLog(@"\n ***\n Standard Deviation of Blended-Weighted scores = %f\n ***", sdScore);
	
	
	// 3) set normalized score values & check for drop / cutoff
	NSMutableArray *itemsToDrop = [NSMutableArray arrayWithCapacity:self.items.count];

	if (LOG_SCORING) NSLog(@"========================================");
	if (LOG_SCORING) NSLog(@"\n\n FINAL SCORES!\n\n");
	if (LOG_SCORING) NSLog(@"========================================");
	
	for (ORSFItem *item in self.items) {
	
		item.scoreBlendedNormalized = item.scoreBlendedWeighted - meanScore;
//		item.scoreBlendedNormalized = item.scoreBlendedWeighted - avgScore;
		item.scoreBlendedNormalized /= sdScore;
		if (LOG_SCORING) NSLog(@"%@ = %f", item.title, item.scoreBlendedNormalized);
		
		// check to see if it should be dropped
		if (item.scoreBlendedNormalized < cutoff) {
			[itemsToDrop addObject:item];
			if (LOG_SCORING) NSLog(@"   >>>>>>>>>>>> DROPPING ITEM  <<<<<<<<<<<< score = %f cutoff = %f", item.scoreBlendedNormalized, cutoff);
		}
		if (LOG_SCORING) NSLog(@"___________________________________________________________\n\n");
	}

	// 4) drop values below the cutoff
	[self.items removeObjectsInArray:itemsToDrop];
    self.itemsAvailable -= itemsToDrop.count;
	
}

@end

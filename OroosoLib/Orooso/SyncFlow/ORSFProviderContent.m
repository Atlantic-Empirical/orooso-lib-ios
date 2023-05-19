//
//  ORSFProviderContent.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 03/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderContent.h"
#import "ORApiEngine.h"
#import "ORSFItem.h"

@interface ORSFProviderContent ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, strong) NSMutableOrderedSet *featuredItems;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, assign) NSUInteger featuredItemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderContent

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.page = 0;
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    self.page = 0;
}

- (void)stop
{
    [super stop];
    
    if (self.op) {
        [self.op cancel];
        self.op = nil;
    }
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (!self.entity) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching Entity content...");
    
    ORApiEngine *engine = [ORApiEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *countryCode = [[locale objectForKey:NSLocaleCountryCode] uppercaseString];
    language = [NSString stringWithFormat:@"%@_%@", [language lowercaseString], [countryCode lowercaseString]];
    if (![language isEqualToString:@"ja_jp"]) language = @"en_us";
    if (!countryCode) countryCode = @"US";
    
    ORArrayCompletion returnBlock = ^(NSError *error, NSArray *result) {
        dispatch_async(queue, ^{
            self.op = nil;
            
            if (error) {
                if (completion) completion(error, 0);
                return;
            }
            
            // Create the item set, if needed
            if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
            if (!self.featuredItems) self.featuredItems = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
            
            NSUInteger added = 0;
            self.page++;
            
            for (ORSFItem *item in result) {
                // TEMP: Videos go to featured
                if (item.type == SFItemTypeVideo) {
                    // Only add item if it's not already in the set
                    if (![self.featuredItems containsObject:item]) {
                        item.taken = NO;
                        item.parentEntity = self.entity;
                        [self.featuredItems addObject:item];
                        self.featuredItemsAvailable++;
                        added++;
                    }
                } else {
                    // Only add item if it's not already in the set
                    if (![self.items containsObject:item]) {
                        item.taken = NO;
                        item.parentEntity = self.entity;
                        [self.items addObject:item];
                        self.itemsAvailable++;
                        added++;
                    }
                }
            }
            
            if (completion) completion(nil, added);
        });
    };
    
    if (self.entity.isDynamic) {
        self.op = [engine fetchDynamicContent:self.entity.name
                                maturityLevel:self.maturityLevel
                                      country:countryCode
                                     language:language
                                         page:self.page
                                     latitude:self.currentLatitude
                                    longitude:self.currentLongitude
                                           cb:returnBlock];
    } else {
        self.op = [engine fetchContent:self.entity.entityId
                            entityType:self.entity.entityType
                         maturityLevel:self.maturityLevel
                               country:countryCode
                              language:language
                                  page:self.page
                              latitude:self.currentLatitude
                             longitude:self.currentLongitude
                                    cb:returnBlock];
    }
}

@end

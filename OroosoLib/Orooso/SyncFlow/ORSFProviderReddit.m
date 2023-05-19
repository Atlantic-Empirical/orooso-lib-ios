//
//  ORSFProviderReddit.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderReddit.h"
#import "ORRedditEngine.h"
#import "ORRedditLink.h"
#import "ORImage.h"
#import "ORInstantResult.h"
#import "ORURLResolver.h"
#import "ORURL.h"

#import "ORSFVideo.h"
#import "ORSFImage.h"
#import "ORSFWebsite.h"

@interface ORSFProviderReddit ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, weak) MKNetworkOperation *op;
@property (atomic, copy) NSString *after;

@end

@implementation ORSFProviderReddit

- (id)initWithFrequency:(NSUInteger)frequency
{
    self = [super initWithFrequency:frequency];
    
    if (self) {
        self.minimumThreshold = 5;
        self.after = nil;
    }
    
    return self;
}

- (NSString *)searchQuery
{
    if (self.entity.subreddit) {
        return self.entity.subreddit;
    } else {
        NSData *asciiEncoded = [self.entity.name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *unfiltered = [[NSString alloc] initWithData:asciiEncoded encoding:NSASCIIStringEncoding];
        
        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
        NSString *resultString = [[unfiltered componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        NSLog(@"%@ -> %@", self.entity.name, resultString);
        return [NSString stringWithFormat:@"/r/%@", resultString];
    }
}

- (void)reset
{
    [super reset];
    
    self.after = nil;
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (!self.entity) {
        if (completion) completion(nil, 0);
        return;
    }
    
    NSLog(@"Fetching Reddit items...");
    
    ORRedditEngine *engine = [ORRedditEngine sharedInstance];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    self.op = [engine fetchItemsFromSubreddit:[self searchQuery] after:self.after cb:^(NSError *error, NSArray *items) {
        dispatch_async(queue, ^{
            self.op = nil;
            
            if (error) {
                if (completion) completion(error, 0);
                return;
            }
            
            // Create the item set, if needed
            NSUInteger totalItems = items.count;
            if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:totalItems];
            
            __block NSUInteger added = 0;
            if (totalItems > 0) self.after = ((ORRedditLink *)items.lastObject).name;
            
            for (ORRedditLink *reddit in items) {
                // Discard Reddit posts without a link
                if (reddit.isSelf) continue;
                
                // Discard mature items if maturity level is higher than 0
                if (self.maturityLevel > 0 && reddit.isOver18) continue;

                ORURL *url = [ORURL URLWithURLString:reddit.url];
                if (!url.originalURL) continue;
                
                [[ORURLResolver sharedInstance] resolveORURL:url localOnly:YES completion:^(NSError *error, ORURL *finalURL) {
                    ORSFItem *item = nil;
                    
                    finalURL.pageTitle = reddit.title;
                    finalURL.pageDescription = reddit.text;
                    
                    switch (finalURL.type) {
                        case ORURLTypeYoutube: {
                            item = [[ORSFVideo alloc] initWithORURL:finalURL andEntity:self.entity];
                            break;
                        }
                        case ORURLTypeImage:
                        case ORURLTypeTwitpic:
                        case ORURLTypeTwitterMedia:
                        case ORURLTypeYfrog:
                        case ORURLTypeInstagram:
                        case ORURLTypeImgur: {
                            ORSFImage *img = [[ORSFImage alloc] initWithORURL:finalURL andEntity:self.entity];
                            img.image.sourceUrl = reddit.permalinkUrl;
                            item = img;
                            
                            break;
                        }
                        default: {
                            ORSFWebsite *web = [[ORSFWebsite alloc] initWithORURL:finalURL andEntity:self.entity];
                            web.avatarName = @"reddit-alien";
                            item = web;
                            
                            break;
                        }
                    }
                    
                    if (item) {
                        // Workaround for Imgur albums
                        if ([reddit.mediaType isEqualToString:@"imgur.com"] && !item.imageURL) {
                            item.imageURL = [NSURL URLWithString:reddit.mediaThumbnail];
                        }

                        item.provider = @"reddit";
                        item.taken = NO;
                    
                        [self.items addObject:item];
                        self.itemsAvailable++;
                        added++;
                    }
                }];
            }
            
            // Return to caller
            if (completion) completion(nil, added);
        });
    }];
}

@end

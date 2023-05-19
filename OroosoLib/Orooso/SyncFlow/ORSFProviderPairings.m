//
//  ORSFProviderPairings.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 29/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFProviderPairings.h"
#import "ORFacebookEngine.h"
#import "ORGoogleEngine.h"
#import "ORTwitterEngine.h"
#import "ORInstagramEngine.h"
#import "ORVimeoEngine.h"
#import "ORApiEngine.h"
#import "ORSFPairPrompt.h"

@interface ORSFProviderPairings ()

@property (atomic, strong) NSMutableOrderedSet *items;
@property (atomic, assign) NSUInteger itemsAvailable;
@property (atomic, assign) NSUInteger page;

@end

@implementation ORSFProviderPairings

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

- (void)updatePairStringsWithCompletion:(void(^)(void))completion
{
    if (self.pairStrings) {
        if (completion) completion();
        return;
    }
    
    ORApiEngine *api = [ORApiEngine sharedInstance];
    NSArray *keys = @[@"sf-prompt-facebook", @"sf-prompt-gmail", @"sf-prompt-instagram", @"sf-prompt-twitter", @"sf-prompt-vimeo"];
    dispatch_queue_t queue = dispatch_get_current_queue();
    
    [api clientStringsForKeys:keys cb:^(NSError *error, NSDictionary *result) {
        dispatch_async(queue, ^{
            if (error) NSLog(@"Error: %@", error);
            self.pairStrings = result;
            if (completion) completion();
        });
    }];
}

- (void)fetchNewItemsWithCompletion:(ORSFProviderIntBlock)completion
{
    if (self.page > 0) {
        if (completion) completion(nil, 0);
        return;
    }
    
    [self updatePairStringsWithCompletion:^{
        // Create the item set, if needed
        if (!self.items) self.items = [NSMutableOrderedSet orderedSetWithCapacity:5];
        
        NSUInteger added = 0;
        self.page++;
        
        // Facebook
        ORFacebookEngine *fb = [ORFacebookEngine sharedInstance];
        if (!fb.isAuthenticated) {
            ORSFPairPrompt *card = [[ORSFPairPrompt alloc] initWithId:@"facebook" title:@"Facebook" content:self.pairStrings[@"sf-prompt-facebook"]];
            card.imageName = @"facebook-tile-80x";
            card.taken = NO;
            
            [self.items addObject:card];
            self.itemsAvailable++;
            added++;
        }
        
        // Google
        ORGoogleEngine *go = [ORGoogleEngine sharedInstance];
        if (!go.isAuthenticated) {
            ORSFPairPrompt *card = [[ORSFPairPrompt alloc] initWithId:@"google" title:@"Google" content:self.pairStrings[@"sf-prompt-gmail"]];
            card.imageName = @"gmail-shiny-80x";
            card.taken = NO;
            
            [self.items addObject:card];
            self.itemsAvailable++;
            added++;
        }
        
        // Twitter
        ORTwitterEngine *tw = [ORTwitterEngine sharedInstance];
        if (!tw.isAuthenticated) {
            ORSFPairPrompt *card = [[ORSFPairPrompt alloc] initWithId:@"twitter" title:@"Twitter" content:self.pairStrings[@"sf-prompt-twitter"]];
            card.imageName = @"twitter-blue-bird-100x";
            card.taken = NO;
            
            [self.items addObject:card];
            self.itemsAvailable++;
            added++;
        }
        
        // Instagram
        ORInstagramEngine *ig = [ORInstagramEngine sharedInstance];
        if (!ig.isAuthenticated) {
            ORSFPairPrompt *card = [[ORSFPairPrompt alloc] initWithId:@"instagram" title:@"Instagram" content:self.pairStrings[@"sf-prompt-instagram"]];
            card.imageName = @"instagram-80x";
            card.taken = NO;
            
            [self.items addObject:card];
            self.itemsAvailable++;
            added++;
        }
        
        // Vimeo
        ORVimeoEngine *vi = [ORVimeoEngine sharedInstance];
        if (!vi.isAuthenticated) {
            ORSFPairPrompt *card = [[ORSFPairPrompt alloc] initWithId:@"vimeo" title:@"Vimeo" content:self.pairStrings[@"sf-prompt-vimeo"]];
            card.imageName = @"vimeo-80x";
            card.taken = NO;
            
            [self.items addObject:card];
            self.itemsAvailable++;
            added++;
        }
        
        // Return to caller
        if (completion) completion(nil, added);
    }];
}

@end

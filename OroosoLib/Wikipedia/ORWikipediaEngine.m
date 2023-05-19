//
//  ORWikipediaEngine.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORWikipediaEngine.h"
#import "ORWikipediaPageExtract.h"
#import "ORWikipediaPageExtractQuery.h"
#import "ORWikipediaPageExtractQueryPage.h"
#import "ORWikipediaPageExtractQueryPages.h"

// Parameters
#define WIKIPEDIA_HOSTNAME @"en.wikipedia.org"
#define WIKIPEDIA_API_PATH @"w/api.php"
#define WIKIPEDIA_ERROR_DOMAIN @"com.orooso.wikipedia.ErrorDomain"

// Search Parameters
#define WIKIPEDIA_MAX_RESULTS @"25" // Default: 25

@interface ORWikipediaEngine ()

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description;

@end

@implementation ORWikipediaEngine

#pragma mark - Initialization

+ (ORWikipediaEngine *)sharedInstance;
{
    static dispatch_once_t pred;
    static ORWikipediaEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORWikipediaEngine alloc] init];
    });
    
    return shared;
}

- (id) init
{
    self = [super initWithHostName:WIKIPEDIA_HOSTNAME customHeaderFields:nil];
    return self;
}

#pragma mark - Helpers

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
    return [NSError errorWithDomain:WIKIPEDIA_ERROR_DOMAIN code:code userInfo:ui];
}

#pragma mark - Custom Methods

// doc: http://en.wikipedia.org/w/api.php
// http://en.wikipedia.org/w/api.php?action=query&pageids=19831&prop=extracts&format=jsonfm&explaintext=1&exchars=120 or exsentences=n or exintro=1

- (MKNetworkOperation *)fetchPageExtractForPageId:(NSString*)pageId sentences:(int)sentences characters:(int)chars cb:(ORWKStringCompletion)completion;
{
    if (!pageId) { completion(nil, nil); return nil; }
    
    NSDictionary *params;
	if (sentences){
		params = @{@"action": @"query",
			 @"pageids": pageId,
			 @"format": @"json",
			 @"prop": @"extracts",
			 @"explaintext": @"1",
			 @"redirects": @"1",
			 @"exsentences": [NSString stringWithFormat:@"%d", sentences]};
	} else if (chars) {
		params = @{@"action": @"query",
			 @"pageids": pageId,
			 @"format": @"json",
			 @"prop": @"extracts",
			 @"explaintext": @"1",
			 @"redirects": @"1",
			 @"exchars": [NSString stringWithFormat:@"%d", chars]};
	} else {
		params = @{@"action": @"query",
			 @"pageids": pageId,
			 @"format": @"json",
			 @"prop": @"extracts",
			 @"explaintext": @"1",
			 @"redirects": @"1",
			 @"exintro": @"1"};
	}
    
    MKNetworkOperation *op = [self operationWithPath:WIKIPEDIA_API_PATH params:params httpMethod:@"GET" ssl:NO];
//    DLog(@"%@", op.url);

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		ORWikipediaPageExtract *pe = [ORWikipediaPageExtract instanceFromDictionary:[completedOperation responseJSON]];
		
        if (pe) {
			completion(nil, pe.query.pages.queryPage.extract);
        } else if ([pe isKindOfClass:[NSNull class]]) {
            completion(nil, nil);
        } else {
            NSError *error = [self errorWithCode:500 description:@"Unexpected response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

+ (NSString*)bestEffortWikiUrlForArbitraryString:(NSString*)string
{
	return [NSString stringWithFormat:@"http://en.wikipedia.org/w/index.php?go=Go&search=%@", [string mk_urlEncodedString]];
}


@end

//
//  ORRedditEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORRedditEngine.h"
#import "ORRedditLink.h"

#define REDDIT_HOSTNAME @"www.reddit.com"
#define REDDIT_ERROR_DOMAIN @"com.orooso.reddit.ErrorDomain"
#define REDDIT_MAX_RESULTS @"100"

@implementation ORRedditEngine

+ (ORRedditEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORRedditEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORRedditEngine alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super initWithHostName:REDDIT_HOSTNAME customHeaderFields:nil];
    return self;
}

#pragma mark - Helpers

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)description
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
    return [NSError errorWithDomain:REDDIT_ERROR_DOMAIN code:code userInfo:ui];
}

#pragma mark - Public Methods

- (MKNetworkOperation *)fetchItemsFromSubreddit:(NSString *)subreddit after:(NSString *)after cb:(ORRedditArrayCompletion)completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (after) params[@"after"] = after;
    params[@"limit"] = REDDIT_MAX_RESULTS;
    
    NSString *path = [NSString stringWithFormat:@"%@/hot.json", subreddit];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSArray *result = [data valueForKeyPath:@"data.children"];
            NSArray *items = [ORRedditLink arrayWithJSON:result];
            completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)searchRedditFor:(NSString *)query after:(NSString *)after cb:(ORRedditArrayCompletion)completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (after) params[@"after"] = after;
    params[@"limit"] = REDDIT_MAX_RESULTS;
    params[@"q"] = query;
    
    NSString *path = @"/search.json";
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSArray *result = [data valueForKeyPath:@"data.children"];
            NSArray *items = [ORRedditLink arrayWithJSON:result];
            completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

@end

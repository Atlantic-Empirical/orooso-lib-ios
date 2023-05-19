//
//  ORYouTubeEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORYouTubeEngine.h"
#import "ORYouTubeVideo.h"

// YouTube Parameters
#define YT_HOSTNAME @"gdata.youtube.com"
#define YT_PATH @"feeds/api/videos"
#define YT_ERROR_DOMAIN @"com.orooso.youtube.ErrorDomain"

@interface ORYouTubeEngine ()

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description;

@end

@implementation ORYouTubeEngine

#pragma mark - Initialization

+ (ORYouTubeEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORYouTubeEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORYouTubeEngine alloc] init];
    });
    
    return shared;
}

- (id) init
{
    self = [super initWithHostName:YT_HOSTNAME customHeaderFields:nil];
    return self;
}

#pragma mark - Helpers

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
    return [NSError errorWithDomain:YT_ERROR_DOMAIN code:code userInfo:ui];
}

#pragma mark - Custom Methods

// Retrieve a list of videos matching a user-specified search term
// Docs: https://developers.google.com/youtube/2.0/developers_guide_protocol_api_query_parameters

- (MKNetworkOperation *)fetchVideosForString:(NSString *)query page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORYouTubeArrayCompletion)completion
{
    if (!query) { completion(nil, nil); return nil; }

    NSString *safeSearch = nil;
    switch (maturityLevel) {
        case 1: // Moderate
            safeSearch = @"moderate";
            break;
        case 2: // Strict
            safeSearch = @"strict";
            break;
        default:
            safeSearch = @"none";
            break;
    }
    
    NSUInteger startIndex = (page * count) + 1;
    NSDictionary *params = @{@"alt": @"json",
                             @"v": @"2",
                             @"format": @"5",
                             @"max-results": @(count),
                             @"start-index": @(startIndex),
                             @"safeSearch": safeSearch,
                             @"q": query};
    
    // Shows only results from a specific author
    //[params setObject:@"Google" forKey:@"author"];
    
    // Returns only 3D videos
    //[params setObject:@"true" forKey:@"3d"];
    
    // Returns videos with a specific category/keyword
    //[params setObject:@"Music" forKey:@"category"];
    
    // Returns videos with a specific duration
    //[params setObject:@"short" forKey:@"duration"]; // short = <4m | medium = >4m <20m | long = >20m
    
    // Returns only HD videos (> 720p)
    //[params setObject:@"true" forKey:@"hd"];
    
    // Specifies the method to order results
    //[params setObject:@"published" forKey:@"orderby"]; // relevance (default) | published | viewCount | rating
    
    MKNetworkOperation *op = [self operationWithPath:YT_PATH params:params httpMethod:@"GET" ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [[[completedOperation responseJSON] objectForKey:@"feed"] objectForKey:@"entry"];

        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[data count]];
            NSUInteger idx = 0;
            
            for (NSDictionary *obj in data) {
                ORYouTubeVideo *v = [[ORYouTubeVideo alloc] initWithYTJSON:obj];
                v.queryString = query;
                v.positionInSearchResults = idx;
                
                if (!v.isMobileRestricted) {
                    [result addObject:v];
                    idx++;
                }
            }
            
            completion(nil, result);
        } else if ([data isKindOfClass:[NSNull class]]) {
            completion(nil, nil);
        } else if (!data && [[completedOperation responseJSON] objectForKey:@"feed"]) {
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

// Retrieve a list of videos related to a given video ID
// Docs: https://developers.google.com/youtube/2.0/developers_guide_protocol_video_feeds#Related_Feeds

- (MKNetworkOperation *)fetchVideosRelatedToId:(NSString *)videoId page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORYouTubeArrayCompletion)completion
{
    if (!videoId) { completion(nil, nil); return nil; }
    
    NSString *safeSearch = nil;
    switch (maturityLevel) {
        case 1: // Moderate
            safeSearch = @"moderate";
            break;
        case 2: // Strict
            safeSearch = @"strict";
            break;
        default:
            safeSearch = @"none";
            break;
    }
    
    NSUInteger startIndex = (page * count) + 1;
    NSDictionary *params = @{@"alt": @"json",
                             @"v": @"2",
                             @"format": @"5",
                             @"max-results": @(count),
                             @"start-index": @(startIndex),
                             @"safeSearch": safeSearch};
    
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@/%@/related", YT_PATH, videoId]
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [[[completedOperation responseJSON] objectForKey:@"feed"] objectForKey:@"entry"];

        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[data count]];
            NSUInteger idx = 0;
            
            for (NSDictionary *obj in data) {
                ORYouTubeVideo *v = [[ORYouTubeVideo alloc] initWithYTJSON:obj];
                v.queryString = videoId;
                v.positionInSearchResults = idx;
                
                if (!v.isMobileRestricted) {
                    [result addObject:v];
                    idx++;
                }
            }
            
            completion(nil, result);
        } else if ([data isKindOfClass:[NSNull class]]) {
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

//https://developers.google.com/youtube/2.0/developers_guide_protocol_video_entries
//https://gdata.youtube.com/feeds/api/videos/videoid?v=2

- (MKNetworkOperation *)fetchVideoById:(NSString *)videoId cb:(ORYouTubeArrayCompletion)completion
{
    if (!videoId) { completion(nil, nil); return nil; }
	
    NSDictionary *params = @{@"alt": @"json",
                             @"v": @"2",
                             @"format": @"5"};
    
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@/%@", YT_PATH, videoId]
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:YES];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [[completedOperation responseJSON] objectForKey:@"entry"];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
			[result addObject:[[ORYouTubeVideo alloc] initWithYTJSON:data]];
            completion(nil, result);
        } else if ([data isKindOfClass:[NSNull class]]) {
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

+ (NSString*)bestEffortUrlForArbitraryString:(NSString*)string
{
	return [NSString stringWithFormat:@"http://m.youtube.com/results?q=%@", [string mk_urlEncodedString]];
}

@end

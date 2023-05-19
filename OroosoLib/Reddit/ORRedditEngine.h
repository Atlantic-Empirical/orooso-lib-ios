//
//  ORRedditEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^ORRedditArrayCompletion)(NSError *error,NSArray *items);

@interface ORRedditEngine : MKNetworkEngine

+ (ORRedditEngine *)sharedInstance;

- (MKNetworkOperation *)fetchItemsFromSubreddit:(NSString *)subreddit after:(NSString *)after cb:(ORRedditArrayCompletion)completion;
- (MKNetworkOperation *)searchRedditFor:(NSString *)query after:(NSString *)after cb:(ORRedditArrayCompletion)completion;

@end

//
//  ORYouTubeEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

typedef void (^ORYouTubeArrayCompletion)(NSError *error, NSArray *items);

@interface ORYouTubeEngine : MKNetworkEngine

+ (ORYouTubeEngine *)sharedInstance;
- (MKNetworkOperation *)fetchVideosForString:(NSString *)query page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORYouTubeArrayCompletion)completion;
- (MKNetworkOperation *)fetchVideosRelatedToId:(NSString *)videoId page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORYouTubeArrayCompletion)completion;
- (MKNetworkOperation *)fetchVideoById:(NSString *)videoId cb:(ORYouTubeArrayCompletion)completion;
+ (NSString*)bestEffortUrlForArbitraryString:(NSString*)string;

@end

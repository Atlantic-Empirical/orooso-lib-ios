//
//  ORSongkickEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^ORSKCompletion)(NSError *error);
typedef void (^ORSKArrayCompletion)(NSError *error, NSArray *items);

@interface ORSongkickEngine : MKNetworkEngine

+ (ORSongkickEngine *)sharedInstance;
- (MKNetworkOperation *)findConcertsForArtist:(NSString *)artist lat:(CGFloat)lat lng:(CGFloat)lng completion:(ORSKArrayCompletion)completion;

@end
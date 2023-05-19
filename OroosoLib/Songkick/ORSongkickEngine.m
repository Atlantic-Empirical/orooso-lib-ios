//
//  ORSongkickEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSongkickEngine.h"
#import "ORSongkickEvent.h"

#define SK_API_KEY @"kevvwEg9CVAL4yDl"
#define SK_HOSTNAME @"api.songkick.com"
#define SK_EVENTS @"api/3.0/events.json"

@implementation ORSongkickEngine

#pragma mark - Initialization

+ (ORSongkickEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORSongkickEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORSongkickEngine alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super initWithHostName:SK_HOSTNAME customHeaderFields:nil];
    return self;
}

- (MKNetworkOperation *)findConcertsForArtist:(NSString *)artist lat:(CGFloat)lat lng:(CGFloat)lng completion:(ORSKArrayCompletion)completion
{
    NSDictionary *params = @{@"artist_name": artist,
                             @"location": [NSString stringWithFormat:@"geo:%f,%f", lat, lng],
                             @"apikey": SK_API_KEY};
    
    MKNetworkOperation *op = [self operationWithPath:SK_EVENTS params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSArray *events = [ORSongkickEvent arrayWithSKJSON:[data valueForKeyPath:@"resultsPage.results.event"]];
            completion(nil, events);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid Response.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORSongkickEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

@end

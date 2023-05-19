//
//  ORFreebaseEngine.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORFreebaseEngine.h"
#import "ORFreebaseTopicDescription.h"
#import "ORFreebaseTopicDescriptionProperty.h"
#import "ORFreebaseTopicDescriptionPropertyCommonTopicDescription.h"
#import "ORFreebaseTopicDescriptionValue.h"
#import "ORInstantResult.h"
#import "ORLoggingEngine.h"

// Freebase Parameters
#define FREEBASE_HOSTNAME @"www.googleapis.com"
#define FREEBASE_TOPIC_PATH @"freebase/v1/topic/en/"
#define FREEBASE_SEARCH_PATH @"freebase/v1/search"
#define FREEBASE_ERROR_DOMAIN @"com.orooso.freebase.ErrorDomain"
#define FREEBASE_API_KEY @"AIzaSyBeu-mLWQG53j7LWfuAsbmCb7J1MqJwiRk"

// Search Parameters
#define FREEBASE_MAX_RESULTS @"25" // Default: 25

@implementation ORFreebaseEngine

#pragma mark - Initialization

+ (ORFreebaseEngine *)sharedInstance;
{
    static dispatch_once_t pred;
    static ORFreebaseEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORFreebaseEngine alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super initWithHostName:FREEBASE_HOSTNAME customHeaderFields:nil];
    return self;
}

#pragma mark - Helpers

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)description
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
    return [NSError errorWithDomain:FREEBASE_ERROR_DOMAIN code:code userInfo:ui];
}

#pragma mark - Custom Methods

// doc: https://developers.google.com/freebase/v1/topic-overview
// ex. url: https://www.googleapis.com/freebase/v1/topic/en/entourage?filter=%2Fcommon%2Ftopic%2Fdescription

- (MKNetworkOperation *)fetchDescriptionForTopicName:(NSString *)query cb:(ORTopicDescriptionCompletion)completion
{
    if (!query) { completion(nil, nil); return nil; }
    
	// mandatory prep of the string
	query = [query stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	query = [query lowercaseString];
	
	NSString *path = [NSString stringWithFormat:@"%@%@", FREEBASE_TOPIC_PATH, [query or_urlPathEncodedString]];
	
    NSDictionary *params = @{@"filter": @"/common/topic/description"};
    
    
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:YES];
    DLog(@"%@", op.url);
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		ORFreebaseTopicDescription *desc = [ORFreebaseTopicDescription instanceFromDictionary:[completedOperation responseJSON]];
		ORFreebaseTopicDescriptionValue *descV = [desc.property.CommonTopicDescription.values objectAtIndex:0];
		
        if (descV) {
			completion(nil, descV);
        } else if ([desc isKindOfClass:[NSNull class]]) {
            completion(nil, nil);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)searchFor:(NSString *)query cb:(ORFreebaseArrayCompletion)completion
{
    NSDictionary *params = @{@"key": FREEBASE_API_KEY,
                             @"query": query,
                             @"limit": @"10",
                             @"filter": @"(any type:/film/film type:tv/tv_program type:music/artist type:/people/person type:/sports/sports_team type:/location/citytown type:/location/country)"};
    NSString *path = [NSString stringWithFormat:@"%@", FREEBASE_SEARCH_PATH];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:YES];
    
    [ORLoggingEngine logEvent:@"Search.Freebase" params:@{@"query": query}];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSArray *result = [data valueForKey:@"result"];
            NSArray *items = [ORInstantResult arrayWithFreebaseJSON:result];
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

//
//  ORWikipediaEngine.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^ORWKStringCompletion)(NSError *error, NSString *result);

@interface ORWikipediaEngine : MKNetworkEngine

+ (ORWikipediaEngine *)sharedInstance;
- (MKNetworkOperation *)fetchPageExtractForPageId:(NSString*)pageId sentences:(int)sentences characters:(int)chars cb:(ORWKStringCompletion)completion;
+ (NSString*)bestEffortWikiUrlForArbitraryString:(NSString*)string;

@end

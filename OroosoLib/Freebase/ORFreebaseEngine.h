//
//  ORFreebaseEngine.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "MKNetworkEngine.h"

@class ORFreebaseTopicDescriptionValue;

typedef void (^ORTopicDescriptionCompletion)(NSError *error, ORFreebaseTopicDescriptionValue *description);
typedef void (^ORFreebaseArrayCompletion)(NSError *error,NSArray *items);

@interface ORFreebaseEngine : MKNetworkEngine

+ (ORFreebaseEngine *)sharedInstance;
- (MKNetworkOperation *)fetchDescriptionForTopicName:(NSString *)topicName cb:(ORTopicDescriptionCompletion)completion;
- (MKNetworkOperation *)searchFor:(NSString *)query cb:(ORFreebaseArrayCompletion)completion;

@end

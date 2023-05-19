//
//  ORLoggingEngine.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 3/25/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"

@class ORApiEngine, ORUser;

@interface ORLoggingEngine : NSObject

+ (ORLoggingEngine *)sharedInstance;
- (void)setupWithTestFlightId:(NSString*)testFlightId andGoogleAnalyticsId:(NSString*)googleAnalyticsId andMixpanelId:(NSString *)mixpanelId;

- (void)addLogItemAtLocation:(NSString*)location andEvent:(NSString*)event withParams:(NSDictionary*)params;
- (void)addLogItemAtLocation:(NSString*)location tappedItemName:(NSString*)btnName;

+ (void)logEvent:(NSString *)event params:(NSDictionary *)params;

@property (strong, nonatomic) ORUser *user;
@property (nonatomic, strong) id<GAITracker> gAnalytics;
@property (assign, nonatomic) NSUInteger utcSkewSeconds;

@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *serviceContext;
@property (nonatomic, copy) NSString *environment;
@property (nonatomic, copy) NSString *device;

- (void)flush;

@end

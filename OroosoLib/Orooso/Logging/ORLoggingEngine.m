//
//  ORLoggingEngine.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 3/25/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORLoggingEngine.h"
#import "ORLogItem.h"
#import "ORApiEngine.h"
#import "ORUser.h"

#define MXP (Mixpanel*)[Mixpanel sharedInstance]

//#ifdef DEBUG
//#warning TEST FLIGHT - comment before submitting for app store
//#define TESTING
//#endif

@interface ORLoggingEngine()

@property (strong, nonatomic) NSMutableArray *logItems;

@end

@implementation ORLoggingEngine

const int logBufferSize = 100;

#pragma mark - Initialization

+ (ORLoggingEngine *)sharedInstance;
{
    static dispatch_once_t pred;
    static ORLoggingEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORLoggingEngine alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;

    // TrackID parts
	self.company = @"Orooso";
	self.serviceContext = @"Client";
	self.environment = @"iOS";
	self.device = @"iPad";

	// OROOSO LOGGING
	self.logItems = [NSMutableArray arrayWithCapacity:logBufferSize];
    self.utcSkewSeconds = 0;
    
    return self;
}

- (void)setupWithTestFlightId:(NSString *)testFlightId andGoogleAnalyticsId:(NSString *)googleAnalyticsId andMixpanelId:(NSString *)mixpanelId
{
	// GOOGLE ANALYTICS
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].debug = NO;
    _gAnalytics = [[GAI sharedInstance] trackerWithTrackingId:googleAnalyticsId];
    
    [ORApiEngine sharedInstance].currentClientID = [_gAnalytics clientId];
    NSLog(@"GA Client ID: %@", [ORApiEngine sharedInstance].currentClientID);
	
	// MIXPANEL
	[Mixpanel sharedInstanceWithToken:mixpanelId];
	
	// TEST FLIGHT
	[TestFlight takeOff:testFlightId];
}

- (void)setUser:(ORUser*)user
{
	// MIXPANEL
	[MXP identify:user.userId];
	[MXP setNameTag:user.name];
}

//================================================================================================================
//
//  INTERFACE
//
//================================================================================================================
#pragma mark - INTERFACE

- (void)addLogItemAtLocation:(NSString*)location tappedItemName:(NSString*)btnName {
	[self addLogItemAtLocation:location andEvent:@"Tapped" withParams:[NSDictionary dictionaryWithObject:btnName forKey:@"button-name"]];
}

- (void)addLogItemAtLocation:(NSString*)location andEvent:(NSString*)event withParams:(NSDictionary*)params
{
	// BUILD TRACK ID
    NSString *trackId = nil;
    
    if (location) {
        trackId = [NSString stringWithFormat:@"%@.%@.%@.%@.%@.%@", self.company, self.serviceContext, self.environment, self.device, location, event];
    } else {
        trackId = [NSString stringWithFormat:@"%@.%@.%@.%@.%@", self.company, self.serviceContext, self.environment, self.device, event];
    }
	
	// INIT ORLogItem
	ORLogItem *li = [[ORLogItem alloc] initWithTrackId:trackId andUtcSkew:self.utcSkewSeconds];
    li.parameters = params;
	
	// DISPATCH
	[self bufferLogItemForOrooso:li];
	[self dispatchLogItemToGoogleAnalytics:li];
	[self dispatchLogItemToMixpanel:li];
	[self dispatchLogItemToTestFlight:li];
}

+ (void)logEvent:(NSString *)event params:(NSDictionary *)params
{
    [[ORLoggingEngine sharedInstance] addLogItemAtLocation:nil andEvent:event withParams:params];
}

//================================================================================================================
//
//  OROOSO LOGGING
//
//================================================================================================================
#pragma mark - OROOSO LOGGING

- (void)bufferLogItemForOrooso:(ORLogItem*)logItem
{
	// DEBUGGING - atomic
	[[ORApiEngine sharedInstance] postLogItem:logItem cb:nil];
	
//	// THE FANCY WAY - LOG BLOBS
//	[self.logItems addObject:logItem];
//	if (self.logItems.count >= logBufferSize) {
//		[self flush];
//	}
}

- (void)flush
{
    NSRange rng = NSMakeRange(0, self.logItems.count-1);
    NSArray *blob = [self.logItems subarrayWithRange:rng];
    [self.logItems removeObjectsInRange:rng];
    [self dispatchLogBlobToOrooso:blob];
}

- (void)dispatchLogBlobToOrooso:(NSArray*)blob
{
	[[ORApiEngine sharedInstance] postLogItems:blob cb:^(NSError *error, NSInteger httpStatusCode) {
		if (error) {
			DLog(@"error posting logblob: %@", [error localizedDescription]);
		} else {
			DLog(@"LOG BLOB SENT");
		}
	}];
}

//================================================================================================================
//
//  GOOGLE ANALYTICS
//
//================================================================================================================
#pragma mark - GOOGLE ANALYTICS

- (void)dispatchLogItemToGoogleAnalytics:(ORLogItem*)logItem
{
	// todo: convert logItem.params to a string
	[self.gAnalytics trackEventWithCategory:logItem.trackId withAction:nil withLabel:nil withValue:nil];
}

//================================================================================================================
//
//  MIXPANEL
//
//================================================================================================================
#pragma mark - MIXPANEL

- (void)dispatchLogItemToMixpanel:(ORLogItem*)logItem
{
//	[MXP track:logItem.trackId properties:logItem.parameters];
}

//================================================================================================================
//
//  TESTFLIGHT
//
//================================================================================================================
#pragma mark - TESTFLIGHT

- (void)dispatchLogItemToTestFlight:(ORLogItem*)logItem
{
//	[TestFlight passCheckpoint:logItem.trackId];
//	TFLog(logItem.trackId);
}
	
@end

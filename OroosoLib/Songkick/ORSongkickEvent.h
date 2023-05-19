//
//  ORSKEvent.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORSongkickPerformance;

@interface ORSongkickEvent : NSObject

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *eventURL;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, copy) NSString *venueName;
@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) NSArray *performances;
@property (nonatomic, readonly) ORSongkickPerformance *performance0;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

+ (id)instanceWithSKJSON:(NSDictionary *)json;
+ (id)arrayWithSKJSON:(NSArray *)json;
- (id)initWithSKJSON:(NSDictionary *)json;

@end

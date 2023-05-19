//
//  ORSKPerformance.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORSongkickPerformance : NSObject

@property (nonatomic, copy) NSString *performanceId;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *billingIndex;
@property (nonatomic, copy) NSString *billing;
@property (nonatomic, copy) NSString *artistId;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *artistURL;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;
+ (NSMutableArray *)proxyForJsonWithArray:(NSArray *)array;

+ (id)instanceWithSKJSON:(NSDictionary *)json;
+ (id)arrayWithSKJSON:(NSArray *)json;
- (id)initWithSKJSON:(NSDictionary *)json;

@end

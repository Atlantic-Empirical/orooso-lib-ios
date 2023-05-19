//
//  ORSpotLocation.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 04/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ORSpotLocation : NSObject

@property (nonatomic, copy) NSString *spotShareID;
@property (nonatomic, strong) NSMutableArray *spotShareIDs;
@property (nonatomic, assign) CLLocationCoordinate2D position;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSDictionary *)proxyForJson;

@end

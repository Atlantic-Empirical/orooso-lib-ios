//
//  ORSpotShare.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 02/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GMSMarker;

@interface ORSpotShare : NSObject <NSCoding>

@property (nonatomic, copy) NSString *spotShareID;
@property (nonatomic, copy) NSString *fromName;
@property (nonatomic, copy) NSString *fromEmail;
@property (nonatomic, copy) NSString *toName;
@property (nonatomic, copy) NSString *toEmail;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, assign) NSUInteger expire;
@property (nonatomic, assign) CLLocationCoordinate2D position;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, assign) BOOL isUpdating;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;
- (BOOL)isExpired;

@end

//
//  ORIDValue.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 17/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORIDValue : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *value;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
+ (NSArray *)proxyForJsonWithArray:(NSArray *)items;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

@end

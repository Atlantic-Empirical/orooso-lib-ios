//
//  OREmailType.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 15/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OREmailType : NSObject

@property (copy, nonatomic) NSString *emailType;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *userDescription;
@property (assign, nonatomic) BOOL isSelected;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

@end

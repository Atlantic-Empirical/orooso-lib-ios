//
//  ORVimeoUser.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORVimeoUser : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, assign) BOOL isPlus;
@property (nonatomic, assign) BOOL isPro;
@property (nonatomic, assign) BOOL isStaff;
@property (nonatomic, copy) NSString *realName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *profileURL;
@property (nonatomic, copy) NSString *videosURL;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

+ (id)instanceWithVimeoJSON:(NSDictionary *)json;
+ (id)arrayWithVimeoJSON:(NSArray *)json;
- (id)initWithVimeoJSON:(NSDictionary *)json;

@end

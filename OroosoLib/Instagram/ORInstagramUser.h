//
//  ORIGUser.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORInstagramUser : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, copy) NSString *profilePicture;
@property (nonatomic, copy) NSString *website;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

+ (id)instanceWithIGJSON:(NSDictionary *)json;
- (id)initWithIGJSON:(NSDictionary *)json;

@end

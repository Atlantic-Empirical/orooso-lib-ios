//
//  ORFriend.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 22/07/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORContact;

@interface ORFriend : NSObject

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *emailAddress;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *matchedHash;
@property (copy, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) ORContact *contact;
@property (assign, nonatomic) BOOL isFollowing;
@property (assign, nonatomic) BOOL isFollower;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (void)updateWithUser:(ORFriend *)user isFollowing:(BOOL)following isFollower:(BOOL)follower;

@end

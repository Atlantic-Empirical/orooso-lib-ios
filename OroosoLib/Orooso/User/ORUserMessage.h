//
//  ORUserMessage.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 08/10/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORUserMessage : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *messageType;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *portlUrl;
@property (nonatomic, copy) NSString *friendId;
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *entityId;
@property (nonatomic, assign) NSUInteger entityType;

@property (nonatomic, copy) NSDate *created;
@property (nonatomic, assign) BOOL seen;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;

@end

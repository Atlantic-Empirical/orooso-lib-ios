//
//  ORUserMessage.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 08/10/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORUserMessage.h"
#import "ISO8601DateFormatter.h"

@implementation ORUserMessage

+ (id)instanceWithJSON:(NSDictionary *)json
{
    return [[self alloc] initWithJSON:json];
}

+ (id)arrayWithJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    self.userId = [json valueForKey:@"UserId"];
    self.messageId = [json valueForKey:@"MessageId"];
    self.messageType = [json valueForKey:@"MessageType"];
    self.message = [json valueForKey:@"Message"];
    self.portlUrl = [json valueForKey:@"PortlUrl"];
    self.friendId = [json valueForKey:@"FriendId"];
    self.boardId = [json valueForKey:@"BoardId"];
    self.itemId = [json valueForKey:@"ItemId"];
    self.entityId = [json valueForKey:@"EntityId"];
    self.entityType = [[json valueForKey:@"EntityType"] unsignedIntegerValue];
    self.created = [f dateFromString:[json valueForKey:@"Created"]];
    self.seen = [[json valueForKey:@"Seen"] boolValue];
    
    return self;
}

@end

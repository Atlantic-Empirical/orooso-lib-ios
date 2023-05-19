//
//  ORTwitterEntities.m
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORTwitterEntities.h"

@implementation ORTwitterEntities

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.hashtags forKey:@"hashtags"];
    [encoder encodeObject:self.urls forKey:@"urls"];
    [encoder encodeObject:self.userMentions forKey:@"userMentions"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.hashtags = [decoder decodeObjectForKey:@"hashtags"];
        self.urls = [decoder decodeObjectForKey:@"urls"];
        self.userMentions = [decoder decodeObjectForKey:@"userMentions"];
    }
    return self;
}

+ (ORTwitterEntities *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORTwitterEntities *instance = [[ORTwitterEntities alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([key isEqualToString:@"hashtags"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.hashtags = myMembers;

        }

    } else if ([key isEqualToString:@"urls"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.urls = myMembers;

        }

    } else if ([key isEqualToString:@"user_mentions"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.userMentions = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"user_mentions"]) {
        [self setValue:value forKey:@"userMentions"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.hashtags) {
        [dictionary setObject:self.hashtags forKey:@"hashtags"];
    }

    if (self.urls) {
        [dictionary setObject:self.urls forKey:@"urls"];
    }

    if (self.userMentions) {
        [dictionary setObject:self.userMentions forKey:@"userMentions"];
    }

    return dictionary;

}

@end

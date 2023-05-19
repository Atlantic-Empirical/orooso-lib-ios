//
//  ORTwitterUserEntitiesDescription.m
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORTwitterUserEntitiesDescription.h"

@implementation ORTwitterUserEntitiesDescription

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.urls forKey:@"urls"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.urls = [decoder decodeObjectForKey:@"urls"];
    }
    return self;
}

+ (ORTwitterUserEntitiesDescription *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORTwitterUserEntitiesDescription *instance = [[ORTwitterUserEntitiesDescription alloc] init];
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

    if ([key isEqualToString:@"urls"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.urls = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.urls) {
        [dictionary setObject:self.urls forKey:@"urls"];
    }

    return dictionary;

}

@end

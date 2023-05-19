//
//  ORMyClassPropertyCommonTopicDescription.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORFreebaseTopicDescriptionPropertyCommonTopicDescription.h"

#import "ORFreebaseTopicDescriptionValue.h"

@implementation ORFreebaseTopicDescriptionPropertyCommonTopicDescription

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.count forKey:@"count"];
    [encoder encodeObject:self.values forKey:@"values"];
    [encoder encodeObject:self.valuetype forKey:@"valuetype"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.count = [decoder decodeObjectForKey:@"count"];
        self.values = [decoder decodeObjectForKey:@"values"];
        self.valuetype = [decoder decodeObjectForKey:@"valuetype"];
    }
    return self;
}

+ (ORFreebaseTopicDescriptionPropertyCommonTopicDescription *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORFreebaseTopicDescriptionPropertyCommonTopicDescription *instance = [[ORFreebaseTopicDescriptionPropertyCommonTopicDescription alloc] init];
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

    if ([key isEqualToString:@"values"]) {

        if ([value isKindOfClass:[NSArray class]])
		{
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:((NSArray*)value).count];
            for (id valueMember in value) {
                ORFreebaseTopicDescriptionValue *populatedMember = [ORFreebaseTopicDescriptionValue instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.values = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.count) {
        [dictionary setObject:self.count forKey:@"count"];
    }

    if (self.values) {
        [dictionary setObject:self.values forKey:@"values"];
    }

    if (self.valuetype) {
        [dictionary setObject:self.valuetype forKey:@"valuetype"];
    }

    return dictionary;

}

@end

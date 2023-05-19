//
//  ORFreebaseTopicDescription.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORFreebaseTopicDescription.h"

#import "ORFreebaseTopicDescriptionProperty.h"

@implementation ORFreebaseTopicDescription

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.topicDescriptionId forKey:@"topicDescriptionId"];
    [encoder encodeObject:self.property forKey:@"property"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.topicDescriptionId = [decoder decodeObjectForKey:@"topicDescriptionId"];
        self.property = [decoder decodeObjectForKey:@"property"];
    }
    return self;
}

+ (ORFreebaseTopicDescription *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORFreebaseTopicDescription *instance = [[ORFreebaseTopicDescription alloc] init];
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

    if ([key isEqualToString:@"property"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.property = [ORFreebaseTopicDescriptionProperty instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"topicDescriptionId"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.topicDescriptionId) {
        [dictionary setObject:self.topicDescriptionId forKey:@"topicDescriptionId"];
    }

    if (self.property) {
        [dictionary setObject:self.property forKey:@"property"];
    }

    return dictionary;

}

@end

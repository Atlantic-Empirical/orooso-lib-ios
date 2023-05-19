//
//  ORMyClassProperty.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORFreebaseTopicDescriptionProperty.h"

#import "ORFreebaseTopicDescriptionPropertyCommonTopicDescription.h"

@implementation ORFreebaseTopicDescriptionProperty

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.CommonTopicDescription forKey:@"CommonTopicDescription"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.CommonTopicDescription = [decoder decodeObjectForKey:@"CommonTopicDescription"];
    }
    return self;
}

+ (ORFreebaseTopicDescriptionProperty *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORFreebaseTopicDescriptionProperty *instance = [[ORFreebaseTopicDescriptionProperty alloc] init];
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

    if ([key isEqualToString:@"/common/topic/description"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.CommonTopicDescription = [ORFreebaseTopicDescriptionPropertyCommonTopicDescription instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"/common/topic/description"]) {
        [self setValue:value forKey:@"CommonTopicDescription"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.CommonTopicDescription) {
        [dictionary setObject:self.CommonTopicDescription forKey:@"CommonTopicDescription"];
    }

    return dictionary;

}

@end

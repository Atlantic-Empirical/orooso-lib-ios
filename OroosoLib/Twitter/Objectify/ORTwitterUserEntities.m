//
//  ORTwitterUserEntities.m
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORTwitterUserEntities.h"

#import "ORTwitterUserEntitiesDescription.h"

@implementation ORTwitterUserEntities

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.descriptionText forKey:@"descriptionText"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.descriptionText = [decoder decodeObjectForKey:@"descriptionText"];
    }
    return self;
}

+ (ORTwitterUserEntities *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORTwitterUserEntities *instance = [[ORTwitterUserEntities alloc] init];
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

    if ([key isEqualToString:@"description"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.descriptionText = [ORTwitterUserEntitiesDescription instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.descriptionText) {
        [dictionary setObject:self.descriptionText forKey:@"descriptionText"];
    }

    return dictionary;

}

@end

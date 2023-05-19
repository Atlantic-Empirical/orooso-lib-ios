//
//  ORValue.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORFreebaseTopicDescriptionValue.h"

#import "ORFreebaseTopicDescriptionValueCitation.h"

@implementation ORFreebaseTopicDescriptionValue

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.citation forKey:@"citation"];
    [encoder encodeObject:self.creator forKey:@"creator"];
    [encoder encodeObject:self.dataset forKey:@"dataset"];
    [encoder encodeObject:self.lang forKey:@"lang"];
    [encoder encodeObject:self.project forKey:@"project"];
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeObject:self.value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.citation = [decoder decodeObjectForKey:@"citation"];
        self.creator = [decoder decodeObjectForKey:@"creator"];
        self.dataset = [decoder decodeObjectForKey:@"dataset"];
        self.lang = [decoder decodeObjectForKey:@"lang"];
        self.project = [decoder decodeObjectForKey:@"project"];
        self.text = [decoder decodeObjectForKey:@"text"];
        self.value = [decoder decodeObjectForKey:@"value"];
    }
    return self;
}

+ (ORFreebaseTopicDescriptionValue *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORFreebaseTopicDescriptionValue *instance = [[ORFreebaseTopicDescriptionValue alloc] init];
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
    if ([key isEqualToString:@"citation"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.citation = [ORFreebaseTopicDescriptionValueCitation instanceFromDictionary:value];
        }
    } else {
		@try {
			[super setValue:value forKey:key];
		}
		@catch (NSException *e) {
			NSLog(@"*** WARN: Tried to set a value to a key that doesn't exist: %@ ***", key);
		}
    }
}

- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.citation) {
        [dictionary setObject:self.citation forKey:@"citation"];
    }

    if (self.creator) {
        [dictionary setObject:self.creator forKey:@"creator"];
    }

    if (self.dataset) {
        [dictionary setObject:self.dataset forKey:@"dataset"];
    }

    if (self.lang) {
        [dictionary setObject:self.lang forKey:@"lang"];
    }

    if (self.project) {
        [dictionary setObject:self.project forKey:@"project"];
    }

    if (self.text) {
        [dictionary setObject:self.text forKey:@"text"];
    }

    if (self.value) {
        [dictionary setObject:self.value forKey:@"value"];
    }

    return dictionary;

}

@end

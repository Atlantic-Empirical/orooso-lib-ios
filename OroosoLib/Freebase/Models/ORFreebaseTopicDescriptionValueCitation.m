//
//  ORValueCitation.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORFreebaseTopicDescriptionValueCitation.h"

@implementation ORFreebaseTopicDescriptionValueCitation

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.provider forKey:@"provider"];
    [encoder encodeObject:self.statement forKey:@"statement"];
    [encoder encodeObject:self.uri forKey:@"uri"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.provider = [decoder decodeObjectForKey:@"provider"];
        self.statement = [decoder decodeObjectForKey:@"statement"];
        self.uri = [decoder decodeObjectForKey:@"uri"];
    }
    return self;
}

+ (ORFreebaseTopicDescriptionValueCitation *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORFreebaseTopicDescriptionValueCitation *instance = [[ORFreebaseTopicDescriptionValueCitation alloc] init];
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

- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.provider) {
        [dictionary setObject:self.provider forKey:@"provider"];
    }

    if (self.statement) {
        [dictionary setObject:self.statement forKey:@"statement"];
    }

    if (self.uri) {
        [dictionary setObject:self.uri forKey:@"uri"];
    }

    return dictionary;

}

@end

//
//  ORWikipediaPageExtract.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORWikipediaPageExtract.h"

#import "ORWikipediaPageExtractQuery.h"

@implementation ORWikipediaPageExtract

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.query forKey:@"query"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.query = [decoder decodeObjectForKey:@"query"];
    }
    return self;
}

+ (ORWikipediaPageExtract *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORWikipediaPageExtract *instance = [[ORWikipediaPageExtract alloc] init];
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

    if ([key isEqualToString:@"query"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.query = [ORWikipediaPageExtractQuery instanceFromDictionary:value];
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

    if (self.query) {
        [dictionary setObject:self.query forKey:@"query"];
    }

    return dictionary;

}

@end

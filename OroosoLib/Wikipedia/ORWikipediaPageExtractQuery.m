//
//  ORWikipediaPageExtractQuery.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORWikipediaPageExtractQuery.h"

#import "ORWikipediaPageExtractQueryPages.h"

@implementation ORWikipediaPageExtractQuery

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.pages forKey:@"pages"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.pages = [decoder decodeObjectForKey:@"pages"];
    }
    return self;
}

+ (ORWikipediaPageExtractQuery *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORWikipediaPageExtractQuery *instance = [[ORWikipediaPageExtractQuery alloc] init];
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
    if ([key isEqualToString:@"pages"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.pages = [ORWikipediaPageExtractQueryPages instanceFromDictionary:value];
        }
    } else if ([key isEqualToString:@"redirects"]) {
        // Ignore
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

    if (self.pages) {
        [dictionary setObject:self.pages forKey:@"pages"];
    }

    return dictionary;

}

@end

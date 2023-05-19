//
//  ORWikipediaPageExtractQueryPage.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORWikipediaPageExtractQueryPage.h"

@implementation ORWikipediaPageExtractQueryPage

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.extract forKey:@"extract"];
    [encoder encodeObject:self.ns forKey:@"ns"];
    [encoder encodeObject:self.pageid forKey:@"pageid"];
    [encoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.extract = [decoder decodeObjectForKey:@"extract"];
        self.ns = [decoder decodeObjectForKey:@"ns"];
        self.pageid = [decoder decodeObjectForKey:@"pageid"];
        self.title = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

+ (ORWikipediaPageExtractQueryPage *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORWikipediaPageExtractQueryPage *instance = [[ORWikipediaPageExtractQueryPage alloc] init];
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
    // Just to ignore this property
    if ([key isEqualToString:@"missing"]) return;
    
    @try {
        [super setValue:value forKey:key];
    }
    @catch (NSException *e) {
        NSLog(@"*** WARN: Tried to set a value to a key that doesn't exist: %@ ***", key);
    }
}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.extract) {
        [dictionary setObject:self.extract forKey:@"extract"];
    }

    if (self.ns) {
        [dictionary setObject:self.ns forKey:@"ns"];
    }

    if (self.pageid) {
        [dictionary setObject:self.pageid forKey:@"pageid"];
    }

    if (self.title) {
        [dictionary setObject:self.title forKey:@"title"];
    }

    return dictionary;

}

@end

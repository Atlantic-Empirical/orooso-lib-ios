//
//  ORSFPairPrompt.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 21/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFPairPrompt.h"

@implementation ORSFPairPrompt

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.imageName = [json valueForKey:@"ImageName"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:self.imageName forKey:@"ImageName"];
    
    return d;
}

- (id)initWithId:(NSString *)itemId title:(NSString *)title content:(NSString *)content
{
    self = [super init];
    
    if (self) {
        self.itemID = itemId;
        self.type = SFItemTypePairPrompt;
        self.title = title;
        self.content = content;
    }
    
    return self;
}

- (UIImage *)mainImage
{
    if (self.imageName) {
        return [UIImage imageNamed:self.imageName];
    } else {
        return [super mainImage];
    }
}

@end

//
//  ORSFItemFacts.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 20/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItemFacts.h"
#import "ORUtility.h"

@implementation ORSFItemFacts

- (id)initWithTitle:(NSString *)title content:(NSString *)content entity:(OREntity *)entity
{
    self = [super init];
    
    if (self) {
        self.itemID = [ORUtility newGuidString];
        self.type = SFItemTypeFacts;
        self.title = title;
        self.content = content;
    }
    
    return self;
}

@end

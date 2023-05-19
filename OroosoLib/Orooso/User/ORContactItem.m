//
//  ORContactItem.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 10/1/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORContactItem.h"

@implementation ORContactItem

- (ORContactItem*) initWithDisplayName:(NSString*)displayName andType:(ORContactItemType) inType {
	self = [super init];
	if (self) {
		self.contactName = displayName;
		self.type = inType;
	}
	return self;
}

- (NSString *)description
{
    if (self.originalContact) return self.originalContact.description;
	return self.contactName;
	
//	switch (self.type) {
//			
//		case ORContactItemTypePhone:
//		case ORContactItemTypeEmail:
//			return [NSString stringWithFormat:@"%@ (%@)", self.contactName, self.contactInfo];
//			break;
//			
//		case ORContactItemTypeFb:
//			return [NSString stringWithFormat:@"%@ (Fb)", self.contactName];
//			break;
//
//		default:
//			break;
//	}
}

+ (NSArray *)proxyForJsonWithArray:(NSArray *)items
{
    if (!items) return nil;
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:items.count];
    
    for (ORContactItem *item in items) {
        NSDictionary *i = [item proxyForJson];
        if (i) [a addObject:i];
    }
    
    return a;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [d setValue:self.contactName forKey:@"ContactName"];
    [d setValue:self.contactInfo forKey:@"ContactInfo"];
    
    return d;
}

#pragma mark - NSCODING

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.contactName forKey:@"contactName"];
    [encoder encodeObject:self.contactInfo forKey:@"contactInfo"];
    [encoder encodeInt:self.type forKey:@"type"];
	[encoder encodeObject:self.originalContact forKey:@"originalContact"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	ORContactItem *newMe = [[ORContactItem alloc] init];
	newMe.contactName = [decoder decodeObjectForKey:@"contactName"];
	newMe.contactInfo = [decoder decodeObjectForKey:@"contactInfo"];
	newMe.type = [decoder decodeIntForKey:@"type"];
	newMe.originalContact = [decoder decodeObjectForKey:@"originalContact"];
    return newMe;
}

@end

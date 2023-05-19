//
//  ORContact.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 20/07/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORContact.h"
#import "ABPerson.h"
#import "ABMultiValue.h"

@implementation ORContact

- (NSString *)typeName
{
    switch (self.type) {
        case ORContactTypeAddressBook:
            return @"Address Book";
        case ORContactTypeFacebook:
            return @"Facebook";
        case ORContactTypeGoogle:
            return @"Google";
        case ORContactTypeTwitter:
            return @"Twitter";
        default:
            return @"Unknown";
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ORContact (%@)\n\tName: %@\n\tID: %@\n\tEmail: %@\n\tPhone: %@\n\tIM: %@\n\tImage: %@",
            [self typeName], _name, _id, _email, _phone, _im, _imageURL];
}

- (id)initWithDisplayName:(NSString *)displayName andType:(ORContactType)inType
{
    self = [super init];
    if (self) {
        self.name = displayName;
        self.type = inType;
    }
    return self;
}

- (id)initWithGoogleData:(NSDictionary *)data
{
    NSString *organization = nil;
    
    self = [super init];
    
    if (self && data) {
        self.id = [[data objectForKey:@"id"] objectForKey:@"$t"];
        self.name = [[data objectForKey:@"title"] objectForKey:@"$t"];
        self.email = nil;
        self.phone = nil;
        self.im = nil;
        self.type = ORContactTypeGoogle;
		
        // Use the e-mail with the "primary" key
        // If no primary e-mail defined, use the first found
        for (NSDictionary *info in [data objectForKey:@"gd$email"]) {
            if (!self.email) self.email = [info objectForKey:@"address"];
            
            if ([info objectForKey:@"primary"]) {
                self.email = [info objectForKey:@"address"];
                break;
            }
        }

        // Use the phone with the "primary" key
        // If no primary phone defined, use the first found
        for (NSDictionary *info in [data objectForKey:@"gd$phoneNumber"]) {
            if (!self.phone) self.phone = [info objectForKey:@"$t"];
            
            if ([info objectForKey:@"primary"]) {
                self.phone = [info objectForKey:@"$t"];
                break;
            }
        }
        
        // Use the im with the "primary" key
        // If no primary im defined, use the first found
        for (NSDictionary *info in [data objectForKey:@"gd$im"]) {
            if (!self.im) self.im = [info objectForKey:@"address"];
            
            if ([info objectForKey:@"primary"]) {
                self.im = [info objectForKey:@"address"];
                break;
            }
        }

        // Use the organization with the "primary" key
        // If no primary organization defined, use the first found
        for (NSDictionary *info in [data objectForKey:@"gd$organization"]) {
            if (!organization) organization = [[info objectForKey:@"gd$orgName"] objectForKey:@"$t"];
            
            if ([info objectForKey:@"primary"]) {
                organization = [[info objectForKey:@"gd$orgName"] objectForKey:@"$t"];
                break;
            }
        }
        
        // If the contact doesn't have a name, it may be an organization
        // Use the organization name (if found), otherwise use the e-mail address
        if ([self.name isEqualToString:@""]) {
            if (organization) {
                self.name = organization;
            } else if (self.email) {
                self.name = self.email;
            } else {
                self.name = nil;
            }
        }
    }
    
	if ([[data objectForKey:@"link"][0] objectForKey:@"gd$etag"]) {
//		DLog(@"got google contact image for: %@ %@", self.name, self.email);
		self.imageURL = [[data objectForKey:@"link"][0] objectForKey:@"href"];
//		DLog(@"%@", self.imageURL);
	}

    return self;
}

- (id)initWithFacebookData:(NSDictionary *)data
{
    self = [super init];
    
    if (self && data) {
        self.id = [data objectForKey:@"id"];
        self.name = [data objectForKey:@"name"];
        self.imageURL = [data valueForKeyPath:@"picture.data.url"];
        self.email = nil;
        self.phone = nil;
        self.im = nil;
        self.type = ORContactTypeFacebook;
    }
    
    return self;
}

- (id)initWithTwitterId:(NSString *)twitterId
{
    self = [super init];
    if (self) {
        self.id = twitterId;
        self.name = twitterId;
        self.type = ORContactTypeTwitter;
    }
    return self;
}

- (id)initWithABPerson:(ABPerson *)person
{
    self = [super init];
    if (!self) return nil;
    
    ABMultiValue *mv = [person valueForProperty:kABPersonEmailProperty];
    NSArray *emails = [mv allValues];
    if (!emails || [emails count] == 0) return nil;
    
    self.id = [NSString stringWithFormat:@"%d", [person recordID]];
    self.name = [person compositeName];
    self.email = emails[0];
    self.phone = nil;
    self.im = nil;
    self.type = ORContactTypeAddressBook;
    self.abPerson = person;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.id = [aDecoder decodeObjectForKey:@"RSCId"];
        self.name = [aDecoder decodeObjectForKey:@"RSCName"];
        self.email = [aDecoder decodeObjectForKey:@"RSCEmail"];
        self.phone = [aDecoder decodeObjectForKey:@"RSCPhone"];
        self.im = [aDecoder decodeObjectForKey:@"RSCIm"];
        self.type = [aDecoder decodeIntForKey:@"RSCType"];
		self.imageURL = [aDecoder decodeObjectForKey:@"RSCImage"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"RSCId"];
    [aCoder encodeObject:self.name forKey:@"RSCName"];
    [aCoder encodeObject:self.email forKey:@"RSCEmail"];
    [aCoder encodeObject:self.phone forKey:@"RSCPhone"];
    [aCoder encodeObject:self.im forKey:@"RSCIm"];
    [aCoder encodeInt:self.type forKey:@"RSCType"];
	[aCoder encodeObject:self.imageURL forKey:@"RSCImage"];
}

- (NSUInteger)hash
{
    if (self.email) return [self.email hash];
    if (self.phone) return [self.phone hash];

    return [self.id hash];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    
    if (self.email) return [self.email isEqual:[object email]];
    if (self.phone) return [self.phone isEqual:[object phone]];
    return [self.id isEqual:[object id]];
}

- (NSString *)contactHash
{
    switch (self.type) {
        case ORContactTypeAddressBook:
            if (self.email) return [self.email mk_md5];
            if (self.phone) return [self.phone mk_md5];
            return [[NSString stringWithFormat:@"ab_%@", self.id] mk_md5];
        case ORContactTypeGoogle:
            if (self.email) return [self.email mk_md5];
            if (self.phone) return [self.phone mk_md5];
            return [[NSString stringWithFormat:@"go_%@", self.id] mk_md5];
        case ORContactTypeFacebook:
            return [[NSString stringWithFormat:@"fb_%@", self.id] mk_md5];
        case ORContactTypeTwitter:
            return [[NSString stringWithFormat:@"tw_%@", self.id] mk_md5];
        default:
            return [self.id mk_md5];
    }
}


@end

//
//  OAuth1_PairingInfo.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 8/5/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "OAuthPairingInfo.h"

@implementation OAuthPairingInfo

+ (NSString *)serviceName:(OAuthService)service
{
    switch (service) {
        case OAuthServiceTwitter:
            return @"Twitter";
        case OAuthServiceFacebook:
            return @"Facebook";
        case OAuthServiceGoogle:
            return @"Google";
        case OAuthServiceATT:
            return @"ATT";
        case OAuthServiceUVerse:
            return @"UVerse";
		case OAuthServiceInstagram:
			return @"Instagram";
		case OAuthServiceVimeo:
			return @"Vimeo";
    }
    
    return @"Unknown";
}

#pragma mark - Initialization

- (id)initWithJson:(NSDictionary *)json
{
	self = [super init];
    
	if (self) {
        self.version = [[json valueForKey:@"Version"] integerValue];
        self.service = [[json valueForKey:@"Service"] integerValue];
        self.pairId = [json valueForKey:@"PairingId"];
		self.accessToken = [json valueForKey:@"AccessToken"];
		self.userId = [json valueForKey:@"UserId"];
		self.userName = [json valueForKey:@"UserName"];
		self.accessTokenSecret = [json valueForKey:@"AccessTokenSecret"];
		self.refreshToken = [json valueForKey:@"RefreshToken"];
		self.userEmail = [json valueForKey:@"UserEmail"];
		self.profilePicUrl = [json valueForKey:@"ProfilePicUrl"];
        self.parentUserId = [json valueForKey:@"ParentUserId"];
        
        NSString *expiration = [json valueForKey:@"ExpirationTime"];
        
        if (expiration && [expiration isKindOfClass:[NSString class]]) {
            self.expirationTime = [NSDate dateFromRFC1123:expiration];
        }

        NSLog(@"---");
        NSLog(@"Pairing Loaded from server for %@", [OAuthPairingInfo serviceName:self.service]);
        NSLog(@"User: %@ [%@]", self.userName, self.userId);
        NSLog(@"---");
	}
    
	return self;
}

#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    
    if (self) {
        self.version = [d decodeIntegerForKey:@"Version"];
        self.service = [d decodeIntegerForKey:@"Service"];
		self.pairId = [d decodeObjectForKey:@"PairingId"];
		self.accessToken = [d decodeObjectForKey:@"AccessToken"];
		self.userId = [d decodeObjectForKey:@"UserId"];
		self.userName = [d decodeObjectForKey:@"UserName"];
		self.accessTokenSecret = [d decodeObjectForKey:@"AccessTokenSecret"];
		self.refreshToken = [d decodeObjectForKey:@"RefreshToken"];
		self.expirationTime = [d decodeObjectForKey:@"ExpirationTime"];
		self.userEmail = [d decodeObjectForKey:@"UserEmail"];
		self.profilePicUrl = [d decodeObjectForKey:@"ProfilePicUrl"];
        self.parentUserId = [d decodeObjectForKey:@"ParentUserId"];
        
        NSLog(@"---");
        NSLog(@"Pairing Loaded locally for %@", [OAuthPairingInfo serviceName:self.service]);
        NSLog(@"User: %@ [%@]", self.userName, self.userId);
        NSLog(@"---");
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeInteger:self.version forKey:@"Version"];
    [c encodeInteger:self.service forKey:@"Service"];
    [c encodeObject:self.pairId forKey:@"PairingId"];
    [c encodeObject:self.accessToken forKey:@"AccessToken"];
    [c encodeObject:self.userId forKey:@"UserId"];
    [c encodeObject:self.userName forKey:@"UserName"];
    [c encodeObject:self.accessTokenSecret forKey:@"AccessTokenSecret"];
    [c encodeObject:self.refreshToken forKey:@"RefreshToken"];
    [c encodeObject:self.expirationTime forKey:@"ExpirationTime"];
    [c encodeObject:self.userEmail forKey:@"UserEmail"];
    [c encodeObject:self.profilePicUrl forKey:@"ProfilePicUrl"];
    [c encodeObject:self.parentUserId forKey:@"ParentUserId"];
}

- (NSDictionary *)proxyForJson
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:11];
    
    [json setValue:@(self.version) forKey:@"Version"];
    [json setValue:@(self.service) forKey:@"Service"];
    [json setValue:self.pairId forKey:@"PairingId"];
    [json setValue:self.accessToken forKey:@"AccessToken"];
    [json setValue:self.userId forKey:@"UserId"];
    [json setValue:self.userName forKey:@"UserName"];
    [json setValue:self.accessTokenSecret forKey:@"AccessTokenSecret"];
    [json setValue:self.refreshToken forKey:@"RefreshToken"];
    [json setValue:[self.expirationTime rfc1123String] forKey:@"ExpirationTime"];
    [json setValue:self.userEmail forKey:@"UserEmail"];
    [json setValue:self.profilePicUrl forKey:@"ProfilePicUrl"];
    [json setValue:self.parentUserId forKey:@"ParentUserId"];
	
	return json;
}

@end

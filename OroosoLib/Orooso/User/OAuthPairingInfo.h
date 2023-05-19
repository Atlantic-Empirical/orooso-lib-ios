//
//  OAuth1_PairingInfo.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 8/5/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _OAuthService {
    OAuthServiceTwitter,
    OAuthServiceFacebook,
    OAuthServiceGoogle,
    OAuthServiceATT,
    OAuthServiceUVerse,
	OAuthServiceVimeo,
	OAuthServiceInstagram
} OAuthService;

@class ORUser;

@interface OAuthPairingInfo : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger version;
@property (assign, nonatomic) OAuthService service;
@property (copy, nonatomic) NSString *parentUserId;
@property (copy, nonatomic) NSString *pairId;

// OAuth Shared
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;

// OAuth 1.0a
@property (copy, nonatomic) NSString *accessTokenSecret;

// OAuth 2.0
@property (copy, nonatomic) NSString *refreshToken;
@property (copy, nonatomic) NSDate *expirationTime;

// Non-OAuth
@property (copy, nonatomic) NSString *userEmail;
@property (copy, nonatomic) NSString *profilePicUrl;

- (id)initWithJson:(NSDictionary *)json;
- (NSDictionary *)proxyForJson;
+ (NSString *)serviceName:(OAuthService)service;

@end

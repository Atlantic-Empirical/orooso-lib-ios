//
//  ORTwitterUser.h
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORTwitterUserEntities;

@interface ORTwitterUser : NSObject <NSCoding>

@property (nonatomic, assign) BOOL contributorsEnabled;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, assign) BOOL defaultProfile;
@property (nonatomic, assign) BOOL defaultProfileImage;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, strong) ORTwitterUserEntities *entities;
@property (nonatomic, copy) NSNumber *favouritesCount;
@property (nonatomic, strong) id followRequestSent;
@property (nonatomic, copy) NSNumber *followersCount;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, copy) NSNumber *friendsCount;
@property (nonatomic, assign) BOOL geoEnabled;
@property (nonatomic, copy) NSNumber *oRTwitterUserId;
@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, assign) BOOL isTranslator;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSNumber *listedCount;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id notifications;
@property (nonatomic, copy) NSString *profileBackgroundColor;
@property (nonatomic, copy) NSString *profileBackgroundImageUrl;
@property (nonatomic, copy) NSString *profileBackgroundImageUrlHttps;
@property (nonatomic, assign) BOOL profileBackgroundTile;
@property (nonatomic, copy) NSString *profileImageUrl;
@property (nonatomic, copy) NSString *profileImageUrlHttps;
@property (nonatomic, copy) NSString *profileLinkColor;
@property (nonatomic, copy) NSString *profileSidebarBorderColor;
@property (nonatomic, copy) NSString *profileSidebarFillColor;
@property (nonatomic, copy) NSString *profileTextColor;
@property (nonatomic, assign) BOOL profileUseBackgroundImage;
@property (nonatomic, assign) BOOL protected;
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSNumber *statusesCount;
@property (nonatomic, copy) NSString *timeZone;
@property (nonatomic, strong) id url;
@property (nonatomic, copy) NSNumber *utcOffset;
@property (nonatomic, assign) BOOL verified;


+ (ORTwitterUser *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end

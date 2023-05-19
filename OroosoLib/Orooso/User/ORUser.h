//
//  OroosoUser.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 6/23/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthPairingInfo.h"

@class ORApiEngine;
@class ORFacebookEngine;
@class ORGoogleEngine;
@class ORFriend;

@interface ORUser : NSObject <NSCoding>

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

+ (ORUser *)instanceFromLocallyStoredUser;
- (ORUser *)initAnonUser;

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL hasContacts;
@property (assign, nonatomic, readonly) BOOL isAnonUser;
@property (nonatomic, readonly) NSString *defaultBoardId;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *emailAddress;
@property (copy, nonatomic) NSString *oldEmailAddress;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *lastSignIn;
@property (copy, nonatomic) NSString *signupDate;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *profileImageUrl;
@property (copy, nonatomic) NSString *lastNotificationId;
@property (strong, nonatomic) NSMutableDictionary *pairings;
@property (strong, nonatomic) NSMutableArray *optedOutEmails;

@property (strong, nonatomic, readonly) OAuthPairingInfo *twitterPairingInfo;
@property (strong, nonatomic, readonly) OAuthPairingInfo *googlePairingInfo;
@property (strong, nonatomic, readonly) OAuthPairingInfo *facebookPairingInfo;
@property (strong, nonatomic, readonly) OAuthPairingInfo *attPairingInfo;

- (BOOL)hasPairingInfoFor:(OAuthService)service;
- (OAuthPairingInfo *)pairingInfoFor:(OAuthService)service;
- (void)addPairingInfo:(OAuthPairingInfo *)info storeLocal:(BOOL)local storeRemote:(BOOL)remote;
- (void)addPairingInfo:(OAuthPairingInfo *)info;
- (void)removePairingInfo:(OAuthService)service;
- (void)fillPairingInfos:(NSArray *)infos;

// PERSISTENCE
- (void)saveUserWithCompletion:(void (^)(NSError *error, ORUser *user))completion;
- (void)saveLocalUser;
- (void)deleteUser;
- (void)removeLocalUser;

// Boards
@property (strong, nonatomic) NSMutableOrderedSet *boards;
@property (strong, nonatomic) NSOrderedSet *followingBoards;

- (void)reloadBoardsWithCompletion:(void (^)(NSError *error))completion;
- (void)reloadFollowingBoardsWithCompletion:(void (^)(NSError *error))completion;

// Friends/Followers
@property (nonatomic, strong) NSMutableOrderedSet *relatedUsers;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *followers;

- (void)reloadFriendsWithCompletion:(void (^)(NSError *error))completion;
- (void)reloadFollowersWithCompletion:(void (^)(NSError *error))completion;
- (ORFriend *)relatedUserWithUser:(ORFriend *)user;

// CONTACTS
@property (nonatomic, strong) NSArray *googleContacts;
@property (nonatomic, strong) NSArray *facebookContacts;
@property (nonatomic, strong) NSArray *twitterContacts;
@property (nonatomic, strong) NSMutableDictionary *allContacts;

- (void)refreshContacts;
- (void)fillContactsArrayFromLocalStorage;
- (void)facebookClearContacts;
- (void)facebookRefreshContactsWithCompletion:(void (^)(void))completion;
- (void)googleClearContacts;
- (void)googleRefreshContactsWithCompletion:(void (^)(void))completion;
- (void)twitterClearContacts;
- (void)twitterRefreshContactsWithCompletion:(void (^)(void))completion;

// OTHER
+ (NSString*) documentsDirectory;

@end

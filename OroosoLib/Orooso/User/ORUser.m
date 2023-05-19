//
//  OroosoUser.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 6/23/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORUser.h"
#import "ORApiEngine.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "ORStrings.h"

#define REFRESH_CONTACTS_AFTER_SECONDS 600.0f

@implementation ORUser

#pragma mark - Class Methods

- (BOOL)isAnonUser
{
	return [self.userId isEqualToString:@"1"];
}

- (NSString *)defaultBoardId
{
    if (self.isAnonUser) {
        // GA Client ID
        return [ORApiEngine sharedInstance].currentClientID;
    } else {
        // User ID
        return self.userId;
    }
}

+ (NSString*)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)userArchivePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"user.archive"];
}

+ (ORUser*)instanceFromLocallyStoredUser
{
	NSString *path = [ORUser userArchivePath];
	ORUser *result = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
	// If the user hadn't been saved previously, create a new empty one
	if (!result) result = [[ORUser alloc] initAnonUser];

	return result;
}

+ (id)instanceWithJSON:(NSDictionary *)json
{
    return [[self alloc] initWithJSON:json];
}

+ (id)arrayWithJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

#pragma mark - Properties

- (NSString*)description
{
	return [NSString stringWithFormat:
            @"Name:     %@\n"
             "E-mail:   %@\n"
             "PIN:      %@\n"
             "Pairings: %@",
            self.name, self.emailAddress, self.password, self.pairings];
}

#pragma mark - Initialization

- (id)initAnonUser
{
    self = [super init];
    
    if (self) {
        [self setAsAnonUser];
    }
    
    return self;
}

- (id)initWithJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
	self = [self init];
    if (!self) return nil;
	
    self.userId = [json valueForKey:@"UserId"];
    self.emailAddress = [json valueForKey:@"EmailAddress"];
    self.password = [json valueForKey:@"Password"];
    self.name = [json valueForKey:@"Name"];
    self.lastSignIn = [json valueForKey:@"LastSignIn"];
    self.signupDate = [json valueForKey:@"SignupDate"];
    self.enabled = [[json valueForKey:@"Enabled"] boolValue];
    self.profileImageUrl = [json valueForKey:@"ProfileImageUrl"];
    self.optedOutEmails = [[json valueForKey:@"OptedOutEmails"] mutableCopy];
    self.lastNotificationId = [json valueForKey:@"LastNotificationId"];
	
	return self;
}

#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        self.userId = [aDecoder decodeObjectForKey:@"UserId"];
        self.emailAddress = [aDecoder decodeObjectForKey:@"EmailAddress"];
        self.password = [aDecoder decodeObjectForKey:@"Password"];
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.lastSignIn = [aDecoder decodeObjectForKey:@"LastSignIn"];
        self.signupDate = [aDecoder decodeObjectForKey:@"SignupDate"];
        self.profileImageUrl = [aDecoder decodeObjectForKey:@"ProfileImageUrl"];
        self.optedOutEmails = [aDecoder decodeObjectForKey:@"OptedOutEmails"];
        self.lastNotificationId = [aDecoder decodeObjectForKey:@"LastNotificationId"];
        
        NSLog(@"---");
        NSLog(@"User loaded from local storage: %@", self.emailAddress);
        NSLog(@"Name: %@ [%@]", self.name, self.userId);
        NSLog(@"---");
        
        self.pairings = [[aDecoder decodeObjectForKey:@"PairingInfos"] mutableCopy];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userId forKey:@"UserId"];
    [aCoder encodeObject:self.emailAddress forKey:@"EmailAddress"];
    [aCoder encodeObject:self.password forKey:@"Password"];
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.lastSignIn forKey:@"LastSignIn"];
    [aCoder encodeObject:self.signupDate forKey:@"SignupDate"];
    [aCoder encodeObject:self.profileImageUrl forKey:@"ProfileImageUrl"];
    [aCoder encodeObject:self.pairings forKey:@"PairingInfos"];
    [aCoder encodeObject:self.optedOutEmails forKey:@"OptedOutEmails"];
    [aCoder encodeObject:self.lastNotificationId forKey:@"LastNotificationId"];
}

#pragma mark - JSON Encoding

- (NSMutableDictionary *)proxyForJson
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:8];
    
    [json setValue:self.userId forKey:@"UserId"];
    [json setValue:self.emailAddress forKey:@"EmailAddress"];
    [json setValue:self.oldEmailAddress forKey:@"OldEmailAddress"];
    [json setValue:self.password forKey:@"Password"];
    [json setValue:self.name forKey:@"Name"];
    [json setValue:self.signupDate forKey:@"SignupDate"];
    [json setValue:@(self.enabled) forKey:@"Enabled"];
    [json setValue:self.profileImageUrl forKey:@"ProfileImageUrl"];
    [json setValue:self.optedOutEmails forKey:@"OptedOutEmails"];
    [json setValue:self.lastNotificationId forKey:@"LastNotificationId"];

	return json;
}

#pragma mark - Account Pairing

- (BOOL)hasPairingInfoFor:(OAuthService)service
{
    return ([self.pairings objectForKey:[OAuthPairingInfo serviceName:service]] != nil);
}

- (OAuthPairingInfo *)pairingInfoFor:(OAuthService)service
{
    return [self.pairings objectForKey:[OAuthPairingInfo serviceName:service]];
}

- (void)addPairingInfo:(OAuthPairingInfo *)info storeLocal:(BOOL)local storeRemote:(BOOL)remote
{
    // Fill the User ID
    info.parentUserId = self.userId;
    NSLog(@"%@", self.userId);
    
    NSString *serviceName = [OAuthPairingInfo serviceName:info.service];
	if (!self.pairings) self.pairings = [[NSMutableDictionary alloc] init];
    [self.pairings setObject:info forKey:serviceName];
    if (local) [self saveLocalUser];
    
    if (remote) {
        ORApiEngine *api = [ORApiEngine sharedInstance];
        [api storePairing:info cb:^(NSError *error, BOOL result) {
            if (!error) NSLog(@"Pairing Info stored on server: %@", serviceName);
        }];
    }
    
    NSLog(@"Pairing Info added for: %@", serviceName);
}

- (void)addPairingInfo:(OAuthPairingInfo *)info
{
    [self addPairingInfo:info storeLocal:YES storeRemote:YES];
}

- (void)removePairingInfo:(OAuthService)service
{
    NSString *serviceName = [OAuthPairingInfo serviceName:service];
    [self.pairings removeObjectForKey:serviceName];
    [self saveLocalUser];
}

- (void)fillPairingInfos:(NSArray *)infos
{
    self.pairings = [NSMutableDictionary dictionaryWithCapacity:[infos count]];
    for (OAuthPairingInfo *info in infos) [self addPairingInfo:info storeLocal:NO storeRemote:NO];
    [self saveLocalUser];
}

//============================================================================
//
//  PERSISTANCE
//
//============================================================================
#pragma mark - PERSISTANCE

- (void)setAsAnonUser
{
	[self facebookClearContacts];
	[self googleClearContacts];
    [self twitterClearContacts];
    
	self.allContacts = [NSMutableDictionary dictionaryWithCapacity:2];
    [self.allContacts setValue:[[ORContact alloc] initWithDisplayName:@"Connect Facebook" andType:ORContactTypeFacebook_connect] forKey:@"connect_fb"];
    [self.allContacts setValue:[[ORContact alloc] initWithDisplayName:@"Connect Google" andType:ORContactTypeGoogle_connect] forKey:@"connect_go"];
    
    self.pairings = [NSMutableDictionary dictionary];
    self.userId = @"1";
    self.name = nil;
    self.emailAddress = nil;
    self.oldEmailAddress = nil;
    self.password = nil;
    self.signupDate = nil;
    self.lastSignIn = nil;
    self.profileImageUrl = nil;
    self.lastNotificationId = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:nil forKey:@"last_contacts_refresh"];
    [ud synchronize];
}

// INTERFACE

- (void)saveUserWithCompletion:(void (^)(NSError *, ORUser *))completion
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
	[api saveUser:self cb:^(NSError *error, ORUser *user) {
		if (error) {
			DLog(@"ERROR: saveExistingUser: %@", [error localizedDescription]);
		} else {
            if (self.userId && ![self.userId isEqualToString:user.userId]) {
                DLog(@"ERROR: Failed to update user, IDs don't match: %@ - %@", self.userId, user.userId);
            } else {
				if (!self.userId)
					self.userId = user.userId;
                DLog(@"Update user on server result: %@", user.userId);
                [self commitToLocalStorage];
            }
		}
        if (completion) completion(error, user);
	}];
}

- (void)saveLocalUser
{
    [self commitToLocalStorage];
}

- (void)deleteUser
{
	[self removeLocalUser];
}

- (void)removeLocalUser
{
	[ORUser removeUserFromLocalStorage];
	[self googleClearContacts];
	[self facebookClearContacts];
    [self twitterClearContacts];
    [self setAsAnonUser];
}

// LOCAL

- (BOOL)commitToLocalStorage
{
    return [NSKeyedArchiver archiveRootObject:self toFile:[ORUser userArchivePath]];
}

+ (BOOL)removeUserFromLocalStorage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[ORUser userArchivePath] error:NULL];
	return YES;
}

// REMOTE

- (void)removeUserFromRemoteStorage
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
	[api deleteUserByEmail:self.emailAddress withPwHash:self.password cb:^(NSError *error, BOOL result) {
		if (error){
			DLog(@"Failed to remove user from remote storage: %@", [error debugDescription]);
		} else {
			//
		}
	}];
}

- (void)reloadBoardsWithCompletion:(void (^)(NSError *))completion
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
    [api getBoardsWithCompletion:^(NSError *error, NSArray *result) {
        if (error) {
            if (completion) completion(error);
            return;
        }
        
        BOOL foundDefault = NO;
        self.boards = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
        
        for (ORBoard *b in result) {
            if (b.isDefault) foundDefault = YES;
            [self.boards addObject:b];
        }
        
        if (!foundDefault) {
            // Add a default board
            ORBoard *b = [[ORBoard alloc] init];
            b.boardId = self.defaultBoardId;
            b.ownerId = self.userId;
            b.name = @"Favorites";
            b.created = [NSDate date];
            b.isDefault = YES;
            b.isPublic = NO;
            [self.boards insertObject:b atIndex:0];
        }
        
        [self.boards sortUsingComparator:^NSComparisonResult(ORBoard *o1, ORBoard *o2) {
            // 1. Default
            if (o1.isDefault && !o2.isDefault) {
                return NSOrderedAscending;
            } else if (!o1.isDefault && o2.isDefault) {
                return NSOrderedDescending;
            }
            
            // 2. Created
            return [o1.created compare:o2.created];
        }];
        
        if (completion) completion(nil);
    }];
}

- (void)reloadFollowingBoardsWithCompletion:(void (^)(NSError *))completion
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
    [api followingBoardsFor:nil completion:^(NSError *error, NSArray *result) {
        if (error) {
            if (completion) completion(error);
            return;
        }

        self.followingBoards = [NSOrderedSet orderedSetWithArray:result];
        for (ORBoard *board in self.followingBoards) board.isFollowing = YES;
        if (completion) completion(nil);
    }];
}

- (void)reloadFriendsWithCompletion:(void (^)(NSError *))completion
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
    [api followingUsersFor:nil completion:^(NSError *error, NSArray *result) {
        if (error) {
            if (completion) completion(error);
            return;
        }
        
        if (!self.relatedUsers) self.relatedUsers = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
        self.friends = [NSMutableArray arrayWithCapacity:result.count];
        
        for (ORFriend *f in result) {
            NSUInteger idx = [self.relatedUsers indexOfObject:f];
            
            if (idx != NSNotFound) {
                ORFriend *existing = [self.relatedUsers objectAtIndex:idx];
                [existing updateWithUser:f isFollowing:YES isFollower:NO];
                
                [self.friends addObject:existing];
            } else {
                f.isFollowing = YES;
                
                [self.relatedUsers addObject:f];
                [self.friends addObject:f];
            }
        }
        
        if (completion) completion(nil);
    }];
}

- (void)reloadFollowersWithCompletion:(void (^)(NSError *))completion
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
    [api followersForUser:nil completion:^(NSError *error, NSArray *result) {
        if (error) {
            if (completion) completion(error);
            return;
        }
        
        if (!self.relatedUsers) self.relatedUsers = [NSMutableOrderedSet orderedSetWithCapacity:result.count];
        self.followers = [NSMutableArray arrayWithCapacity:result.count];
        
        for (ORFriend *f in result) {
            NSUInteger idx = [self.relatedUsers indexOfObject:f];
            
            if (idx != NSNotFound) {
                ORFriend *existing = [self.relatedUsers objectAtIndex:idx];
                [existing updateWithUser:f isFollowing:NO isFollower:YES];
                
                [self.followers addObject:existing];
            } else {
                f.isFollower = YES;
                
                [self.relatedUsers addObject:f];
                [self.followers addObject:f];
            }
        }
        
        if (completion) completion(nil);
    }];
}

- (ORFriend *)relatedUserWithUser:(ORFriend *)user
{
    NSUInteger idx = [self.relatedUsers indexOfObject:user];
    if (idx == NSNotFound) return nil;
    return [self.relatedUsers objectAtIndex:idx];
}

//============================================================================
//
//  CONTACTS
//
//============================================================================
#pragma mark - CONTACTS

- (void)refreshContacts
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *lastRefresh = [ud objectForKey:@"last_contacts_refresh"];
    
    // Check if we should refresh contacts now
    if (lastRefresh && [lastRefresh isKindOfClass:[NSDate class]]) {
        NSTimeInterval i = [[NSDate date] timeIntervalSinceDate:lastRefresh];
        if (i < REFRESH_CONTACTS_AFTER_SECONDS) {
            NSLog(@"Only %d minutes passed since last contact refresh, loading from local data.", (int)(i / 60));
            [self fillContactsArrayFromLocalStorage];
            return;
        }
    }
    
    NSLog(@"Refreshing contacts...");
    
    // Refresh contacts
    [self facebookRefreshContactsWithCompletion:^{
        [self googleRefreshContactsWithCompletion:^{
            [self twitterRefreshContactsWithCompletion:^{
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSDate *lastRefresh = [NSDate date];
                [ud setObject:lastRefresh forKey:@"last_contacts_refresh"];
                [ud synchronize];
                
                [self fillContactsArrayFromLocalStorage];
            }];
        }];
    }];
}

- (void)fillContactsArrayFromLocalStorage
{
    self.hasContacts = NO;
    
    if (!self.googleContacts) {
        NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"googleContacts.dat"];
		
        // Load Google contacts from a previously stored file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			@try {
				self.googleContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
				NSLog(@"Google contacts loaded: %d", [self.googleContacts count]);
			}
			@catch (NSException *ex) {
				[self googleClearContacts];
				NSLog(@"Failed to load Google contacts from local store (corrupted possibly or class schema changed?)");
			}
        }
    }
	
    if (!self.facebookContacts) {
        NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"facebookContacts.dat"];
        
        // Load Facebook contacts from a previously stored file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			@try {
				self.facebookContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
				NSLog(@"Facebook contacts loaded: %d", [self.facebookContacts count]);
			}
			@catch (NSException *exception) {
				[self facebookClearContacts];
				NSLog(@"Failed to load Facebook contacts from local store (corrupted possibly or class schema changed?");
			}
        }
    }

    if (!self.twitterContacts) {
        NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"twitterContacts.dat"];
        
        // Load Twitter contacts from a previously stored file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			@try {
				self.twitterContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
				NSLog(@"Twitter contacts loaded: %d", [self.twitterContacts count]);
			}
			@catch (NSException *exception) {
				[self twitterClearContacts];
				NSLog(@"Failed to load Twitter contacts from local store (corrupted possibly or class schema changed?");
			}
        }
    }
	
    // Join all contacts in one array
    self.allContacts = [NSMutableDictionary dictionaryWithCapacity:[self.googleContacts count] + [self.facebookContacts count] + [self.twitterContacts count]];
    
    [self loadAddressBookContacts];
    for (ORContact *c in self.googleContacts) self.allContacts[c.contactHash] = c;
    for (ORContact *c in self.facebookContacts) self.allContacts[c.contactHash] = c;
    for (ORContact *c in self.twitterContacts) self.allContacts[c.contactHash] = c;
    
    self.hasContacts = (self.allContacts.count > 0);
    
    if (!self.facebookContacts) [self.allContacts setValue:[[ORContact alloc] initWithDisplayName:@"Connect Facebook" andType:ORContactTypeFacebook_connect] forKey:@"connect_fb"];
    if (!self.googleContacts) [self.allContacts setValue:[[ORContact alloc] initWithDisplayName:@"Connect Google" andType:ORContactTypeGoogle_connect] forKey:@"connect_go"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsUpdated" object:nil];
}
    
- (void)loadAddressBookContacts
{
    // Check for AB Authorization Status
    if (ABAddressBookGetAuthorizationStatus != NULL) {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status != kABAuthorizationStatusAuthorized) return;
    }
    
    // Already authorized, load the contacts
    ABAddressBook *ab = [ABAddressBook sharedAddressBook];
    NSArray *items = [ab allPeopleSorted];
    
    // Add contacts from Address Book
    for (ABPerson *person in items) {
        ORContact *contact = [[ORContact alloc] initWithABPerson:person];
        if (contact) self.allContacts[contact.contactHash] = contact;
    }
}

#pragma mark - Facebook Contacts

- (void)facebookClearContacts
{
    self.facebookContacts = nil;
	
    // Remove Facebook contacts file
    NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"facebookContacts.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
	[self fillContactsArrayFromLocalStorage];
}

- (void)facebookRefreshContactsWithCompletion:(void (^)(void))completion;
{
    ORFacebookEngine *facebook = [ORFacebookEngine sharedInstance];
    if (!facebook.isAuthenticated) { if (completion) completion(); return; }
    
    [facebook listContactsWithCompletion:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
            
            if (error.code == 400 || error.code == 401) {
                // Lost Facebook Pairing
                OAuthPairingInfo *info = [self pairingInfoFor:OAuthServiceFacebook];
                
                [[ORApiEngine sharedInstance] removePairing:info cb:^(NSError *error, BOOL result) {
                    if (error) {
                        NSLog(@"ERROR: removePairingForUser: %@", [error localizedDescription]);
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:orServiceUnpaired object:@"facebook"];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:orServiceUnpaired object:@"facebook"];
                }];
                
                [self removePairingInfo:OAuthServiceFacebook];
                [facebook resetOAuthToken];
                
                self.facebookContacts = nil;
                
                // Remove Facebook contacts file
                NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"facebookContacts.dat"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                }
            }
        } else {
            self.facebookContacts = items;
            
            // Store Facebook contacts in a file
            NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"facebookContacts.dat"];
            if ([NSKeyedArchiver archiveRootObject:self.facebookContacts toFile:path]) {
                NSLog(@"Facebook contacts stored: %d", [items count]);
            }
        }
        
        if (completion) {
            completion();
        } else {
            [self fillContactsArrayFromLocalStorage];
        }
    }];
}

#pragma mark - Google Contacts

- (void)googleClearContacts
{
    self.googleContacts = nil;
	
    // Remove Google contacts file
    NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"googleContacts.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
	[self fillContactsArrayFromLocalStorage];
}

- (void)googleRefreshContactsWithCompletion:(void (^)(void))completion;
{
    ORGoogleEngine *google = [ORGoogleEngine sharedInstance];
    if (!google.isAuthenticated) { if (completion) completion(); return; }
    
    [google listContactsWithCompletion:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error (Google): %@", [error localizedDescription]);
        } else {
			// FILTER OUT CONTACTS WITH INVALID EMAIL ADDRESSES
			BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
			NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
			NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
			NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
			NSError *error = NULL;
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailRegex options:NSRegularExpressionCaseInsensitive error:&error];
			NSTextCheckingResult *match;
			NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];
			for (ORContact *contact in items) {
				if (contact.email) {
					match = [regex firstMatchInString:contact.email options:0 range:NSMakeRange(0, [contact.email length])];
					if (!match) [itemsToRemove addObject:contact];
				}
			}
			NSMutableArray *newItems = [items mutableCopy];
			[newItems removeObjectsInArray:itemsToRemove];
			// END FILTER
			
			self.googleContacts = newItems;
			
            // Store Google contacts in a file
            NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"googleContacts.dat"];
            if ([NSKeyedArchiver archiveRootObject:self.googleContacts toFile:path]) {
                NSLog(@"Google contacts stored: %d", [newItems count]);
            }
        }
        
        if (completion) {
            completion();
        } else {
            [self fillContactsArrayFromLocalStorage];
        }
    }];
}

#pragma mark - Twitter Contacts

- (void)twitterClearContacts
{
    self.twitterContacts = nil;
	
    // Remove Twitter contacts file
    NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"twitterContacts.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
	[self fillContactsArrayFromLocalStorage];
}

- (void)twitterRefreshContactsWithCompletion:(void (^)(void))completion;
{
    ORTwitterEngine *twitter = [ORTwitterEngine sharedInstance];
    if (!twitter.isAuthenticated) { if (completion) completion(); return; }
    
    [twitter listContactsWithCompletion:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error (Twitter): %@", [error localizedDescription]);
        } else {
            self.twitterContacts = items;
            
            // Store Twitter contacts in a file
            NSString *path = [[ORUser documentsDirectory] stringByAppendingPathComponent:@"twitterContacts.dat"];
            if ([NSKeyedArchiver archiveRootObject:self.twitterContacts toFile:path]) {
                NSLog(@"Twitter contacts stored: %d", [items count]);
            }
        }

        if (completion) {
            completion();
        } else {
            [self fillContactsArrayFromLocalStorage];
        }
    }];
}

//============================================================================
//
//  PAIRING ACCESSORS
//
//============================================================================
#pragma mark - PAIRING ACCESSORS

- (OAuthPairingInfo*)twitterPairingInfo{
	return [self pairingInfoFor:OAuthServiceTwitter];
}

- (OAuthPairingInfo*)googlePairingInfo{
	return [self pairingInfoFor:OAuthServiceGoogle];
}

- (OAuthPairingInfo*)facebookPairingInfo{
	return [self pairingInfoFor:OAuthServiceFacebook];
}

- (OAuthPairingInfo*)attPairingInfo{
	return [self pairingInfoFor:OAuthServiceATT];
}

@end

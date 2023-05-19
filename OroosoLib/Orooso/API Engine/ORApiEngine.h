//
//  ORApiEngine.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 11/30/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <OroosoLib/OroosoLib.h>
#import "MKNetworkEngine.h"
#import "OREntity.h"

@class AVAudioPlayer, ORUser, ORLogItem, OAuthPairingInfo, OREntity, ORSFItem, ORImage, ORBoard, ORFriend, ORBoardItem, ORSpotShare, ORSpotLocation, ORITunesApp;

typedef void (^ORArrayCompletion)(NSError *error, NSArray *result);
typedef void (^ORDictionaryCompletion)(NSError *error, NSDictionary *result);
typedef void (^ORIntegerCompletion)(NSError *error, NSInteger httpStatusCode);
typedef void (^ORUserCompletion)(NSError *error, ORUser *userSignedIn);
typedef void (^ORBoolCompletion)(NSError *error, BOOL result);
typedef void (^OREntityCompletion)(NSError *error, OREntity *title);
typedef void (^ORStringCompletion)(NSError *error, NSString *result);
typedef void (^ORURLCompletion)(NSError *error, ORURL *finalURL);
typedef void (^ORImageCompletion)(NSError *error, ORImage *image);
typedef void (^ORBoardCompletion)(NSError *error, ORBoard *board);
typedef void (^ORFriendCompletion)(NSError *error, ORFriend *user);
typedef void (^ORSFItemCompletion)(NSError *error, ORSFItem *item);
typedef void (^ORSpotCompletion)(NSError *error, ORSpotShare *item);
typedef void (^ORAppCompletion)(NSError *error, ORITunesApp *item);

typedef enum {
	All = 0,
	TVShow = 1,
	Movie = 2,
	Person = 3,
	TVChannel = 4
} EntityType;

typedef enum {
	MerchListRecent,
	MerchListPopular,
	MerchListNew,
	MerchListFriends,
	MerchListNearBy,
	MerchListRecommended
} MerchList;

@interface ORApiEngine : MKNetworkEngine

@property (copy, nonatomic) NSString *baseURLString;
@property (copy, nonatomic) NSString *currentUserID;
@property (copy, nonatomic) NSString *currentSessionID;
@property (copy, nonatomic) NSString *currentClientID;
@property (copy, nonatomic) NSString *currentAppCode;
@property (copy, nonatomic) NSString *defaultBoardId;
@property (copy, nonatomic) NSString *currentDeviceID;

+ (ORApiEngine *)sharedInstance;
+ (ORApiEngine *)sharedInstanceWithHostname:(NSString *)hostName portNumber:(NSUInteger)portNumber useSSL:(BOOL)useSSL;
- (id)initWithHostname:(NSString *)hostName portNumber:(NSUInteger)portNumber useSSL:(BOOL)useSSL;

// Instant Results
- (MKNetworkOperation *)instantResults:(NSString *)query cb:(ORArrayCompletion)completion;

// Strings
- (MKNetworkOperation *)clientStringForKey:(NSString *)key cb:(ORStringCompletion)completion;
- (MKNetworkOperation *)clientStringsForKeys:(NSArray *)keys cb:(ORDictionaryCompletion)completion;

// CONTENT
- (MKNetworkOperation *)fetchEntity:(NSString *)entityId entityType:(OREntityType)entityType cb:(OREntityCompletion)completionBlock;
- (MKNetworkOperation *)touchEntity:(NSString *)entityId entityType:(OREntityType)entityType cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)requestEntityNamed:(NSString *)entityName cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)matchEntityNamed:(NSString *)entityName mid:(NSString *)mid cb:(OREntityCompletion)completionBlock;
- (MKNetworkOperation *)itunesSearch:(NSString *)query entityType:(OREntityType)entityType page:(NSUInteger)page count:(NSUInteger)count explicit:(BOOL)explicit cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)blacklistVideoID:(NSString *)videoID cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)youTubeLiveEvents:(NSUInteger)page count:(NSUInteger)count cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)tvnzVideos:(NSUInteger)page count:(NSUInteger)count cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)getFeedWithCompletion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)getHistoryWithCompletion:(ORArrayCompletion)completionBlock;

- (MKNetworkOperation *)fetchContent:(NSString *)entityId
                          entityType:(OREntityType)entityType
                       maturityLevel:(NSUInteger)maturityLevel
                             country:(NSString *)country
                            language:(NSString *)language
                                page:(NSUInteger)page
                            latitude:(double)latitude
                           longitude:(double)longitude
                                  cb:(ORArrayCompletion)completion;

- (MKNetworkOperation *)fetchDynamicContent:(NSString *)entityName
                              maturityLevel:(NSUInteger)maturityLevel
                                    country:(NSString *)country
                                   language:(NSString *)language
                                       page:(NSUInteger)page
                                   latitude:(double)latitude
                                  longitude:(double)longitude
                                         cb:(ORArrayCompletion)completion;

// IMAGES
- (MKNetworkOperation *)imageQuery:(NSString *)queryString page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)imageQueryMultiple:(NSArray *)queries page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)representativeImage:(NSString *)query cb:(ORImageCompletion)completionBlock;

// USER
- (MKNetworkOperation *)signInUserEmail:(NSString *)userEmail withPwHash:(NSString *)userPwHash cb:(ORUserCompletion)completionBlock;
- (MKNetworkOperation *)reauthUserEmail:(NSString *)userEmail withPwHash:(NSString *)userPwHash cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)saveUser:(ORUser *)user cb:(ORUserCompletion)completionBlock;
- (MKNetworkOperation *)deleteUserByEmail:(NSString *)userEmail withPwHash:(NSString *)userPwHash cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)storePairing:(OAuthPairingInfo *)pairInfo cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)listPairingsWithCompletion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)removePairing:(OAuthPairingInfo *)pairInfo cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)userForgotPassword:(NSString *)userEmail cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)clearHistoryWithCompletion:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)emailTypesWithCompletion:(ORArrayCompletion)completion;
- (MKNetworkOperation *)saveOptedOutEmails:(NSArray *)emails cb:(ORBoolCompletion)completion;
- (MKNetworkOperation *)registerDeviceForPush:(NSString *)deviceID cb:(ORBoolCompletion)completion;
- (MKNetworkOperation *)notificationsSince:(NSString *)lastSeenId completion:(ORArrayCompletion)completion;
- (MKNetworkOperation *)inviteFriends:(NSArray *)friends sender:(ORContactItem*)sender completion:(ORBoolCompletion)completionBlock;

// FEEDBACK
- (MKNetworkOperation *)sendFeedback:(NSString *)feedback emailAddress:(NSString*)emailAddress cb:(ORBoolCompletion)completionBlock;

// ADMIN
- (MKNetworkOperation *)getSettingNamed:(NSString*)settingName completion:(ORStringCompletion)completionBlock;
- (MKNetworkOperation *)getAppWithBundleId:(NSString *)bundleId completion:(ORAppCompletion)completion;

// LOGGING
- (MKNetworkOperation *)startSessionWithCB:(ORStringCompletion)completionBlock;
- (MKNetworkOperation *)postLogItem:(ORLogItem *)logItem cb:(ORIntegerCompletion)completionBlock;
- (MKNetworkOperation *)postLogItems:(NSArray*)logItems cb:(ORIntegerCompletion)completionBlock;

// BOARDS
- (MKNetworkOperation *)getBoardsWithCompletion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)getBoard:(NSString *)boardId cb:(ORBoardCompletion)completionBlock;
- (MKNetworkOperation *)saveBoard:(ORBoard *)board cb:(ORBoardCompletion)completionBlock;
- (MKNetworkOperation *)deleteBoard:(NSString *)boardId cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)getBoardItems:(NSString *)boardId cb:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)saveBoardItem:(ORBoardItem *)item cb:(ORStringCompletion)completionBlock;
- (MKNetworkOperation *)removeItemFromBoard:(NSString *)boardId itemId:(NSString *)itemId newImageURL:(NSString *)imageURL cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)publicBoardsFor:(NSString *)userId completion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)boardsForItem:(NSString *)itemId cb:(ORArrayCompletion)completionBlock;

// Graph
- (MKNetworkOperation *)followUser:(NSString *)userId completion:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)followBoard:(NSString *)boardId completion:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)unfollowUser:(NSString *)userId completion:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)unfollowBoard:(NSString *)boardId completion:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)followingUsersFor:(NSString *)userId completion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)followingBoardsFor:(NSString *)userId completion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)followersForUser:(NSString *)userId completion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)followersForBoard:(NSString *)boardId completion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)activityFeedWithCompletion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)usersForHashes:(NSArray *)hashes completion:(ORArrayCompletion)completionBlock;
- (MKNetworkOperation *)getFriend:(NSString *)friendId completion:(ORFriendCompletion)completionBlock;

// URL Handling
- (MKNetworkOperation *)resolveURL:(NSString *)url cb:(ORURLCompletion)completion;
- (MKNetworkOperation *)resolveURLs:(NSArray *)urls cb:(ORArrayCompletion)completion;
- (MKNetworkOperation *)submitURL:(ORURL *)url cb:(ORBoolCompletion)completionBlock;
- (MKNetworkOperation *)shortenURL:(NSString *)url cb:(ORStringCompletion)completion;

// SpotMe
- (MKNetworkOperation *)shareSpot:(ORSpotShare *)spot cb:(ORStringCompletion)completion;
- (MKNetworkOperation *)updateSpots:(ORSpotLocation *)spot cb:(ORBoolCompletion)completion;
- (MKNetworkOperation *)loadSpot:(NSString *)spotShareID cb:(ORSpotCompletion)completion;
- (MKNetworkOperation *)loadSpotLocations:(NSArray *)spotShareIDs cb:(ORArrayCompletion)completion;
- (MKNetworkOperation *)removeSpot:(NSString *)spotShareID cb:(ORBoolCompletion)completion;
- (MKNetworkOperation *)resendSpot:(NSString *)spotShareID cb:(ORBoolCompletion)completion;

@end

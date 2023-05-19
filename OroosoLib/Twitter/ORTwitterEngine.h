//
//  ORTwitterEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/8/11.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.

#import "RSOAuthEngine.h"

@protocol ORTwitterEngineDelegate;

@class ACAccount, ORTweet, ORTwitterUser, ORTwitterUserRelationship;

typedef void (^ORTwitterEngineCompletionBlock)(NSError *error);
typedef void (^ORSingleTweetCompletionBlock)(NSError *error, ORTweet *tweet);
typedef void (^ORTwitterArrayCompletionBlock)(NSError *error, NSArray *items);
typedef void (^ORUserCompletionBlock)(NSError *error, ORTwitterUser *user);
typedef void (^ORUserRelationshipsCompletion)(NSError *error, ORTwitterUserRelationship *followState);
typedef void (^ORUserFollowActionCompletion)(NSError *error, BOOL success);

@interface ORTwitterEngine : RSOAuthEngine
{
    ORTwitterEngineCompletionBlock _oAuthCompletionBlock;
}

@property (readonly) NSString *callbackURL;
@property (weak) id <ORTwitterEngineDelegate> delegate;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *screenName;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *profilePicture;
@property (readonly, nonatomic) BOOL isStreaming;

+ (ORTwitterEngine *)sharedInstance;
+ (ORTwitterEngine *)sharedInstanceWithConsumerKey:(NSString *)consumerKey andSecret:(NSString *)secret;
- (id)initWithConsumerKey:(NSString *)consumerKey andSecret:(NSString *)secret;

- (void)existingAccountsWithCompletion:(ORTwitterArrayCompletionBlock)completion;
- (void)reverseAuthWithAccount:(ACAccount *)account completion:(ORTwitterEngineCompletionBlock)completion;
- (void)authenticateWithCompletion:(ORTwitterEngineCompletionBlock)completion;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;

- (void)startStreamingStatuses:(NSString *)keywords andAccountIds:(NSString*)accountIds completion:(ORTwitterEngineCompletionBlock)completion;
- (void)stopStreaming;

- (MKNetworkOperation *)getProfileWithCompletion:(ORTwitterEngineCompletionBlock)completion;
- (MKNetworkOperation *)homeTimeline:(NSUInteger)count maxID:(u_int64_t)maxID sinceID:(u_int64_t)sinceID completion:(ORTwitterArrayCompletionBlock)completion;
- (MKNetworkOperation *)userTimeline:(NSString *)user count:(NSUInteger)count completion:(ORTwitterArrayCompletionBlock)completion;
- (MKNetworkOperation *)searchTweets:(NSString *)filter count:(NSUInteger)count maxID:(u_int64_t)maxID sinceID:(u_int64_t)sinceID completion:(ORTwitterArrayCompletionBlock)completion;
- (MKNetworkOperation *)conversationTweetsRelatedTo:(u_int64_t)tweetID count:(NSUInteger)count completion:(ORTwitterArrayCompletionBlock)completion;

- (MKNetworkOperation *)postTweet:(NSString *)tweet completion:(ORTwitterEngineCompletionBlock)completion;
- (MKNetworkOperation *)postTweet:(NSString *)tweet inReplyTo:(u_int64_t)tweetID completion:(ORTwitterEngineCompletionBlock)completion;
- (MKNetworkOperation *)postTweet:(NSString *)tweet withImage:(UIImage *)image completion:(ORTwitterEngineCompletionBlock)completion;
- (MKNetworkOperation *)destroyId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion;
- (MKNetworkOperation *)retweetId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion;
- (MKNetworkOperation *)favoriteId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion;
- (MKNetworkOperation *)unfavoriteId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion;

- (MKNetworkOperation *)fetchUserProfileForScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserCompletionBlock)completion;
- (MKNetworkOperation *)fetchUserProfilesForScreenNames:(NSArray*)screenNames completion:(ORTwitterArrayCompletionBlock)completion;
- (MKNetworkOperation *)userRelationshipsWithScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserRelationshipsCompletion)completion;
- (MKNetworkOperation *)userFollowScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserFollowActionCompletion)completion;
- (MKNetworkOperation *)userUnfollowScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserFollowActionCompletion)completion;

- (MKNetworkOperation *)listContactsWithCompletion:(ORTwitterArrayCompletionBlock)completion;

- (NSMutableArray *)validateTweets:(NSArray *)tweets;
- (BOOL)validateTweet:(ORTweet *)tweet;

@end

@protocol ORTwitterEngineDelegate <NSObject>

- (void)twitterEngine:(ORTwitterEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)twitterEngine:(ORTwitterEngine *)engine statusUpdate:(NSString *)message;
- (void)twitterEngine:(ORTwitterEngine *)engine newTweet:(ORTweet *)tweet;

@end
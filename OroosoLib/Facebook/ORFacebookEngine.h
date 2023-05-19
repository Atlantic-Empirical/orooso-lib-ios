//
//  ORFacebookEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 06/15/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.

#import "MKNetworkKit.h"

@protocol ORFacebookEngineDelegate;

typedef void (^ORFacebookEngineCompletionBlock)(NSError *error);
typedef void (^ORFacebookContactsCompletionBlock)(NSError *error, NSArray *items);

@interface ORFacebookEngine : MKNetworkEngine
{
    ORFacebookEngineCompletionBlock _oAuthCompletionBlock;
}

+ (NSString *)facebookAppID;
+ (ORFacebookEngine *)sharedInstance;
- (id)initWithDelegate:(id <ORFacebookEngineDelegate>)delegate;

@property (readonly) NSString *callbackURL;
@property (weak) id <ORFacebookEngineDelegate> delegate;

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSDate *expirationTime;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *profilePicture;
@property (copy, nonatomic) NSString *optionalPermissions;

- (void)authenticateWithCompletion:(ORFacebookEngineCompletionBlock)completion;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (BOOL)isAuthenticated;
- (void)resetOAuthToken;
- (void)getProfileWithCompletion:(ORFacebookEngineCompletionBlock)completion;
- (void)listContactsWithCompletion:(ORFacebookContactsCompletionBlock)completion;

//- (void)postMessage:(NSString *)message completion:(ORFacebookEngineCompletionBlock)completion;
//- (void)postImage:(UIImage *)image withMessage:(NSString *)message completion:(ORFacebookEngineCompletionBlock)completion;
//- (void)postMessage:(NSString *)message toWallForUserID:(NSString *)userID completion:(ORFacebookEngineCompletionBlock)completion;

- (void)postImage:(UIImage *)image withMessage:(NSString *)message toWallForUserID:(NSString *)userID completion:(ORFacebookEngineCompletionBlock)completion;
- (void)postMessage:(NSString*)message withLink:(NSString*)link andLinkName:(NSString*)name andCaption:(NSString*)caption andDescription:(NSString*)description andPictureUrl:(NSString*)picture toWallForUserID:(NSString *)userID completion:(ORFacebookEngineCompletionBlock)completion;

@end

@protocol ORFacebookEngineDelegate <NSObject>

- (void)facebookEngine:(ORFacebookEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)facebookEngine:(ORFacebookEngine *)engine statusUpdate:(NSString *)message;

@end

//
//  ORInstagramEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 06/10/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.

#import "MKNetworkKit.h"

@protocol ORInstagramEngineDelegate;
@class ORInstagramUser;

typedef void (^ORIGCompletion)(NSError *error);
typedef void (^ORIGUserCompletion)(NSError *error, ORInstagramUser *user);
typedef void (^ORIGArrayCompletion)(NSError *error, NSArray *items, NSString *nextID);

@interface ORInstagramEngine : MKNetworkEngine
{
    ORIGCompletion _oAuthCompletionBlock;
}

+ (ORInstagramEngine *)sharedInstance;
- (id)initWithDelegate:(id <ORInstagramEngineDelegate>)delegate;

@property (readonly) NSString *callbackURL;
@property (weak) id <ORInstagramEngineDelegate> delegate;

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *profilePicture;
@property (copy, nonatomic) NSString *optionalPermissions;

- (void)authenticateWithCompletion:(ORIGCompletion)completion;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (BOOL)isAuthenticated;
- (void)resetOAuthToken;

- (MKNetworkOperation *)getUserID:(NSString *)userID completion:(ORIGUserCompletion)completion;
- (MKNetworkOperation *)getImagesForTag:(NSString *)tag minID:(NSString *)minID maxID:(NSString *)maxID completion:(ORIGArrayCompletion)completion;
- (MKNetworkOperation *)getImagesForLat:(CGFloat)lat Lng:(CGFloat)lng completion:(ORIGArrayCompletion)completion;

@end

@protocol ORInstagramEngineDelegate <NSObject>

- (void)instagramEngine:(ORInstagramEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)instagramEngine:(ORInstagramEngine *)engine statusUpdate:(NSString *)message;

@end

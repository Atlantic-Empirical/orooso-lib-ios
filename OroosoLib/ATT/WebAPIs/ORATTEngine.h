//
//  ORATTEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 08/07/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "MKNetworkKit.h"

@protocol ORATTEngineDelegate;

typedef void (^ORATTEngineCompletionBlock)(NSError *error);

@interface ORATTEngine : MKNetworkEngine
{
    ORATTEngineCompletionBlock _oAuthCompletionBlock;
}

@property (readonly) NSString *callbackURL;
@property (weak) id <ORATTEngineDelegate> delegate;
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *refreshToken;
@property (copy, nonatomic) NSDate *expirationTime;

- (id)initWithDelegate:(id <ORATTEngineDelegate>)delegate;
- (void)authenticateWithCompletion:(ORATTEngineCompletionBlock)completion;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (void)resetOAuthToken;
- (BOOL)isAuthenticated;

- (void)sendSMS:(NSString *)message toNumbers:(NSArray *)numbers withCompletion:(ORATTEngineCompletionBlock)completion;
- (void)sendSMS:(NSString *)message toNumber:(NSString *)number withCompletion:(ORATTEngineCompletionBlock)completion;
- (void)sendMMS:(NSString *)message subject:(NSString *)subject numbers:(NSArray *)numbers image:(UIImage *)image completion:(ORATTEngineCompletionBlock)completion;
- (void)sendMMS:(NSString *)message subject:(NSString *)subject number:(NSString *)number image:(UIImage *)image completion:(ORATTEngineCompletionBlock)completion;

- (void)getMessagesWithCompletion:(ORATTEngineCompletionBlock)completion;

@end

@protocol ORATTEngineDelegate <NSObject>

- (void)attEngine:(ORATTEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)attEngine:(ORATTEngine *)engine statusUpdate:(NSString *)message;

@end

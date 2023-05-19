//
//  ORVimeoEngine.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 6/9/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "RSOAuthEngine.h"

@protocol ORVimeoEngineDelegate;

typedef void (^ORVimeoEngineCompletion)(NSError *error);
typedef void (^ORVimeoArrayCompletion)(NSError *error, NSArray *items);

@interface ORVimeoEngine : RSOAuthEngine
{
    ORVimeoEngineCompletion _oAuthCompletionBlock;
}

@property (readonly) NSString *callbackURL;
@property (weak) id <ORVimeoEngineDelegate> delegate;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;

+ (ORVimeoEngine *)sharedInstance;
- (id)initWithDelegate:(id <ORVimeoEngineDelegate>)delegate;

- (void)authenticateWithCompletion:(ORVimeoEngineCompletion)completion;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;

- (MKNetworkOperation *)getProfileWithCompletion:(ORVimeoEngineCompletion)completion;
- (MKNetworkOperation *)fetchVideosForString:(NSString *)query page:(NSUInteger)page count:(NSUInteger)count cb:(ORVimeoArrayCompletion)completion;

@end

@protocol ORVimeoEngineDelegate <NSObject>

- (void)vimeoEngine:(ORVimeoEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)vimeoEngine:(ORVimeoEngine *)engine statusUpdate:(NSString *)message;

@end

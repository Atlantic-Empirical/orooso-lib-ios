//
//  ORGoogleEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/19/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.

#import "RSOAuthEngine.h"

@class ORContact;

@protocol ORGoogleEngineDelegate;

typedef void (^ORGoogleEngineCompletionBlock)(NSError *error);
typedef void (^ORGoogleContactsCompletionBlock)(NSError *error, NSArray *items);
typedef void (^ORGoogleStringCompletionBlock)(NSError *error, NSString *item);
typedef void (^ORGoogleImageCompletionBlock)(NSError *error, UIImage *item);
typedef void (^ORGoogleContactCompletionBlock)(NSError *error, ORContact *item);

@interface ORGoogleEngine : RSOAuthEngine
{
    ORGoogleEngineCompletionBlock _oAuthCompletionBlock;
    ORGoogleEngineCompletionBlock _smtpCompletionBlock;
}

@property (readonly) NSString *callbackURL;
@property (weak) id <ORGoogleEngineDelegate> delegate;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *userEmail;
@property (copy, nonatomic) NSString *profilePicture;
@property (copy, nonatomic) NSString *mainContactsGroup;

+ (ORGoogleEngine *)sharedInstance;
- (id)initWithDelegate:(id <ORGoogleEngineDelegate>)delegate;
- (void)authenticateWithCompletion:(ORGoogleEngineCompletionBlock)completion;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (void)getProfileWithCompletion:(ORGoogleEngineCompletionBlock)completion;
- (void)listGroupsWithCompletion:(ORGoogleContactsCompletionBlock)completion;
- (void)listContactsWithCompletion:(ORGoogleContactsCompletionBlock)completion;
- (void)sendMessageTo:(NSString *)to subject:(NSString *)subject body:(NSString *)body completion:(ORGoogleEngineCompletionBlock)completion;
- (void)sendMessageTo:(NSString *)to subject:(NSString *)subject body:(NSString *)body bodyIsHTML:(BOOL)html attachImage:(UIImage*)image completion:(ORGoogleEngineCompletionBlock)completion;
- (void)shortenURL:(NSString *)url completion:(ORGoogleStringCompletionBlock)completion;
- (void)imageForContactWithURL:(NSString *)url completion:(ORGoogleImageCompletionBlock)completion;
- (void)getSearchSuggestionFor:(NSString *)queryString completion:(ORGoogleStringCompletionBlock)completion;
- (void)addContact:(ORContact *)contact completion:(ORGoogleContactCompletionBlock)completion;

@end

@protocol ORGoogleEngineDelegate <NSObject>

- (void)googleEngine:(ORGoogleEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)googleEngine:(ORGoogleEngine *)engine statusUpdate:(NSString *)message;

@end

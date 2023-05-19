//
//  ORVimeoEngine.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 6/9/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORVimeoEngine.h"
#import "ORVimeoVideo.h"

#define V_APP_ID @"bbfe631ef3faefd7f1e307b55efa61718923eaa8"
#define V_APP_SECRET @"ec80eace37c1107f494279979d03000219d14f57"
#define V_APP_DISPLAY_NAME @"Portl"

// This will be called after the user authorizes your app
#define V_CALLBACK_URL @"http://portl.it/vimeo_oauth_callback"

// Default hostnames and paths
#define V_HOSTNAME @"vimeo.com"
#define V_REQUEST_TOKEN @"oauth/request_token"
#define V_ACCESS_TOKEN @"oauth/access_token"
#define V_API_ROOT @"api/rest/v2"

// URL to redirect the user for authentication
#define V_AUTHORIZE(__TOKEN__) [NSString stringWithFormat:@"https://vimeo.com/oauth/authorize?oauth_token=%@", __TOKEN__]

@interface ORVimeoEngine ()

@end

@implementation ORVimeoEngine

#pragma mark - Read-only Properties

- (NSString *)callbackURL
{
    return V_CALLBACK_URL;
}

#pragma mark - Initialization

+ (ORVimeoEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORVimeoEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORVimeoEngine alloc] initWithDelegate:nil];
    });
    
    return shared;
}

- (id)initWithDelegate:(id <ORVimeoEngineDelegate>)delegate
{
    self = [super initWithHostName:V_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:RSOAuthHMAC_SHA1
                       consumerKey:V_APP_ID
                    consumerSecret:V_APP_SECRET
                       callbackURL:V_CALLBACK_URL];
	
    if (self) {
        _oAuthCompletionBlock = nil;
        _delegate = delegate;
        
        _userID = nil;
        _userName = nil;
    }
    
    return self;
}

#pragma mark - Authentication

- (void)authenticateWithCompletion:(ORVimeoEngineCompletion)completion
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completion copy];
    
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];
    
    // OAuth Step 1 - Obtain a request token
    MKNetworkOperation *op = [self operationWithPath:V_REQUEST_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the request token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthRequestToken];
		
        // OAuth Step 2 - Redirect user to authorization page
        if ([self.delegate respondsToSelector:@selector(vimeoEngine:statusUpdate:)]) {
            [self.delegate vimeoEngine:self statusUpdate:@"Waiting for user authorization..."];
        }
        
        NSURL *url = [NSURL URLWithString:V_AUTHORIZE(self.token)];
        
        if ([self.delegate respondsToSelector:@selector(vimeoEngine:needsToOpenURL:)]) {
            [self.delegate vimeoEngine:self needsToOpenURL:url];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
        _oAuthCompletionBlock = nil;
    }];
    
    if ([self.delegate respondsToSelector:@selector(vimeoEngine:statusUpdate:)]) {
        [self.delegate vimeoEngine:self statusUpdate:@"Requesting Tokens..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:RSOAuthRequestToken];
	
    // OAuth Step 3 - Exchange the request token with an access token
    MKNetworkOperation *op = [self operationWithPath:V_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the access token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthAccessToken];
        
        NSLog(@"Access Token (Vimeo): %@", self.token);
        NSLog(@"Token Secret: %@", self.tokenSecret);
		
        // Get user Profile
        [self getProfileWithCompletion:^(NSError *error) {
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
            _oAuthCompletionBlock = nil;
        }];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }];
    
    if ([self.delegate respondsToSelector:@selector(vimeoEngine:statusUpdate:)]) {
        [self.delegate vimeoEngine:self statusUpdate:@"Authenticating..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORVimeoEngine.ErrorDomain" code:401 userInfo:ui];
    
    [self resetOAuthToken];
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)resetOAuthToken
{
    [super resetOAuthToken];
    
    self.userID = nil;
    self.userName = nil;
}

- (MKNetworkOperation *)getProfileWithCompletion:(ORVimeoEngineCompletion)completion
{
    NSDictionary *params = @{@"method": @"vimeo.oauth.checkAccessToken",
                             @"format": @"json"};
    
    MKNetworkOperation *op = [self operationWithPath:V_API_ROOT params:params httpMethod:@"GET" ssl:NO];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];

        if (data && [data isKindOfClass:[NSDictionary class]]) {
            // Fill user with returned data
            self.userID = [data valueForKeyPath:@"oauth.user.id"];
            self.userName = [data valueForKeyPath:@"oauth.user.display_name"];

            completion(nil);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORVimeoEngine.ErrorDomain" code:401 userInfo:ui];

            completion(error);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];

    if ([self.delegate respondsToSelector:@selector(vimeoEngine:statusUpdate:)]) {
        [self.delegate vimeoEngine:self statusUpdate:@"Loading Profile..."];
    }

    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)fetchVideosForString:(NSString *)query page:(NSUInteger)page count:(NSUInteger)count cb:(ORVimeoArrayCompletion)completion
{
    NSDictionary *params = @{@"method": @"vimeo.videos.search",
                             @"format": @"json",
                             @"page": [NSString stringWithFormat:@"%d", page + 1],
                             @"per_page": [NSString stringWithFormat:@"%d", count],
                             @"summary_response": @"1",
                             @"query": query};
    
    MKNetworkOperation *op = [self operationWithPath:V_API_ROOT params:params httpMethod:@"GET" ssl:NO];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSArray *items = [ORVimeoVideo arrayWithVimeoJSON:[data valueForKeyPath:@"videos.video"]];
            completion(nil, items);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid Response", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORVimeoEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    if ([self.delegate respondsToSelector:@selector(vimeoEngine:statusUpdate:)]) {
        [self.delegate vimeoEngine:self statusUpdate:@"Loading Videos..."];
    }
    
    [self enqueueSignedOperation:op];
    return op;
}

@end

//
//  ORInstagramEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 06/10/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.

#import "ORInstagramEngine.h"
#import "ORInstagramUser.h"
#import "ORInstagramImage.h"

#define IG_APP_ID @"0d5011a3bbb349b681c3f994f7da3cea"

// This will be called after the user authorizes your app
#define IG_CALLBACK_URL @"http://api.portl.it/instagram_oauth_redirect"

// Default Facebook hostname and paths
#define IG_AUTH_DIALOG @"https://instagram.com/oauth/authorize/"
#define IG_HOSTNAME @"api.instagram.com"

#define IG_USER(__ID__) [NSString stringWithFormat:@"v1/users/%@/", __ID__]
#define IG_TAGS(__NAME__) [NSString stringWithFormat:@"v1/tags/%@/media/recent", __NAME__]
#define IG_SEARCH @"v1/media/search"

@implementation ORInstagramEngine

#pragma mark - Read-only Properties

- (NSString *)callbackURL
{
    return IG_CALLBACK_URL;
}

#pragma mark - Initialization

+ (ORInstagramEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORInstagramEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORInstagramEngine alloc] initWithDelegate:nil];
    });
    
    return shared;
}

- (id)initWithDelegate:(id <ORInstagramEngineDelegate>)delegate
{
    self = [super initWithHostName:IG_HOSTNAME customHeaderFields:nil];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _delegate = delegate;
        
        _accessToken = nil;
        _userID = nil;
        _userName = nil;
        _profilePicture = nil;
    }
    
    return self;
}

#pragma mark - Authentication

- (void)authenticateWithCompletion:(ORIGCompletion)completion
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completion copy];
    
    if (self.optionalPermissions == nil) self.optionalPermissions = @"";
    NSDictionary *params = @{@"client_id": IG_APP_ID,
                             @"redirect_uri": IG_CALLBACK_URL,
                             @"response_type": @"token"};
    
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:params.allKeys.count];
    
    for (NSString *key in params) {
        NSString *obj = [params objectForKey:key];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [obj mk_urlEncodedString]]];
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"%@?%@", IG_AUTH_DIALOG, [pairs componentsJoinedByString:@"&"]];
    
    // Redirect user to authorization page
    [self.delegate instagramEngine:self statusUpdate:@"Waiting for user authorization..."];
    NSURL *url = [NSURL URLWithString:fullURL];
    [self.delegate instagramEngine:self needsToOpenURL:url];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    NSString *query = [url fragment];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:pairs.count];
    
    // The access token is returned in the query string
    for (NSString *obj in pairs) {
        NSArray *kv = [obj componentsSeparatedByString:@"="];
        [params setObject:[[kv objectAtIndex:1] mk_urlDecodedString] forKey:[kv objectAtIndex:0]];
    }
    
    self.accessToken = [params valueForKey:@"access_token"];
    
    if (self.accessToken) {
        self.userID = [self.accessToken componentsSeparatedByString:@"."][0];
        NSLog(@"Access Token (Instagram): %@", self.accessToken);
        
        [self getUserID:self.userID completion:^(NSError *error, ORInstagramUser *user) {
            if (user) {
                self.userName = user.username;
                self.profilePicture = user.profilePicture;
            }
            
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
            _oAuthCompletionBlock = nil;
        }];
    } else {
        NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid authentication response.", NSLocalizedDescriptionKey, nil];
        NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORInstagramEngine.ErrorDomain" code:401 userInfo:ui];
        
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORInstagramEngine.ErrorDomain" code:401 userInfo:ui];
    
    self.accessToken = nil;
    
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)resetOAuthToken
{
    self.accessToken = nil;
    self.userID = nil;
    self.userName = nil;
}

- (BOOL)isAuthenticated
{
    return (self.accessToken != nil);
}

- (MKNetworkOperation *)getUserID:(NSString *)userID completion:(ORIGUserCompletion)completion
{
    NSDictionary *params = @{@"access_token": self.accessToken};
    MKNetworkOperation *op = [self operationWithPath:IG_USER(userID) params:params httpMethod:@"GET" ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            ORInstagramUser *user = [ORInstagramUser instanceWithIGJSON:[data valueForKey:@"data"]];
            completion(nil, user);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid Response.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORInstagramEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self.delegate instagramEngine:self statusUpdate:@"Loading User..."];
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getImagesForTag:(NSString *)tag minID:(NSString *)minID maxID:(NSString *)maxID completion:(ORIGArrayCompletion)completion
{
    NSMutableDictionary *params = [@{@"access_token": self.accessToken} mutableCopy];
    
    if (minID) [params setObject:minID forKey:@"min_tag_id"];
    if (maxID) [params setObject:maxID forKey:@"max_tag_id"];
    
    MKNetworkOperation *op = [self operationWithPath:IG_TAGS([tag mk_urlEncodedString]) params:params httpMethod:@"GET" ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            
            NSString *maxTagID = [data valueForKeyPath:@"pagination.next_max_tag_id"];
            NSArray *images = [ORInstagramImage arrayWithIGJSON:[data valueForKey:@"data"]];
            
            completion(nil, images, maxTagID);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid Response.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORInstagramEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil, nil);
    }];
    
    [self.delegate instagramEngine:self statusUpdate:@"Loading Images..."];
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getImagesForLat:(CGFloat)lat Lng:(CGFloat)lng completion:(ORIGArrayCompletion)completion
{
    NSDictionary *params = @{@"lat": [NSString stringWithFormat:@"%f", lat],
                             @"lng": [NSString stringWithFormat:@"%f", lng],
                             @"access_token": self.accessToken};

    MKNetworkOperation *op = [self operationWithPath:IG_SEARCH params:params httpMethod:@"GET" ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSArray *images = [ORInstagramImage arrayWithIGJSON:[data valueForKey:@"data"]];
            completion(nil, images, nil);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid Response.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.ORInstagramEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil, nil);
    }];
    
    [self.delegate instagramEngine:self statusUpdate:@"Loading Images..."];
    [self enqueueOperation:op];
    return op;
}

@end

//
//  ORFacebookEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 06/15/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.

#import "ORFacebookEngine.h"
#import "ORContact.h"

#define FB_APP_ID @"356456794425203"

#ifdef DEBUG
// Don't include in the release build since we're not using it
#define FB_APP_SECRET @"fca165ff87c9e7fe2ffecc744d218d77"
#endif

// This will be called after the user authorizes your app
#define FB_CALLBACK_URL [NSString stringWithFormat:@"fb%@://authorize/", FB_APP_ID]

// Default Facebook hostname and paths
#define FB_AUTH_DIALOG @"https://m.facebook.com/dialog/oauth"
#define FB_AUTH_TOKEN @"https://api.facebook.com/method/auth.extendSSOAccessToken"
#define FB_HOSTNAME @"graph.facebook.com"
#define FB_ME @"me"
#define FB_PICTURE @"me/picture"
#define FB_FRIENDS @"me/friends"
#define FB_PHOTOS @"me/photos"

@interface ORFacebookEngine ()

- (void)refreshTokenIfNeededWithCompletion:(ORFacebookEngineCompletionBlock)completion;

@end

@implementation ORFacebookEngine

#pragma mark - Read-only Properties

- (NSString *)callbackURL
{
    return FB_CALLBACK_URL;
}

+ (NSString *)facebookAppID
{
    return FB_APP_ID;
}

#pragma mark - Initialization

+ (ORFacebookEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORFacebookEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORFacebookEngine alloc] initWithDelegate:nil];
    });
    
    return shared;
}

- (id)initWithDelegate:(id <ORFacebookEngineDelegate>)delegate
{
    self = [super initWithHostName:FB_HOSTNAME customHeaderFields:nil];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _delegate = delegate;
        
        _accessToken = nil;
        _expirationTime = nil;
        _userID = nil;
        _userName = nil;
        _profilePicture = nil;
    }
    
    return self;
}

#pragma mark - Authentication

- (void)authenticateWithCompletion:(ORFacebookEngineCompletionBlock)completion
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completion copy];
    
    if (self.optionalPermissions == nil) self.optionalPermissions = @"";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FB_APP_ID, @"client_id",
                                   FB_CALLBACK_URL, @"redirect_uri",
                                   @"touch", @"display",
                                   @"token", @"response_type",
                                   self.optionalPermissions, @"scope",
                                   nil];

    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:params.allKeys.count];
    
    for (NSString *key in params) {
        NSString *obj = [params objectForKey:key];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [obj mk_urlEncodedString]]];
    }

    NSString *fullURL = [NSString stringWithFormat:@"%@?%@", FB_AUTH_DIALOG, [pairs componentsJoinedByString:@"&"]];
    
    // Redirect user to authorization page
    [self.delegate facebookEngine:self statusUpdate:@"Waiting for user authorization..."];
    NSURL *url = [NSURL URLWithString:fullURL];
    [self.delegate facebookEngine:self needsToOpenURL:url];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    NSString *query = [url fragment];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    __block NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:pairs.count];
    
    // The access token is returned in the query string
    for (NSString *obj in pairs) {
        NSArray *kv = [obj componentsSeparatedByString:@"="];
        [params setObject:[[kv objectAtIndex:1] mk_urlDecodedString] forKey:[kv objectAtIndex:0]];
    }
    
    self.accessToken = [params valueForKey:@"access_token"];
    
    if (self.accessToken) {
        // Calculate when the access token will expire
        NSString *expiresIn = [params valueForKey:@"expires_in"];
        self.expirationTime = [NSDate distantFuture];
        if (expiresIn) {
            int expiresInVal = [expiresIn intValue];
            if (expiresInVal > 0) self.expirationTime = [NSDate dateWithTimeIntervalSinceNow:expiresInVal];
        }
        
        NSLog(@"Access Token (Facebook): %@", self.accessToken);
        NSLog(@"Expires In: %@", self.expirationTime);
        
        // Get user ID and Name
        [self getProfileWithCompletion:^(NSError *error) {
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
            _oAuthCompletionBlock = nil;
        }];
    } else {
        NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid authentication response.", NSLocalizedDescriptionKey, nil];
        NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];

        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];
    
    self.accessToken = nil;
    self.expirationTime = nil;
    
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)resetOAuthToken
{
    self.accessToken = nil;
    self.expirationTime = nil;
    self.userID = nil;
    self.userName = nil;
}

- (BOOL)isAuthenticated
{
    return (self.accessToken != nil);
}

- (void)refreshTokenIfNeededWithCompletion:(ORFacebookEngineCompletionBlock)completion
{
    // User should be already authenticated
    if (!self.isAuthenticated) {
        NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Not authenticated.", NSLocalizedDescriptionKey, nil];
        NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];
        
        completion(error);
        return;
    }
    
    // If the Access Token is not expired, no need to refresh
    if ([self.expirationTime compare:[NSDate date]] == NSOrderedDescending) {
        completion(nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"json", @"format",
                                   self.accessToken, @"access_token",
                                   nil];
    
    // Refresh the access token
    MKNetworkOperation *op = [self operationWithURLString:FB_AUTH_TOKEN params:params httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            NSUInteger error = [[data valueForKey:@"error_code"] unsignedIntegerValue];
            if (error > 0) {
                [self resetOAuthToken];
                
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];
                
                completion(error);
                return;
            }
            
            self.accessToken = [data valueForKey:@"access_token"];
            
            // Calculate when the access token will expire
            NSString *expiresAt = [data valueForKey:@"expires_at"];
            self.expirationTime = [NSDate distantFuture];
            if (expiresAt) {
                int expiresAtVal = [expiresAt intValue];
                if (expiresAtVal > 0) self.expirationTime = [NSDate dateWithTimeIntervalSince1970:expiresAtVal];
            }
            
            completion(nil);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];
            
            completion(error);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    [self.delegate facebookEngine:self statusUpdate:@"Refreshing Access Token..."];
    [self enqueueOperation:op];
}

- (void)getProfileWithCompletion:(ORFacebookEngineCompletionBlock)completion
{
    // Every API call should first refresh the access token if needed
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"id,name,picture", @"fields",
                                          @"json", @"format",
                                          self.accessToken, @"access_token",
                                          nil];
        
        MKNetworkOperation *op = [self operationWithPath:FB_ME
                                                  params:getParams
                                              httpMethod:@"GET"
                                                     ssl:YES];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            
            if (data) {
                self.userID = [data objectForKey:@"id"];
                self.userName = [data objectForKey:@"name"];
                self.profilePicture = [data objectForKey:@"picture"];
                
                if (self.profilePicture) {
                    // If the "October 2012 Breaking Changes" migration setting is enabled for your app,
                    // this field will be an object with the url and is_silhouette fields;
                    // is_silhouette is true if the user has not uploaded a profile picture
                    if ([[data objectForKey:@"picture"] isKindOfClass:[NSDictionary class]]) {
                        self.profilePicture = [[[data objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                    }
                    
                    // Rename the image to use the original
                    // In the filename, the suffix "_q" is for small square image, and "_n" for the large image
                    self.profilePicture = [self.profilePicture stringByReplacingOccurrencesOfString:@"_q." withString:@"_n."];
                }
                
                completion(nil);
            } else {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];
                
                completion(error);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error);
        }];
        
        [self.delegate facebookEngine:self statusUpdate:@"Loading Profile..."];
        [self enqueueOperation:op];
    }];
}


//================================================================================================================
//
//  CONTACTS
//
//================================================================================================================
#pragma mark - CONTACTS

- (void)listContactsWithCompletion:(ORFacebookContactsCompletionBlock)completion
{
    // Every API call should first refresh the access token if needed
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error, nil);
            return;
        }
        
        NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"json", @"format",
                                          self.accessToken, @"access_token",
                                          @"name,id,picture", @"fields",
                                          nil];
        
        MKNetworkOperation *op = [self operationWithPath:FB_FRIENDS
                                                  params:getParams
                                              httpMethod:@"GET"
                                                     ssl:YES];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            
            if (data) {
                NSArray *entries = [data objectForKey:@"data"];
                NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:[entries count]];
                
                for (NSDictionary *entry in entries) {
                    ORContact *contact = [[ORContact alloc] initWithFacebookData:entry];
                    [contacts addObject:contact];
                }
                
                completion(nil, contacts);
            } else {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:401 userInfo:ui];
                
                completion(error, nil);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error, nil);
        }];
        
        [self.delegate facebookEngine:self statusUpdate:@"Listing Contacts..."];
        [self enqueueOperation:op];
    }];
}

////================================================================================================================
////
////  POSTING TO OWN WALL
////
////================================================================================================================
//#pragma mark - POSTING TO OWN WALL
//
//- (void)postMessage:(NSString *)message completion:(ORFacebookEngineCompletionBlock)completion
//{
//    [self postMessage:message toWallForUserID:nil completion:^(NSError *error) {
//        completion(error);
//    }];
//}

//- (void)postImage:(UIImage *)image withMessage:(NSString *)message completion:(ORFacebookEngineCompletionBlock)completion
//{
//	[self postImage:image withMessage:message toWallForUserID:nil completion:^(NSError *error) {
//		completion(error);
//	}];
//	
////    // Every API call should first refresh the access token if needed
////    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
////        if (error) {
////            completion(error);
////            return;
////        }
////
////        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                                       message, @"message",
////                                       @"json", @"format",
////                                       self.accessToken, @"access_token",
////                                       nil];
////        
////        MKNetworkOperation *op = [self operationWithPath:FB_PHOTOS
////                                                  params:params
////                                              httpMethod:@"POST"
////                                                     ssl:YES];
////        
////        // Add the image to the Operation
////        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
////        [op addData:imageData forKey:@"source"];
////        
////        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
////            NSDictionary *data = [completedOperation responseJSON];
////            
////            if (data && [data objectForKey:@"id"]) {
////                completion(nil);
////            } else {
////                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Image sending failed.", NSLocalizedDescriptionKey, nil];
////                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:500 userInfo:ui];
////                
////                completion(error);
////            }
////        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
////            completion(error);
////        }];
////        
////        [self.delegate facebookEngine:self statusUpdate:@"Sending image..."];
////        [self enqueueOperation:op];
////    }];
//}

//================================================================================================================
//
//  POSTING TO WALL WITH USER ID
//
//================================================================================================================
#pragma mark - POSTING TO WALL WITH USER ID

//- (void)postMessage:(NSString *)message toWallForUserID:(NSString *)userID completion:(ORFacebookEngineCompletionBlock)completion
//{
//    // Every API call should first refresh the access token if needed
//    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
//        if (error) {
//            completion(error);
//            return;
//        }
//		
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       message, @"message",
//                                       @"json", @"format",
//                                       self.accessToken, @"access_token",
//                                       nil];
//        
//        NSString *path = (userID != nil) ? userID : @"me";
//        MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@/feed", path]
//                                                  params:params
//                                              httpMethod:@"POST"
//                                                     ssl:YES];
//        
//        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//            NSDictionary *data = [completedOperation responseJSON];
//            
//            if (data && [data objectForKey:@"id"]) {
//                completion(nil);
//            } else {
//                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Message sending failed.", NSLocalizedDescriptionKey, nil];
//                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:500 userInfo:ui];
//                
//                completion(error);
//            }
//        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//            completion(error);
//        }];
//        
//        [self.delegate facebookEngine:self statusUpdate:@"Sending post..."];
//        [self enqueueOperation:op];
//    }];
//}

- (void)postImage:(UIImage *)image withMessage:(NSString *)message toWallForUserID:(NSString *)userID completion:(ORFacebookEngineCompletionBlock)completion
{
    // Every API call should first refresh the access token if needed
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        NSMutableDictionary *params = [@{@"message": message,
                                        @"format": @"json",
                                        @"access_token": self.accessToken} mutableCopy];
        
        if (userID) [params setObject:userID forKey:@"target_id"];
        
        MKNetworkOperation *op = [self operationWithPath:FB_PHOTOS
                                                  params:params
                                              httpMethod:@"POST"
                                                     ssl:YES];
        
        // Add the image to the Operation
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        [op addData:imageData forKey:@"source"];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            
            if (data && [data objectForKey:@"id"]) {
                completion(nil);
            } else {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Image sending failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:500 userInfo:ui];
                
                completion(error);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error);
        }];
        
        [self.delegate facebookEngine:self statusUpdate:@"Sending image..."];
        [self enqueueOperation:op];
    }];
}

- (void)postMessage:(NSString*)message withLink:(NSString*)link andLinkName:(NSString*)name andCaption:(NSString*)caption andDescription:(NSString*)description andPictureUrl:(NSString*)picture toWallForUserID:(NSString *)userID completion:(ORFacebookEngineCompletionBlock)completion
{
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
		
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"json", @"format",
                                       self.accessToken, @"access_token",
                                       nil];

		if (message) [params setObject:message forKey:@"message"];
		if (link) [params setObject:link forKey:@"link"];
		if (name) [params setObject:name forKey:@"name"];
		if (caption) [params setObject:caption forKey:@"caption"];
		if (description) [params setObject:description forKey:@"description"];
		if (picture) [params setObject:picture forKey:@"picture"];
        
        NSString *path = (userID != nil) ? userID : @"me";
        MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@/feed", path]
                                                  params:params
                                              httpMethod:@"POST"
                                                     ssl:YES];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            
            if (data && [data objectForKey:@"id"]) {
                completion(nil);
            } else {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Message sending failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFacebookEngine.ErrorDomain" code:500 userInfo:ui];
                
                completion(error);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error);
        }];
        
        [self.delegate facebookEngine:self statusUpdate:@"Sending post..."];
        [self enqueueOperation:op];
    }];
}

@end

//
//  RSOAuthEngine.h
//
//  Created by Rodrigo Sieiro on 12/11/11.
//  Copyright (c) 2012 Rodrigo Sieiro <rsieiro@sharpcube.com>. All rights reserved.

#import "MKNetworkEngine.h"

typedef enum _RSOAuthTokenType
{
    RSOAuthRequestToken,
    RSOAuthAccessToken,
}
RSOAuthTokenType;

typedef enum _RSOOAuthSignatureMethod {
    RSOAuthPlainText,
    RSOAuthHMAC_SHA1,
} RSOAuthSignatureMethod;

@interface RSOAuthEngine : MKNetworkEngine
{
    @private
    RSOAuthTokenType _tokenType;
    RSOAuthSignatureMethod _signatureMethod;
    NSString *_consumerSecret;
    NSString *_tokenSecret;
    NSString *_callbackURL;
    NSString *_verifier;
    NSMutableDictionary *_oAuthValues;
    NSMutableDictionary *_customValues;
}

@property (readonly) RSOAuthTokenType tokenType;
@property (readonly) RSOAuthSignatureMethod signatureMethod;
@property (readonly) NSString *consumerKey;
@property (readonly) NSString *consumerSecret;
@property (readonly) NSString *callbackURL;
@property (readonly) NSString *token;
@property (readonly) NSString *tokenSecret;
@property (readonly) NSString *verifier;

- (id)initWithHostName:(NSString *)hostName 
    customHeaderFields:(NSDictionary *)headers
       signatureMethod:(RSOAuthSignatureMethod)signatureMethod
           consumerKey:(NSString *)consumerKey
        consumerSecret:(NSString *)consumerSecret
           callbackURL:(NSString *)callbackURL;

- (id)initWithHostName:(NSString *)hostName
    customHeaderFields:(NSDictionary *)headers
       signatureMethod:(RSOAuthSignatureMethod)signatureMethod
           consumerKey:(NSString *)consumerKey
        consumerSecret:(NSString *)consumerSecret;

- (BOOL)isAuthenticated;
- (void)resetOAuthToken;
- (NSString *)customValueForKey:(NSString *)key;
- (void)fillTokenWithResponseBody:(NSString *)body type:(RSOAuthTokenType)tokenType;
- (void)setAccessToken:(NSString *)token secret:(NSString *)tokenSecret;
- (void)signRequest:(MKNetworkOperation *)request;
- (void)enqueueSignedOperation:(MKNetworkOperation *)op;
- (NSString *)generateXOAuthStringForURL:(NSString *)url method:(NSString *)method;

@end

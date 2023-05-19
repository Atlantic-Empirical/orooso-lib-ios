//
//  ORATTEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 08/07/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORATTEngine.h"

// Orooso
//#define ATT_API_KEY @"f99c39be158e18a10239b50f06a5f055"
//#define ATT_API_SECRET @"b09e014bc2112995"

// Portl
#define ATT_API_KEY @"9bdce950f40951647024359f7e6b2310"
#define ATT_API_SECRET @"60c8e42c122992a4"

// This will be called after the user authorizes your app
#define ATT_CALLBACK_URL @"http://www.orooso.com/att_api_oauth_redirect"

// Default AT&T hostname and paths
#define ATT_HOSTNAME @"api.att.com"
#define ATT_AUTH_DIALOG @"https://api.att.com/oauth/authorize"
#define ATT_ACCESS_TOKEN @"oauth/token"
#define ATT_MESSAGES @"rest/1/MyMessages"

@interface ORATTEngine ()

- (void)refreshTokenIfNeededWithCompletion:(ORATTEngineCompletionBlock)completion;

@end

@implementation ORATTEngine

@synthesize delegate = _delegate;
@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize expirationTime = _expirationTime;

#pragma mark - Read-only Properties

- (NSString *)callbackURL
{
    return ATT_CALLBACK_URL;
}

#pragma mark - Initialization

- (id)initWithDelegate:(id <ORATTEngineDelegate>)delegate
{
    self = [super initWithHostName:ATT_HOSTNAME customHeaderFields:nil];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _delegate = delegate;
        
        _accessToken = nil;
        _refreshToken = nil;
        _expirationTime = nil;
    }
    
    return self;
}

#pragma mark - Authentication

- (void)authenticateWithCompletion:(ORATTEngineCompletionBlock)completion
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completion copy];
    
    NSDictionary *params = @{@"client_id": ATT_API_KEY,
                             @"scope": @"IMMN,MIM"};
    
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:params.allKeys.count];
    
    for (NSString *key in params) {
        NSString *obj = [params objectForKey:key];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [obj mk_urlEncodedString]]];
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"%@?%@", ATT_AUTH_DIALOG, [pairs componentsJoinedByString:@"&"]];
    
    // Redirect user to authorization page
    [self.delegate attEngine:self statusUpdate:@"Waiting for user authorization..."];
    NSURL *url = [NSURL URLWithString:fullURL];
    [self.delegate attEngine:self needsToOpenURL:url];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    NSString *query = [url query];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSString *code = @"";
    
    // The code is returned in the query string
    for (NSString *obj in pairs) {
        NSArray *kv = [obj componentsSeparatedByString:@"="];
        
        if ([[kv objectAtIndex:0] isEqualToString:@"code"]) {
            code = [[kv objectAtIndex:1] mk_urlDecodedString];
            break;
        }
    }

    NSDictionary *params = @{@"client_id": ATT_API_KEY,
                             @"client_secret": ATT_API_SECRET,
                             @"grant_type": @"authorization_code",
                             @"code": code};
    
    // Exchange the code with an access token
    MKNetworkOperation *op = [self operationWithPath:ATT_ACCESS_TOKEN
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            // Fill tokens with returned data
            self.accessToken = [data valueForKey:@"access_token"];
            self.refreshToken = [data valueForKey:@"refresh_token"];

            // Calculate when the access token will expire
            NSString *expiresIn = [data valueForKey:@"expires_in"];
            self.expirationTime = [NSDate distantFuture];
            if (expiresIn) {
                int expiresInVal = [expiresIn intValue];
                if (expiresInVal > 0) self.expirationTime = [NSDate dateWithTimeIntervalSinceNow:expiresInVal];
            }
            
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(nil);
            _oAuthCompletionBlock = nil;
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSATTEngine.ErrorDomain" code:401 userInfo:ui];
            
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
            _oAuthCompletionBlock = nil;
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }];
    
    [self.delegate attEngine:self statusUpdate:@"Authenticating..."];
    [self enqueueOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSATTEngine.ErrorDomain" code:401 userInfo:ui];
    
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expirationTime = nil;
    
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)resetOAuthToken
{
    self.accessToken = nil;
    self.refreshToken = nil;
    self.expirationTime = nil;
}

- (BOOL)isAuthenticated
{
    return (self.accessToken != nil);
}

- (void)refreshTokenIfNeededWithCompletion:(ORATTEngineCompletionBlock)completion
{
    // User should be already authenticated
    if (!self.isAuthenticated) {
        NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Not authenticated.", NSLocalizedDescriptionKey, nil];
        NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSATTEngine.ErrorDomain" code:401 userInfo:ui];
        
        completion(error);
        return;
    }
    
    // If the Access Token is not expired, no need to refresh
    if ([self.expirationTime compare:[NSDate date]] == NSOrderedDescending) {
        completion(nil);
        return;
    }
    
    NSDictionary *params = @{@"client_id": ATT_API_KEY,
                             @"client_secret": ATT_API_SECRET,
                             @"grant_type": @"refresh_token",
                             @"refresh_token": self.refreshToken};
    
    // Refresh the access token
    MKNetworkOperation *op = [self operationWithPath:ATT_ACCESS_TOKEN
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            // Fill tokens with returned data
            self.accessToken = [data valueForKey:@"access_token"];
            self.refreshToken = [data valueForKey:@"refresh_token"];
            
            // Calculate when the access token will expire
            NSString *expiresIn = [data valueForKey:@"expires_in"];
            self.expirationTime = [NSDate distantFuture];
            if (expiresIn) {
                int expiresInVal = [expiresIn intValue];
                if (expiresInVal > 0) self.expirationTime = [NSDate dateWithTimeIntervalSinceNow:expiresInVal];
            }
            
            NSLog(@"Access Token (AT&T): %@", self.accessToken);
            NSLog(@"Refresh Token: %@", self.refreshToken);
            NSLog(@"Expires In: %@", self.expirationTime);
            
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(nil);
            _oAuthCompletionBlock = nil;
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSATTEngine.ErrorDomain" code:401 userInfo:ui];
            
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
            _oAuthCompletionBlock = nil;
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    [self.delegate attEngine:self statusUpdate:@"Refreshing Access Token..."];
    [self enqueueOperation:op];
}

#pragma mark - Custom Methods

// Sends a SMS
// Docs: https://devconnect-api.att.com/docs/messaging-behalf-mobo-v1/send-message-v1

- (void)sendSMS:(NSString *)message toNumbers:(NSArray *)numbers withCompletion:(ORATTEngineCompletionBlock)completion
{
    // Every API call should first refresh the access token if needed
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        NSMutableArray *formattedNumbers = [NSMutableArray arrayWithCapacity:[numbers count]];
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        for (NSString *obj in numbers) {
            NSString *digits = [[obj componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
            [formattedNumbers addObject:[NSString stringWithFormat:@"tel:%@", digits]];
        }
        
        NSDictionary *jsonData = @{@"Addresses": formattedNumbers,
                                   @"Text": message};
        
        MKNetworkOperation *op = [self operationWithPath:ATT_MESSAGES
                                                  params:jsonData
                                              httpMethod:@"POST"
                                                     ssl:YES];
        
        op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
        [op setAuthorizationHeaderValue:self.accessToken forAuthType:@"Bearer"];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            
            if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"Id"]) {
                NSLog(@"Message ID: %@", [data objectForKey:@"Id"]);
                completion(nil);
            } else {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Message sending failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSATTEngine.ErrorDomain" code:500 userInfo:ui];
                completion(error);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error);
        }];
        
        [self.delegate attEngine:self statusUpdate:@"Sending Message..."];
        [self enqueueOperation:op];
    }];
}

- (void)sendSMS:(NSString *)message toNumber:(NSString *)number withCompletion:(ORATTEngineCompletionBlock)completion
{
    NSArray *numbers = [NSArray arrayWithObject:number];
    
    [self sendSMS:message toNumbers:numbers withCompletion:^(NSError *error) {
        completion(error);
    }];
}

// Sends a MMS with an image attached
// Docs: https://devconnect-api.att.com/docs/messaging-behalf-mobo-v1/send-message-v1

- (void)sendMMS:(NSString *)message subject:(NSString *)subject numbers:(NSArray *)numbers image:(UIImage *)image completion:(ORATTEngineCompletionBlock)completion
{
    // Every API call should first refresh the access token if needed
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        NSMutableArray *fields = [NSMutableArray arrayWithCapacity:[numbers count]+3];
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        for (NSString *obj in numbers) {
            NSString *digits = [[obj componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
            [fields addObject:[NSString stringWithFormat:@"Addresses=%@%@", [@"tel:" mk_urlEncodedString], [digits mk_urlEncodedString]]];
        }
        
        if (subject) [fields addObject:[NSString stringWithFormat:@"Subject=%@", [subject mk_urlEncodedString]]];
        [fields addObject:@"Group=false"];

        // Right now the message body is omitted because it would create a slideshow in the MMS
        // if (message) [fields addObject:[NSString stringWithFormat:@"Text=%@", [message mk_urlEncodedString]]];
        
        MKNetworkOperation *op = [self operationWithPath:ATT_MESSAGES
                                                  params:nil
                                              httpMethod:@"POST"
                                                     ssl:YES];
        
        NSString *boundary = @"MIMEBoundary_RSATTEngine";
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSMutableData *body = [NSMutableData data];
        NSMutableString *bodyString = [NSMutableString string];
        NSString *tempData;
        
        // Body part 1 - Form Data
        tempData = [NSString stringWithFormat:
                    @"--%@\r\n"
                    "Content-Type: application/x-www-form-urlencoded; charset=UTF-8\r\n"
                    "Content-Transfer-Encoding: 8bit\r\n"
                    "Content-Disposition: form-data; name=\"root-fields\"\r\n"
                    "Content-ID: <startpart>\r\n"
                    "\r\n"
                    "%@\r\n",
                    boundary,
                    [fields componentsJoinedByString:@"&"]];
        
        [body appendData:[tempData dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyString appendString:tempData];
        
        // Body Part 2 - Image Attachment
        tempData = [NSString stringWithFormat:
                    @"--%@\r\n"
                    "Content-Disposition: form-data; name=\"file0\"; filename=\"image.jpg\"\r\n"
                    "Content-Type: image/jpeg\r\n"
                    "Content-ID: <image.jpg>\r\n"
                    "Content-Transfer-Encoding: binary\r\n"
                    "\r\n",
                    boundary];
        
        [body appendData:[tempData dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyString appendString:tempData];
        
        [body appendData:imageData];
        [bodyString appendString:@"<binary data>"];
        
        tempData = [NSString stringWithFormat:
                    @"\r\n"
                    "--%@--\r\n",
                    boundary];
        
        [body appendData:[tempData dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyString appendString:tempData];
        
        // Set the Custom Body Handler
        [op setCustomPostDataEncodingHandler:^NSData *(NSDictionary *postDataDict) { return body; } forType:@"multipart/related"];
        
        // Set the Content-Type and Content-Length Headers
        NSDictionary *headers = @{@"Content-Type": [NSString stringWithFormat:@"multipart/form-data; type=\"application/x-www-form-urlencoded\"; start=\"<startpart>\"; boundary=\"%@\"", boundary],
                                  @"Content-Length": [NSString stringWithFormat:@"%d", [body length]],
                                  @"Accept": @"application/json"};
        
        [op addHeaders:headers];
        
        // Set the Authorization Header
        [op setAuthorizationHeaderValue:self.accessToken forAuthType:@"Bearer"];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            
            if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"Id"]) {
                NSLog(@"Message ID: %@", [data objectForKey:@"Id"]);
                completion(nil);
            } else {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Message sending failed.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSATTEngine.ErrorDomain" code:500 userInfo:ui];
                completion(error);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error);
        }];
        
        [self.delegate attEngine:self statusUpdate:@"Sending MMS..."];
        [self enqueueOperation:op];
        
        // Uncomment if you want to debug the Request
        // NSLog(@"Request: %@", [op curlCommandLineString]);
        // NSLog(@"Body: %@", bodyString);
    }];
}

- (void)sendMMS:(NSString *)message subject:(NSString *)subject number:(NSString *)number image:(UIImage *)image completion:(ORATTEngineCompletionBlock)completion
{
    NSArray *numbers = [NSArray arrayWithObject:number];
    [self sendMMS:message subject:subject numbers:numbers image:image completion:completion];
}

- (void)getMessagesWithCompletion:(ORATTEngineCompletionBlock)completion
{
    // Every API call should first refresh the access token if needed
    [self refreshTokenIfNeededWithCompletion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        NSDictionary *params = @{@"HeaderCount": @"100"};
        
        MKNetworkOperation *op = [self operationWithPath:ATT_MESSAGES
                                                  params:params
                                              httpMethod:@"GET"
                                                     ssl:YES];
        
        [op setAuthorizationHeaderValue:self.accessToken forAuthType:@"Bearer"];
        
        NSDictionary *headers = @{@"Accept": @"application/json"};
        [op addHeaders:headers];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *data = [completedOperation responseJSON];
            NSLog(@"%@", data);
            
            completion(nil);
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completion(error);
        }];
        
        [self.delegate attEngine:self statusUpdate:@"Getting Messages..."];
        [self enqueueOperation:op];
    }];
}

@end

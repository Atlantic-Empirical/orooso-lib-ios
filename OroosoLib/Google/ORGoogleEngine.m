//
//  ORGoogleEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/19/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.

#import "ORGoogleEngine.h"
#import "SKPSMTPMessage.h"
#import "ORGroup.h"
#import "ORContact.h"

#define G_API_KEY @""
#define G_APP_ID @"441849190906.apps.googleusercontent.com"
#define G_APP_SECRET @"1T1OstaQnvQjqBFQ2lOFnDiP"
#define G_APP_DISPLAY_NAME @"Portl" //@"Orooso"

// This will be called after the user authorizes your app
#define G_CALLBACK_URL @"http://localhost/googleauth"

// Default Google hostnames and paths
#define G_HOSTNAME @"www.google.com"
#define G_REQUEST_TOKEN @"accounts/OAuthGetRequestToken"
#define G_ACCESS_TOKEN @"accounts/OAuthGetAccessToken"
#define G_SCOPE @"https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.google.com/m8/feeds https://mail.google.com/"
#define G_PROFILE_URL @"https://www.googleapis.com/oauth2/v1/userinfo"
#define G_GROUPS_PATH @"m8/feeds/groups/default/thin"
#define G_CONTACTS_PATH @"m8/feeds/contacts/default/thin"
#define G_SMTP_SERVER @"smtp.gmail.com"
#define G_MAX_RESULTS @"5000"

// URL to redirect the user for authentication
#define G_AUTHORIZE(__TOKEN__) [NSString stringWithFormat:@"https://www.google.com/accounts/OAuthAuthorizeToken?btmpl=mobile&oauth_token=%@", __TOKEN__]

// URL to use with XOAuth
#define G_XOAUTH_URL(__EMAIL__) [NSString stringWithFormat:@"https://mail.google.com/mail/b/%@/smtp/", __EMAIL__]

@interface ORGoogleEngine () <SKPSMTPMessageDelegate>

@end

@implementation ORGoogleEngine

@synthesize delegate = _delegate;
@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize userEmail = _userEmail;
@synthesize profilePicture = _profilePicture;
@synthesize mainContactsGroup = _mainContactsGroup;

#pragma mark - Read-only Properties

- (NSString *)callbackURL
{
    return G_CALLBACK_URL;
}

#pragma mark - Initialization

+ (ORGoogleEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORGoogleEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORGoogleEngine alloc] initWithDelegate:nil];
    });
    
    return shared;
}

- (id)initWithDelegate:(id <ORGoogleEngineDelegate>)delegate
{
    self = [super initWithHostName:G_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:RSOAuthHMAC_SHA1
                       consumerKey:G_APP_ID
                    consumerSecret:G_APP_SECRET
                       callbackURL:G_CALLBACK_URL];

    if (self) {
        _oAuthCompletionBlock = nil;
        _smtpCompletionBlock = nil;
        _delegate = delegate;
        
        _userID = nil;
        _userName = nil;
        _userEmail = nil;
        _profilePicture = nil;
        _mainContactsGroup = nil;
    }
    
    return self;
}

#pragma mark - Authentication

- (void)authenticateWithCompletion:(ORGoogleEngineCompletionBlock)completion
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completion copy];
    
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   G_SCOPE, @"scope",
                                   G_APP_DISPLAY_NAME, @"xoauth_displayname",
                                   nil];
    
    // OAuth Step 1 - Obtain a request token
    MKNetworkOperation *op = [self operationWithPath:G_REQUEST_TOKEN
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the request token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthRequestToken];

        // OAuth Step 2 - Redirect user to authorization page
        if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
            [self.delegate googleEngine:self statusUpdate:@"Waiting for user authorization..."];
        }
        
        NSURL *url = [NSURL URLWithString:G_AUTHORIZE(self.token)];
        
        if ([self.delegate respondsToSelector:@selector(googleEngine:needsToOpenURL:)]) {
            [self.delegate googleEngine:self needsToOpenURL:url];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
        _oAuthCompletionBlock = nil;
    }];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Requesting Tokens..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:RSOAuthRequestToken];

    // OAuth Step 3 - Exchange the request token with an access token
    MKNetworkOperation *op = [self operationWithPath:G_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the access token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthAccessToken];
        
        NSLog(@"Access Token (Google): %@", self.token);
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
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Authenticating..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSGoogleEngine.ErrorDomain" code:401 userInfo:ui];
    
    [self resetOAuthToken];
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)resetOAuthToken
{
    [super resetOAuthToken];
    
    self.userID = nil;
    self.userName = nil;
    self.userEmail = nil;
    self.mainContactsGroup = nil;
}

- (void)getProfileWithCompletion:(ORGoogleEngineCompletionBlock)completion
{
    MKNetworkOperation *op = [self operationWithURLString:G_PROFILE_URL params:nil httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            // Fill user with returned data
            self.userID = [data objectForKey:@"id"];
            self.userName = [data objectForKey:@"name"];
            self.userEmail = [data objectForKey:@"email"];
            self.profilePicture = [data objectForKey:@"picture"];
            
            if (!self.profilePicture) {
                NSLog(@"User doesn't have a public profile picture");
            }
            
            completion(nil);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication failed.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSGoogleEngine.ErrorDomain" code:401 userInfo:ui];
            
            completion(error);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Loading Profile..."];
    }
    
    [self enqueueSignedOperation:op];
}

#pragma mark - SKPSMTPMessage Delegate Methods

- (void)messageSent:(SKPSMTPMessage *)message
{
    if (_smtpCompletionBlock) _smtpCompletionBlock(nil);
    _smtpCompletionBlock = nil;
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    if (_smtpCompletionBlock) _smtpCompletionBlock(error);
    _smtpCompletionBlock = nil;
}

#pragma mark - Contact Listing Methods

- (void)listGroupsWithCompletion:(ORGoogleContactsCompletionBlock)completion
{
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"2.0", @"GData-Version", nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"json", @"alt",
                                   nil];
    
    MKNetworkOperation *op = [self operationWithPath:G_GROUPS_PATH
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:YES];
    [op addHeaders:headers];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            NSArray *entries = [[data objectForKey:@"feed"] objectForKey:@"entry"];
            NSMutableArray *groups = [NSMutableArray arrayWithCapacity:[entries count]];
            
            for (NSDictionary *entry in entries) {
                ORGroup *group = [[ORGroup alloc] initWithGoogleData:entry];
                
                // Is this the main contacts group?
                if ([group.systemName isEqualToString:@"Contacts"]) {
                    self.mainContactsGroup = group.id;
                }
                
                [groups addObject:group];
            }
            
            completion(nil, groups);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid data returned.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSGoogleEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Listing Groups..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (void)listContactsWithCompletion:(ORGoogleContactsCompletionBlock)completion
{
    if (!self.mainContactsGroup) {
        // If we don't have the main group yet, list the groups first
        [self listGroupsWithCompletion:^(NSError *error, NSArray *items) {
            if (error) {
                completion(error, nil);
            } else {
                [self listContactsWithCompletion:completion];
            }
        }];
        
        return;
    }
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"2.0", @"GData-Version", nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.mainContactsGroup, @"group",
                                   G_MAX_RESULTS, @"max-results",
                                   @"json", @"alt",
                                   nil];
    
    MKNetworkOperation *op = [self operationWithPath:G_CONTACTS_PATH
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:YES];
    [op addHeaders:headers];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            NSArray *entries = [[data objectForKey:@"feed"] objectForKey:@"entry"];
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:[entries count]];
            
            for (NSDictionary *entry in entries) {
                ORContact *contact = [[ORContact alloc] initWithGoogleData:entry];
                [contacts addObject:contact];
            }
            
            completion(nil, contacts);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid data returned.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSGoogleEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Listing Contacts..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (void)imageForContactWithURL:(NSString *)url completion:(ORGoogleImageCompletionBlock)completion
{
    MKNetworkOperation *op = [self operationWithURLString:url];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        UIImage *image = [completedOperation responseImage];
        completion(nil, image);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Loading Contact Image..."];
    }
    
    [self enqueueSignedOperation:op];
}

- (NSString*)signContactImageUrl:(NSString*)contactImageUrl
{
	MKNetworkOperation *op = [self operationWithURLString:contactImageUrl];
	[self signRequest:op];
	return op.url;
}

- (void)addContact:(ORContact *)contact completion:(ORGoogleContactCompletionBlock)completion
{
    NSMutableString *body = [[NSMutableString alloc] initWithCapacity:100];
    
    [body appendString:@"<atom:entry xmlns:atom='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>"];
    [body appendString:@"<atom:category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/contact/2008#contact' />"];
    [body appendFormat:@"<atom:title type='text'>%@</atom:title>", contact.name];
    
    if (contact.email)
        [body appendFormat:@"<gd:email rel='http://schemas.google.com/g/2005#home' address='%@' />", contact.email];
    
    if (contact.phone)
        [body appendFormat:@"<gd:phoneNumber rel='http://schemas.google.com/g/2005#home'>%@</gd:phoneNumber>", contact.phone];
    
    if (contact.im)
        [body appendFormat:@"<gd:im address='%@' protocol='http://schemas.google.com/g/2005#GOOGLE_TALK' rel='http://schemas.google.com/g/2005#home' />", contact.im];
    
    [body appendString:@"</atom:entry>"];
}

#pragma mark - SMTP Send Message

- (void)sendMessageTo:(NSString *)to subject:(NSString *)subject body:(NSString *)body completion:(ORGoogleEngineCompletionBlock)completion
{
    // Store the Completion Block to call after the message is sent
    _smtpCompletionBlock = [completion copy];
    
    SKPSMTPMessage *message = [[SKPSMTPMessage alloc] init];
    
    // Uncomment to debug SMTP messages
    //message.debug = YES;
    
    message.fromEmail = [NSString stringWithFormat:@"%@ <%@>", self.userName, self.userEmail];
    message.toEmail = to;
    message.relayHost = G_SMTP_SERVER;
    message.wantsSecure = YES;
    message.requiresOAuth = YES;
    message.oauthString = [self generateXOAuthStringForURL:G_XOAUTH_URL(self.userEmail) method:@"GET"];
    message.delegate = self;
    
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"text/plain", kSKPSMTPPartContentTypeKey,
                               body, kSKPSMTPPartMessageKey,
                               @"8bit", kSKPSMTPPartContentTransferEncodingKey,
                               nil];
    
    message.subject = subject;
    message.parts = [NSArray arrayWithObjects:plainPart, nil];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Sending e-mail..."];
    }
    
    [message send];
}

- (void)sendMessageTo:(NSString *)to subject:(NSString *)subject body:(NSString *)body bodyIsHTML:(BOOL)html attachImage:(UIImage*)image completion:(ORGoogleEngineCompletionBlock)completion
{
    // Store the Completion Block to call after the message is sent
    _smtpCompletionBlock = [completion copy];
    
    SKPSMTPMessage *message = [[SKPSMTPMessage alloc] init];
    
    // Uncomment to debug SMTP messages
    //	message.debug = YES;
    
    message.fromEmail = [NSString stringWithFormat:@"%@ <%@>", self.userName, self.userEmail];
    message.toEmail = to;
    message.relayHost = G_SMTP_SERVER;
    message.wantsSecure = YES;
    message.requiresOAuth = YES;
    message.oauthString = [self generateXOAuthStringForURL:G_XOAUTH_URL(self.userEmail) method:@"GET"];
    message.delegate = self;
    
    NSDictionary *plainPart;
    
    if (html) {
        plainPart = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"text/html", kSKPSMTPPartContentTypeKey,
                     body, kSKPSMTPPartMessageKey,
                     @"8bit", kSKPSMTPPartContentTransferEncodingKey,
                     nil];
    } else {
        plainPart = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"text/plain", kSKPSMTPPartContentTypeKey,
                     body, kSKPSMTPPartMessageKey,
                     @"8bit", kSKPSMTPPartContentTransferEncodingKey,
                     nil];
    }
    
    NSDictionary *image_part;
    
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        image_part = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"image/jpeg", kSKPSMTPPartContentTypeKey,
                      @"inline", kSKPSMTPPartContentDispositionKey,
                      [imageData base64EncodedString], kSKPSMTPPartMessageKey,
                      @"base64", kSKPSMTPPartContentTransferEncodingKey,
                      @"<my_image>", kSKPSMTPPartContentIdKey,
                      nil];
    }
    
    message.subject = subject;
    message.parts = [NSArray arrayWithObjects:plainPart, image_part, nil];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Sending e-mail..."];
    }
    
    [message send];
}

#pragma mark - URL Shortener

- (void)shortenURL:(NSString *)url completion:(ORGoogleStringCompletionBlock)completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   url, @"longUrl",
                                   nil];
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?key=%@",
                        @"https://www.googleapis.com/urlshortener/v1/url",
                        G_API_KEY];
    
    MKNetworkOperation *op = [self operationWithURLString:apiURL
                                              params:params
                                          httpMethod:@"POST"];
    
    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
   
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            NSString *shortURL = [data objectForKey:@"id"];
            
            completion(nil, shortURL);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid data returned.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSGoogleEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    if ([self.delegate respondsToSelector:@selector(googleEngine:statusUpdate:)]) {
        [self.delegate googleEngine:self statusUpdate:@"Shortening URL..."];
    }
    
    [self enqueueOperation:op];
}

- (void)getSearchSuggestionFor:(NSString *)queryString completion:(ORGoogleStringCompletionBlock)completion
{
	NSString *path = @"http://suggestqueries.google.com/complete/search";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   queryString, @"q",
								   @"android", @"client",
                                   nil];
    
    MKNetworkOperation *op = [self operationWithURLString:path
												   params:params
											   httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//		DLog(@"%@", [completedOperation responseString]);
        NSArray *data = [completedOperation responseJSON];
        NSArray *data2 = [data objectAtIndex:1];
        if (data && data2 && data2.count > 0) {
            completion(nil, [data2 objectAtIndex:0]);
        } else {
            NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid data returned.", NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSGoogleEngine.ErrorDomain" code:500 userInfo:ui];
            
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
}

@end

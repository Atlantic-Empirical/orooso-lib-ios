//
//  ORTwitterEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/8/11.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "ORTwitterEngine.h"
#import "ORTweet.h"
#import "ORTwitterUser.h"
#import "ORTwitterUserRelationship.h"
#import "ORTwitterHashtag.h"
#import "ORLanguageIdentifier.h"
#import "ORContact.h"

#define TW_CONSUMER_KEY @"FfVlxu9etFddbRzvh9gpw"
#define TW_CONSUMER_SECRET @"APcBe4vkRNVVgyRQF9yXRXoH7OC4DSsl1euTYHZr7Dc"

// This will be called after the user authorizes your app
#define TW_CALLBACK_URL @"rstwitterengine://auth_token"

// Default twitter hostname and paths
#define TW_HOSTNAME @"api.twitter.com"
#define TW_REQUEST_TOKEN @"oauth/request_token"
#define TW_ACCESS_TOKEN @"oauth/access_token"
#define TW_VERIFY_CREDENTIALS @"1.1/account/verify_credentials.json"
#define TW_STATUS_UPDATE @"1.1/statuses/update.json"
#define TW_MEDIA_UPLOAD @"1.1/statuses/update_with_media.json"
#define TW_HOME_TIMELINE @"1.1/statuses/home_timeline.json"
#define TW_USER_TIMELINE @"1.1/statuses/user_timeline.json"
#define TW_SEARCH_TWEETS @"1.1/search/tweets.json"
#define TW_RELATED_TWEETS(__ID__) [NSString stringWithFormat:@"1/related_results/show/%lld.json", __ID__]
#define TW_DESTROY(__ID__) [NSString stringWithFormat:@"1.1/statuses/destroy/%lld.json", __ID__]
#define TW_RETWEET(__ID__) [NSString stringWithFormat:@"1.1/statuses/retweet/%lld.json", __ID__]
#define TW_FAVORITE @"1.1/favorites/create.json"
#define TW_UNFAVORITE @"1.1/favorites/destroy.json"

#define TW_STATUS_STREAM @"https://stream.twitter.com/1.1/statuses/filter.json"
#define TW_USER_PROFILE @"1.1/users/show.json"
#define TW_FRIEND_IDS @"1.1/friends/ids.json"
#define TW_USER_LOOKUP @"1.1/users/lookup.json"
#define TW_FRIENDSHIPS_LOOKUP @"1.1/friendships/lookup.json"
#define TW_FRIENDSHIPS_FOLLOW @"1.1/friendships/destroy.json"
#define TW_FRIENDSHIPS_UNFOLLOW @"1.1/friendships/destroy.json"

// URL to redirect the user for authentication
#define TW_AUTHORIZE(__TOKEN__) [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@&force_login=true", __TOKEN__]

@interface ORTwitterEngine () <NSStreamDelegate>

@property (nonatomic, strong) NSString *userLanguage;
@property (atomic, strong) ORLanguageIdentifier *langId;
@property (copy, nonatomic) ORTwitterEngineCompletionBlock streamCompletion;
@property (strong, nonatomic) NSMutableData *streamData;
@property (strong, nonatomic) MKNetworkOperation *streamOP;
@property (strong, nonatomic) NSTimer *streamingTimer;
@property (assign, nonatomic) BOOL isStreaming;
@property (assign, nonatomic) BOOL useSSL;

- (void)resetStreamingTimer;
- (void)streamingTimeout;
- (void)parseStreamingData:(NSData *)data;

@end

@implementation ORTwitterEngine

@synthesize delegate = _delegate;
@synthesize screenName = _screenName;
@synthesize userName = _userName;
@synthesize profilePicture = _profilePicture;

#pragma mark - Read-only Properties

- (NSString *)callbackURL
{
    return TW_CALLBACK_URL;
}

#pragma mark - Initialization

+ (ORTwitterEngine *)sharedInstance
{
    return [self sharedInstanceWithConsumerKey:TW_CONSUMER_KEY andSecret:TW_CONSUMER_SECRET];
}

+ (ORTwitterEngine *)sharedInstanceWithConsumerKey:(NSString *)consumerKey andSecret:(NSString *)secret
{
    static dispatch_once_t pred;
    static ORTwitterEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORTwitterEngine alloc] initWithConsumerKey:consumerKey andSecret:secret];
    });
    
    return shared;
}

- (id)initWithConsumerKey:(NSString *)consumerKey andSecret:(NSString *)secret
{
    self = [super initWithHostName:TW_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:RSOAuthHMAC_SHA1
                       consumerKey:consumerKey
                    consumerSecret:secret
                       callbackURL:TW_CALLBACK_URL];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _streamCompletion = nil;
        _screenName = nil;
        _userName = nil;
        _profilePicture = nil;
        _isStreaming = NO;
        _delegate = nil;
        
        self.langId = [[ORLanguageIdentifier alloc] init];
        
        // User's preferred languages
        self.userLanguage = [NSLocale preferredLanguages][0];
        
        // If the user marks the option "HTTPS Only" in his/her profile,
        // Twitter will fail all non-auth requests that use only HTTP
        // with a misleading "OAuth error". I guess it's a bug.
        _useSSL = YES;
    }
    
    return self;
}

- (id)init
{
    return [self initWithConsumerKey:TW_CONSUMER_KEY andSecret:TW_CONSUMER_SECRET];
}

- (void)statusUpdate:(NSString *)status
{
    if ([self.delegate respondsToSelector:@selector(twitterEngine:statusUpdate:)]) {
        [self.delegate twitterEngine:self statusUpdate:status];
    }
}

//================================================================================================================
//
//  OAUTH AUTHENTICATION FLOW
//
//================================================================================================================
#pragma mark - OAuth Authentication Flow

- (void)existingAccountsWithCompletion:(ORTwitterArrayCompletionBlock)completion
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        } else {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, accounts);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,nil);
                });
            }
        }
    }];
}

- (void)reverseAuthWithAccount:(ACAccount *)account completion:(ORTwitterEngineCompletionBlock)completion
{
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];

    MKNetworkOperation *op = [self operationWithPath:TW_REQUEST_TOKEN
                                              params:@{@"x_auth_mode": @"reverse_auth"}
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *params = @{@"x_reverse_auth_target": self.consumerKey,
                                 @"x_reverse_auth_parameters": [completedOperation responseString]};
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@", TW_HOSTNAME, TW_ACCESS_TOKEN]];
        TWRequest *twRequest = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodPOST];
        twRequest.account = account;
        
        [NSURLConnection sendAsynchronousRequest:[twRequest signedURLRequest] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                completion(error);
            } else {
                if (data && data.length > 0) {
                    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                    // Fill the access token with the returned data
                    [self fillTokenWithResponseBody:responseString type:RSOAuthAccessToken];
                    
                    // Retrieve the user's screen name
                    _screenName = [self customValueForKey:@"screen_name"];
                    
                    // Get user Profile
                    [self getProfileWithCompletion:^(NSError *error) {
                        completion(error);
                    }];
                } else {
                    NSError *error = [self errorWithCode:401 message:@"Empty data received."];
                    completion(error);
                }
            }
        }];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    [self statusUpdate:@"Reverse Auth..."];
    [self enqueueSignedOperation:op];
}

- (void)authenticateWithCompletion:(ORTwitterEngineCompletionBlock)completion
{
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completion copy];
    
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];
    
    // OAuth Step 1 - Obtain a request token
    MKNetworkOperation *op = [self operationWithPath:TW_REQUEST_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the request token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthRequestToken];
        
        // OAuth Step 2 - Redirect user to authorization page
        [self statusUpdate:@"Waiting for user authorization..."];
        
        NSURL *url = [NSURL URLWithString:TW_AUTHORIZE(self.token)];
        
        if ([self.delegate respondsToSelector:@selector(twitterEngine:needsToOpenURL:)]) {
            [self.delegate twitterEngine:self needsToOpenURL:url];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
        _oAuthCompletionBlock = nil;
    }];
    
    [self statusUpdate:@"Requesting Tokens..."];
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:RSOAuthRequestToken];
    
    // OAuth Step 3 - Exchange the request token with an access token
    MKNetworkOperation *op = [self operationWithPath:TW_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the access token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthAccessToken];
        
        // Retrieve the user's screen name
        _screenName = [self customValueForKey:@"screen_name"];
        
        // Get user Profile
        [self getProfileWithCompletion:^(NSError *error) {
            if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
            _oAuthCompletionBlock = nil;
        }];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }];
    
    [self statusUpdate:@"Authenticating..."];
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSError *error = [self errorWithCode:401 message:@"Authentication cancelled."];
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)resetOAuthToken
{
    [super resetOAuthToken];
    
    self.screenName = nil;
    self.userName = nil;
    self.profilePicture = nil;
}

//================================================================================================================
//
//  STREAMING
//
//================================================================================================================
#pragma mark - STREAMING

- (void)resetStreamingTimer
{
    [self.streamingTimer invalidate];
    self.streamingTimer = [NSTimer scheduledTimerWithTimeInterval:90
                                                           target:self
                                                         selector:@selector(streamingTimeout)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)streamingTimeout
{
    NSError *error = [self errorWithCode:408 message:@"Streaming timeout."];
    
    [self.streamOP cancel];
    self.streamOP = nil;
    
    self.isStreaming = NO;
    if (self.streamCompletion) self.streamCompletion(error);
    self.streamCompletion = nil;
}

- (void)parseStreamingData:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"Malformed data, should be ignored: %@", error);
		return;
    }
    
    if ([json isKindOfClass:[NSDictionary class]] && [json objectForKey:@"source"] && [json objectForKey:@"text"]) {
        ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:json];
        if ([self.delegate respondsToSelector:@selector(twitterEngine:newTweet:)]) {
            [self.delegate twitterEngine:self newTweet:tweet];
        }
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventEndEncountered: {
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            self.isStreaming = NO;
            if (self.streamCompletion) self.streamCompletion(nil);
            self.streamCompletion = nil;
            break;
        }
        case NSStreamEventErrorOccurred: {
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

            self.isStreaming = NO;
            if (self.streamCompletion) self.streamCompletion(aStream.streamError);
            self.streamCompletion = nil;
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:1024];
            
            if (len) {
                if (!_streamData) _streamData = [NSMutableData dataWithCapacity:len];
                [_streamData appendBytes:(const void *)buf length:len];
                
                char byte_chars[2] = {'\r','\n'};
                NSRange range = [_streamData rangeOfData:[NSData dataWithBytes:byte_chars length:2] options:0 range:NSMakeRange(0, _streamData.length)];
                
                while (range.location != NSNotFound) {
                    if (range.location > 0) {
                        NSData *block = [_streamData subdataWithRange:NSMakeRange(0, range.location)];
                        [self parseStreamingData:block];
                    }
                    
                    if (_streamData.length > range.location+2) {
                        NSData *rest = [_streamData subdataWithRange:NSMakeRange(range.location+2, _streamData.length-(range.location+2))];
                        _streamData = [NSMutableData dataWithData:rest];
                        range = [_streamData rangeOfData:[NSData dataWithBytes:byte_chars length:2] options:0 range:NSMakeRange(0, _streamData.length)];
                    } else {
                        _streamData = nil;
                        range = NSMakeRange(NSNotFound, 0);
                    }
                    
                    [self resetStreamingTimer];
                }
            }
            
            break;
        }
        default: {
            break;
        }
    }
}

- (void)startStreamingStatuses:(NSString *)keywords andAccountIds:(NSString*)accountIds completion:(ORTwitterEngineCompletionBlock)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!keywords && !accountIds) {
            NSError *error = [self errorWithCode:501 message:@"Either/both keywords and/or accounts are required."];
            completion(error);
            return;
        }
        
        if (self.isStreaming) {
            NSError *error = [self errorWithCode:501 message:@"Already streaming."];
            completion(error);
            return;
        }

        self.streamCompletion = completion;
        
        NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
        if (keywords && keywords.length > 0) [postParams setObject:keywords forKey:@"track"];
        if (accountIds && accountIds.length > 0) [postParams setObject:accountIds forKey:@"follow"];
        
        MKNetworkOperation *op = [self operationWithURLString:TW_STATUS_STREAM params:postParams httpMethod:@"POST"];
        [op setPostDataEncoding:MKNKPostDataEncodingTypeURL];
        [op setQueuePriority:NSOperationQueuePriorityHigh];
        
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreateBoundPair(NULL, &readStream, &writeStream, 8196);
        
        NSInputStream *inputStream = (__bridge NSInputStream *)readStream;
        NSOutputStream *outputStream = (__bridge NSOutputStream *)writeStream;
        
        [inputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        
        [op addDownloadStream:outputStream];
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            self.isStreaming = NO;
            self.streamCompletion = nil;
            completion(nil);
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            self.isStreaming = NO;
            self.streamCompletion = nil;
            completion(error);
        }];
        
        self.streamOP = op;
        self.isStreaming = YES;
        [self statusUpdate:@"Streaming Tweets..."];
        [self enqueueSignedOperation:self.streamOP];
        [self resetStreamingTimer];
    });
}

- (void)stopStreaming
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isStreaming) {
            [self.streamOP cancel];
            self.streamOP = nil;
            
            self.isStreaming = NO;
            if (_streamCompletion) _streamCompletion(nil);
            _streamCompletion = nil;
        }
    });
}

//================================================================================================================
//
//  USER TIMELINE
//
//================================================================================================================
#pragma mark - USER TIMELINE

- (MKNetworkOperation *)homeTimeline:(NSUInteger)count maxID:(u_int64_t)maxID sinceID:(u_int64_t)sinceID completion:(ORTwitterArrayCompletionBlock)completion
{
    NSMutableDictionary *params = [@{@"count": [NSString stringWithFormat:@"%d", count],
                                     @"include_my_retweet": @"true"} mutableCopy];
    
    if (maxID != NSNotFound) [params setObject:@(maxID-1) forKey:@"max_id"];
    if (sinceID != NSNotFound) [params setObject:@(sinceID) forKey:@"since_id"];
    
    MKNetworkOperation *op = [self operationWithPath:TW_HOME_TIMELINE
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
		
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:[data count]];
            
            for (NSDictionary *json in data) {
                ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:json];
                [tweets addObject:tweet];
            }
            
            completion(nil, tweets);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error fetching home timeline."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Fetching home timeline..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)userTimeline:(NSString *)user count:(NSUInteger)count completion:(ORTwitterArrayCompletionBlock)completion
{
    NSMutableDictionary *params = [@{@"count": [NSString stringWithFormat:@"%d", count],
                                     @"screen_name": user,
                                     @"include_my_retweet": @"true"} mutableCopy];
    
    MKNetworkOperation *op = [self operationWithPath:TW_USER_TIMELINE
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:[data count]];
            
            for (NSDictionary *json in data) {
                ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:json];
                [tweets addObject:tweet];
            }
            
            completion(nil, tweets);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error fetching user timeline."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Fetching user timeline..."];
    [self enqueueSignedOperation:op];
    return op;
}

//================================================================================================================
//
//  SEARCH
//
//================================================================================================================
#pragma mark - SEARCH

- (MKNetworkOperation *)searchTweets:(NSString *)filter count:(NSUInteger)count maxID:(u_int64_t)maxID sinceID:(u_int64_t)sinceID completion:(ORTwitterArrayCompletionBlock)completion
{
    if (!filter) {
        if (completion) completion(nil, nil);
        return nil;
    }
    
    NSMutableDictionary *params = [@{@"count": [NSString stringWithFormat:@"%d", count],
                                     @"q": filter,
                                     @"result_type": @"mixed",
                                     @"include_my_retweet": @"true"} mutableCopy];

    if (maxID != NSNotFound) params[@"max_id"] = @(maxID-1);
    if (sinceID != NSNotFound) params[@"since_id"] = @(sinceID);
    if (self.userLanguage) params[@"lang"] = self.userLanguage;
    
    MKNetworkOperation *op = [self operationWithPath:TW_SEARCH_TWEETS
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = nil;
        NSDictionary *result = [completedOperation responseJSON];

        if (result && [result isKindOfClass:[NSDictionary class]]) {
            data = [result objectForKey:@"statuses"];
        }
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:[data count]];
            
            for (NSDictionary *json in data) {
                ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:json];
                [tweets addObject:tweet];
            }
            completion(nil, tweets);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error searching tweets."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Searching Tweets..."];
    [self enqueueSignedOperation:op];
    
    return op;
}

- (MKNetworkOperation *)conversationTweetsRelatedTo:(u_int64_t)tweetID count:(NSUInteger)count completion:(ORTwitterArrayCompletionBlock)completion
{
    NSDictionary *params = @{@"include_entities": @"true",
                             @"count": [NSString stringWithFormat:@"%d", count],
                             @"include_my_retweet": @"true"};
    
    MKNetworkOperation *op = [self operationWithPath:TW_RELATED_TWEETS(tweetID)
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSArray	*d = completedOperation.responseJSON;
		if (d && [d isKindOfClass:[NSArray class]]) {
			if (d.count == 0) {
				completion(nil, nil);
			} else {
				NSDictionary *thing = [d objectAtIndex:0];
				NSArray *data = [thing valueForKey:@"results"];
				
				if (data && [data isKindOfClass:[NSArray class]]) {
					NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:[data count]];
					
                    for (NSDictionary *obj in data) {
						if (obj && [[obj valueForKey:@"kind"] isEqualToString:@"Tweet"]) {
							ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:[obj valueForKey:@"value"]];
							[tweets addObject:tweet];
						}
                    }

					completion(nil, tweets);
				}
			}
		}
		// not handled
		NSError *error = [self errorWithCode:500 message:@"Invalid response."];
		completion(error, nil);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Loading related tweets..."];
    [self enqueueSignedOperation:op];
    return op;
}

//================================================================================================================
//
//  POSTING
//
//================================================================================================================
#pragma mark - POSTING

- (MKNetworkOperation *)postTweet:(NSString *)tweet completion:(ORTwitterEngineCompletionBlock)completion
{
    return [self postTweet:tweet inReplyTo:NSNotFound completion:completion];
}

- (MKNetworkOperation *)postTweet:(NSString *)tweet inReplyTo:(u_int64_t)tweetID completion:(ORTwitterEngineCompletionBlock)completion
{
    // Fill the post body with the tweet
    NSMutableDictionary *postParams = [@{@"status": tweet} mutableCopy];
    if (tweetID != NSNotFound) [postParams setObject:[NSString stringWithFormat:@"%lld", tweetID] forKey:@"in_reply_to_status_id"];
    
    MKNetworkOperation *op = [self operationWithPath:TW_STATUS_UPDATE
                                              params:postParams
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            completion(nil);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error posting tweet."];
            completion(error);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    [self statusUpdate:@"Sending tweet..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)postTweet:(NSString *)tweet withImage:(UIImage *)image completion:(ORTwitterEngineCompletionBlock)completion
{
    // Fill the post body with the tweet
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       tweet, @"status",
                                       nil];
    
    MKNetworkOperation *op = [self operationWithPath:TW_MEDIA_UPLOAD
                                              params:postParams
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    // Add the image to the Operation
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [op addData:imageData forKey:@"media"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            completion(nil);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error posting tweet with image."];
            completion(error);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    [self statusUpdate:@"Sending tweet with image..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)destroyId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion
{
    MKNetworkOperation *op = [self operationWithPath:TW_DESTROY(tweetID)
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:data];
            completion(nil, tweet);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error removing tweet/retweet."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Removing tweet/retweet..."];
    [self enqueueSignedOperation:op];
    return op;
}

//================================================================================================================
//
//  RETWEET & FAVORITE
//
//================================================================================================================
#pragma mark - RETWEET & FAVORITE

- (MKNetworkOperation *)retweetId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion
{
    MKNetworkOperation *op = [self operationWithPath:TW_RETWEET(tweetID)
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:data];
            completion(nil, tweet);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error retweeting status."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Retweeting status..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)favoriteId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion
{
    NSDictionary *params = @{@"id": [NSString stringWithFormat:@"%lld", tweetID]};
    MKNetworkOperation *op = [self operationWithPath:TW_FAVORITE
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:data];
            completion(nil, tweet);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error favoriting tweet."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Favoriting tweet..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)unfavoriteId:(u_int64_t)tweetID completion:(ORSingleTweetCompletionBlock)completion
{
    NSDictionary *params = @{@"id": [NSString stringWithFormat:@"%lld", tweetID]};
    MKNetworkOperation *op = [self operationWithPath:TW_UNFAVORITE
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            ORTweet *tweet = [[ORTweet alloc] initWithTwitterJSON:data];
            completion(nil, tweet);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error unfavoriting tweet."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Unfavoriting tweet..."];
    [self enqueueSignedOperation:op];
    return op;
}

//================================================================================================================
//
//  USER PROFILE, FOLLOW, UNFOLLOW
//
//================================================================================================================
#pragma mark - USER PROFILE, FOLLOW, UNFOLLOW

- (MKNetworkOperation *)getProfileWithCompletion:(ORTwitterEngineCompletionBlock)completion
{
    MKNetworkOperation *op = [self operationWithPath:TW_VERIFY_CREDENTIALS
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            self.userId = [data objectForKey:@"id_str"];
            self.screenName = [data objectForKey:@"screen_name"];
            self.userName = [data objectForKey:@"name"];
            self.profilePicture = [data objectForKey:@"profile_image_url"];
            
            if (self.profilePicture) {
                // Rename the image to use the original
                // In the filename, the suffix "_normal" is for small square image, and no suffix for the original image
                self.profilePicture = [self.profilePicture stringByReplacingOccurrencesOfString:@"_normal." withString:@"."];
            }
            
            completion(nil);
        } else {
            NSError *error = [self errorWithCode:401 message:@"Authentication failed."];
            completion(error);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error);
    }];
    
    [self statusUpdate:@"Loading Profile..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)fetchUserProfileForScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserCompletionBlock)completion
{
	NSMutableDictionary *params;
    
	if (screenName)
		params = [@{@"screen_name": [NSString stringWithFormat:@"%@", screenName],
                    @"include_entities": @"true"} mutableCopy];
	else
		params = [@{@"user_id": [NSString stringWithFormat:@"%lld", userId],
                    @"include_entities": @"true"} mutableCopy];

    MKNetworkOperation *op = [self operationWithPath:TW_USER_PROFILE
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
			ORTwitterUser *user = [[ORTwitterUser alloc] initWithTwitterJSON:data];
            completion(nil, user);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error fetching profile."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Fetching profile..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)fetchUserProfilesForScreenNames:(NSArray *)screenNames completion:(ORTwitterArrayCompletionBlock)completion
{
    if (!screenNames) { completion(nil, nil); return nil; }
    
    NSDictionary *params = @{@"screen_name": [screenNames componentsJoinedByString:@","],
                             @"include_entities": @"false"};
    
    MKNetworkOperation *op = [self operationWithPath:TW_USER_LOOKUP
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:data.count];
            
            for (NSDictionary *obj in data) {
                ORTwitterUser *user = [[ORTwitterUser alloc] initWithTwitterJSON:obj];
                [users addObject:user];
            }
			
            completion(nil, users);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error fetching profiles."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Fetching profiles..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)userRelationshipsWithScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserRelationshipsCompletion)completion {
	NSMutableDictionary *params;
	if (screenName)
		params = [@{@"screen_name": [NSString stringWithFormat:@"%@", screenName]} mutableCopy];
   else
	   params = [@{@"user_id": [NSString stringWithFormat:@"%lld", userId]} mutableCopy];

	
    MKNetworkOperation *op = [self operationWithPath:TW_FRIENDSHIPS_LOOKUP
                                              params:params
                                          httpMethod:@"GET"
                                                 ssl:self.useSSL];
    
//	DLog(@"%@", op.url);
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data) {
			ORTwitterUserRelationship *relationship = [[ORTwitterUserRelationship alloc] initWithTwitterJSON:data[0]];
            completion(nil, relationship);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error fetching user relationships."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Fetching user relationships..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)userFollowScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserFollowActionCompletion)completion {
	NSMutableDictionary *params;
	if (screenName)
		params = [@{@"screen_name": [NSString stringWithFormat:@"%@", screenName], @"follow": @"true"} mutableCopy];
	else
		params = [@{@"user_id": [NSString stringWithFormat:@"%lld", userId], @"follow": @"true"} mutableCopy];
	
	
    MKNetworkOperation *op = [self operationWithPath:TW_FRIENDSHIPS_FOLLOW
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
//	DLog(@"%@", op.url);
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        DLog(@"%@", [data description]);
        if (data) {
            completion(nil, YES);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Following user..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)userUnfollowScreenName:(NSString*)screenName orUserId:(u_int64_t)userId completion:(ORUserFollowActionCompletion)completion {
	NSMutableDictionary *params;
	if (screenName)
		params = [@{@"screen_name": [NSString stringWithFormat:@"%@", screenName]} mutableCopy];
	else
		params = [@{@"user_id": [NSString stringWithFormat:@"%lld", userId]} mutableCopy];
	
	
    MKNetworkOperation *op = [self operationWithPath:TW_FRIENDSHIPS_UNFOLLOW
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:self.useSSL];
    
	//	DLog(@"%@", op.url);
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        DLog(@"%@", [data description]);
        if (data) {
            completion(nil, YES);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self statusUpdate:@"Following user..."];
    [self enqueueSignedOperation:op];
    return op;
}

- (MKNetworkOperation *)listContactsWithCompletion:(ORTwitterArrayCompletionBlock)completion
{
    MKNetworkOperation *op = [self operationWithPath:TW_FRIEND_IDS params:@{@"stringify_ids": @"true"} httpMethod:@"GET" ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        NSArray *ids = [data objectForKey:@"ids"];
        
        if (ids && [ids isKindOfClass:[NSArray class]]) {
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:ids.count];
            
            for (NSString *obj in ids) {
                ORContact *contact = [[ORContact alloc] initWithTwitterId:obj];
                [contacts addObject:contact];
            }
			
            completion(nil, contacts);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Error fetching friends."];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueSignedOperation:op];
    return op;
}

#pragma mark Tweet Validation

- (NSMutableArray *)validateTweets:(NSArray *)tweets
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:tweets.count];
    
	for (ORTweet *tw in tweets) {
        if ([self validateTweet:tw]) [result addObject:tw];
    }
    
	return result;
}

- (BOOL)validateTweet:(ORTweet*)tweet
{
	if (tweet.hashtags) {
		int lengthOfTweet = tweet.text.length;
		int lengthOfContainedHashtags = 0;
		for (ORTwitterHashtag *ht in tweet.hashtags){
			lengthOfContainedHashtags += ht.text.length;
		}
		
		// HASHTAG(S) ONLY?
		// (spamming for views)
		if (lengthOfTweet - lengthOfContainedHashtags <= 5) {
			return NO;
		}
        
		// RATIO OF HASHTAGS TO "REAL" CONTENT
		// example = ~16% or 9 chars to 54 chars
		//	season one
		//	#thementalist #patricjane #teresalisbone #jisbone #redjohn
		float ratio = (float)lengthOfContainedHashtags / (float)lengthOfTweet;
		if (ratio >= 0.25f) {
			return NO;
		}
        
	}
    
    // Try to detect language if not returned from Twitter
    if (!tweet.language || [tweet.language isEqualToString:@"und"]) {
        tweet.language = [self.langId languageOfString:tweet.text];
    }
    
	if (tweet.language) {
        // Undefined, let it pass
		if ([tweet.language isEqualToString:@"und"]) return YES;
        
        // Check against user language
        if ([tweet.language isEqualToString:self.userLanguage]) return YES;

        // Fallback for English
        if ([tweet.language isEqualToString:@"en"]) return YES;
        
        return NO;
	}
    
	return YES;
}

//================================================================================================================
//
//  UTILITY
//
//================================================================================================================
#pragma mark - UTILITY

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    NSDictionary *ui = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"com.orooso.ORTwitterEngine" code:code userInfo:ui];
    return error;
}

@end

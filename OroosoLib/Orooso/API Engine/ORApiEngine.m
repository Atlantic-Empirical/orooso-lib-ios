//
//  ORApiEngine.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 11/30/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORApiEngine.h"
#import "ORImage.h"
#import "ORApiRequestSigner.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "ORUser.h"
#import "ORFriend.h"
#import "ORLogItem.h"
#import "ORBoard.h"
#import "ORBoardItem.h"
#import "ORSFItem.h"
#import "ORInstantResult.h"
#import "ORITunesObject.h"
#import "ORYouTubeLiveEvent.h"
#import "ORTVNZArticle.h"
#import "OREmailType.h"
#import "ORSpotShare.h"
#import "ORSpotLocation.h"
#import "ORITunesApp.h"
#import "ORConstants.h"
#import "ORUserMessage.h"

@interface ORApiEngine ()

@property (nonatomic, assign) BOOL useSSL;

@end

@implementation ORApiEngine

#define API_VERSION @"v1.1/"
#define SERVICE_PATH_LOGGING API_VERSION"log"
#define SERVICE_PATH_USER API_VERSION"user"
#define SERVICE_PATH_ADMIN API_VERSION"admin"
#define SERVICE_PATH_BOARDS API_VERSION"boards"
#define SERVICE_PATH_CONTENT API_VERSION"content"
#define SERVICE_PATH_SHARING API_VERSION"sharing"
#define SERVICE_PATH_SPOT API_VERSION"spot"
#define SERVICE_PATH_IR API_VERSION"ir"

- (void)enqueueOperation:(MKNetworkOperation *)request
{
    if (!self.currentAppCode) self.currentAppCode = @"P";
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:4];
    
	NSString *timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
    NSString *signature = [ORApiRequestSigner generateSignatureForUrl:request.url withTimestamp:timestamp];
    
    [headers setObject:timestamp forKey:@"X-Orooso-Timestamp"];
    [headers setObject:signature forKey:@"X-Orooso-Sig"];
    if (self.currentUserID) [headers setObject:self.currentUserID forKey:@"X-Orooso-UserId"];
    if (self.currentSessionID) [headers setObject:self.currentSessionID forKey:@"X-Orooso-SessionId"];
    [headers setObject:self.currentAppCode forKey:@"X-Orooso-AppCode"];

    [request addHeaders:headers];
    [super enqueueOperation:request];
}

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    NSDictionary *ui = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"com.orooso.ORApiEngine" code:code userInfo:ui];
    return error;
}

//================================================================================================================
//
//  CONSTRUCTORS
//
//================================================================================================================
#pragma mark - Constructors

+ (ORApiEngine *)sharedInstance
{
    return [self sharedInstanceWithHostname:@"api.orooso.com" portNumber:80 useSSL:YES];
}

+ (ORApiEngine *)sharedInstanceWithHostname:(NSString *)hostName portNumber:(NSUInteger)portNumber useSSL:(BOOL)useSSL
{
    static dispatch_once_t pred;
    static ORApiEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORApiEngine alloc] initWithHostname:hostName portNumber:portNumber useSSL:useSSL];
    });
    
    return shared;
}

- (id)initWithHostname:(NSString *)hostName portNumber:(NSUInteger)portNumber useSSL:(BOOL)useSSL
{
    self = [super initWithHostName:hostName customHeaderFields:nil];
    
    if (self) {
        if (portNumber != 80 && portNumber != 443) self.portNumber = portNumber;
        _useSSL = useSSL;        
        _baseURLString = [NSString stringWithFormat:@"%@%@",
                          hostName,
                          (portNumber != 80 && portNumber != 443) ? [NSString stringWithFormat:@":%d", portNumber] : @""];
    }
    
    return self;
}

#pragma mark - Instant Results

- (MKNetworkOperation *)instantResults:(NSString *)query cb:(ORArrayCompletion)completion
{
    NSDictionary *params = @{@"q": query};
    NSString *path = [NSString stringWithFormat:@"%@", SERVICE_PATH_IR];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORInstantResult arrayWithJSON:data];
            completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

//================================================================================================================
//
//  STRINGS
//
//================================================================================================================
#pragma mark - Strings

- (MKNetworkOperation *)clientStringForKey:(NSString *)key cb:(ORStringCompletion)completion
{
    NSString *path = [NSString stringWithFormat:@"%@/clientstring/%@/%@", SERVICE_PATH_ADMIN, @"en", key];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *fullString = [data valueForKey:@"FullString"];
            completion(nil, fullString);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)clientStringsForKeys:(NSArray *)keys cb:(ORDictionaryCompletion)completion
{
    NSString *csv = [keys componentsJoinedByString:@","];
    NSString *path = [NSString stringWithFormat:@"%@/clientstrings/%@/%@", SERVICE_PATH_ADMIN, @"en", csv];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:data.count];
            
            for (NSDictionary *item in data) {
                NSString *key = [item valueForKey:@"Id"];
                NSString *value = [item valueForKey:@"FullString"];
                [dict setValue:value forKey:key];
            }

            completion(nil, dict);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}


//================================================================================================================
//
//  CONTENT
//
//================================================================================================================
#pragma mark - Content

- (MKNetworkOperation *)fetchEntity:(NSString *)entityId entityType:(OREntityType)entityType cb:(OREntityCompletion)completionBlock
{
    NSDictionary *params = @{@"entityType": [NSString stringWithFormat:@"%d", entityType]};
    
    NSString *path = [NSString stringWithFormat:@"%@/entity/%@", SERVICE_PATH_CONTENT, [entityId or_urlPathEncodedString]];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
 
        if (data) {
            OREntity *result = [OREntity instanceWithJSON:data];
            completionBlock(nil, result);
        } else {
            NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)touchEntity:(NSString *)entityId entityType:(OREntityType)entityType cb:(ORBoolCompletion)completionBlock
{
    if (!entityId) {
        if (completionBlock) completionBlock(nil, YES);
        return nil;
    }
    
    NSDictionary *params = @{@"entityType": [NSString stringWithFormat:@"%d", entityType]};
    
    NSString *path = [NSString stringWithFormat:@"%@/entity/touch/%@", SERVICE_PATH_CONTENT, [entityId or_urlPathEncodedString]];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (completionBlock) completionBlock(nil, YES);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)requestEntityNamed:(NSString *)entityName cb:(ORBoolCompletion)completionBlock
{
    if (!entityName) {
        if (completionBlock) completionBlock(nil, NO);
        return nil;
    }
    
    NSDictionary *params = @{@"name": entityName};
    NSString *path = [NSString stringWithFormat:@"%@/requestentity", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (completionBlock) completionBlock(nil, YES);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)matchEntityNamed:(NSString *)entityName mid:(NSString *)mid cb:(OREntityCompletion)completionBlock
{
    if (!entityName && !mid) {
        if (completionBlock) completionBlock(nil, nil);
        return nil;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    if (entityName) params[@"name"] = entityName;
    if (mid) params[@"mid"] = mid;
    
    NSString *path = [NSString stringWithFormat:@"%@/match", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data) {
            OREntity *result = [OREntity instanceWithJSON:data];
            completionBlock(nil, result);
        } else {
            completionBlock(nil, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)itunesSearch:(NSString *)query entityType:(OREntityType)entityType page:(NSUInteger)page count:(NSUInteger)count explicit:(BOOL)explicit cb:(ORArrayCompletion)completionBlock
{
    // Only search iTunes for recording artists and TV shows
    if (entityType != OREntityType_RecordingArtist && entityType != OREntityType_TVShow) {
        if (completionBlock) completionBlock(nil, nil);
        return nil;
    }
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *countryCode = [[locale objectForKey:NSLocaleCountryCode] uppercaseString];
    language = [NSString stringWithFormat:@"%@_%@", [language lowercaseString], [countryCode lowercaseString]];
    if (![language isEqualToString:@"ja_jp"]) language = @"en_us";
    if (!countryCode) countryCode = @"US";
    
    NSDictionary *params = @{@"q": query,
                             @"entityType": [NSString stringWithFormat:@"%d", entityType],
                             @"page": @(page),
                             @"count": @(count),
                             @"isexplicit": (explicit) ? @"true" : @"false",
                             @"country": countryCode,
                             @"language": language};
    
    NSString *path = [NSString stringWithFormat:@"%@/itunes/search", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];

    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        NSArray *result = [ORITunesObject arrayWithJSON:data];
        completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)blacklistVideoID:(NSString *)videoID cb:(ORBoolCompletion)completionBlock
{
    if (!videoID) { completionBlock(nil, YES); return nil; }
    
    NSDictionary *params = @{@"VideoID": videoID,
                             @"Device": @"ios"};
    
	NSString *path = [NSString stringWithFormat:@"%@/blacklistvideo", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)youTubeLiveEvents:(NSUInteger)page count:(NSUInteger)count cb:(ORArrayCompletion)completionBlock
{
    NSDictionary *params = @{@"page": @(page),
                             @"count": @(count)};
    
    NSString *path = [NSString stringWithFormat:@"%@/youtube/live", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        NSArray *items = [ORYouTubeLiveEvent arrayWithJSON:data];
        
        completionBlock(nil, items);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)tvnzVideos:(NSUInteger)page count:(NSUInteger)count cb:(ORArrayCompletion)completionBlock
{
    NSDictionary *params = @{@"page": @(page),
                             @"count": @(count)};
    
    NSString *path = [NSString stringWithFormat:@"%@/tvnz/videos", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        NSArray *items = [ORTVNZArticle arrayWithJSON:data];
        
        completionBlock(nil, items);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getFeedWithCompletion:(ORArrayCompletion)completionBlock
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [[locale objectForKey:NSLocaleCountryCode] uppercaseString];
    if (!country) country = @"US";
    
    NSDictionary *params = @{@"country": country};
    NSString *path = [NSString stringWithFormat:@"%@/feed", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
		if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *result = [ORInstantResult arrayWithJSON:data];
			completionBlock(nil, result);
		} else {
			completionBlock(nil, nil);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getHistoryWithCompletion:(ORArrayCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/history", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
		if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *result = [ORInstantResult arrayWithJSON:data];
			completionBlock(nil, result);
		} else {
			completionBlock(nil, nil);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)fetchContent:(NSString *)entityId
                          entityType:(OREntityType)entityType
                       maturityLevel:(NSUInteger)maturityLevel
                             country:(NSString *)country
                            language:(NSString *)language
                                page:(NSUInteger)page
                            latitude:(double)latitude
                           longitude:(double)longitude
                                  cb:(ORArrayCompletion)completion
{
    NSMutableDictionary *params = [@{@"entityType": [NSString stringWithFormat:@"%d", entityType],
                                     @"maturityLevel": [NSString stringWithFormat:@"%d", maturityLevel],
                                     @"country": country,
                                     @"language": language,
                                     @"page": [NSString stringWithFormat:@"%d", page]} mutableCopy];
    
    if (latitude != 0 || longitude != 0) {
        [params setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/entity/content/%@", SERVICE_PATH_CONTENT, [entityId or_urlPathEncodedString]];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:data.count];
            
            for (NSDictionary *json in data) {
                ORSFItem *item = [ORSFItem instanceWithJSON:json];
                if (item) [items addObject:item];
            }

            completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)fetchDynamicContent:(NSString *)entityName
                              maturityLevel:(NSUInteger)maturityLevel
                                    country:(NSString *)country
                                   language:(NSString *)language
                                       page:(NSUInteger)page
                                   latitude:(double)latitude
                                  longitude:(double)longitude
                                         cb:(ORArrayCompletion)completion
{
    NSMutableDictionary *params = [@{@"entityName": entityName,
                                     @"maturityLevel": [NSString stringWithFormat:@"%d", maturityLevel],
                                     @"country": country,
                                     @"language": language,
                                     @"page": [NSString stringWithFormat:@"%d", page]} mutableCopy];
    
    if (latitude != 0 || longitude != 0) {
        [params setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
        [params setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/dynamic/content", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:data.count];
            
            for (NSDictionary *json in data) {
                ORSFItem *item = [ORSFItem instanceWithJSON:json];
                if (item) [items addObject:item];
            }
            
            completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

//================================================================================================================
//
//  IMAGES
//
//================================================================================================================
#pragma mark - Images

- (MKNetworkOperation *)imageQuery:(NSString *)queryString page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORArrayCompletion)completionBlock
{
    if (!queryString) {
        if (completionBlock) completionBlock(nil, nil);
        return nil;
    }

    NSDictionary *params = @{@"q": queryString,
                             @"page": @(page),
                             @"count": @(count),
                             @"maturitylevel": @(maturityLevel)};
    
    NSString *path = [NSString stringWithFormat:@"%@/images", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        NSArray *result = [ORImage arrayWithJSON:data];
        completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)imageQueryMultiple:(NSArray *)queries page:(NSUInteger)page count:(NSUInteger)count maturityLevel:(NSUInteger)maturityLevel cb:(ORArrayCompletion)completionBlock
{
    if (!queries) {
        if (completionBlock) completionBlock(nil, nil);
        return nil;
    }

    NSString *fullQuery = [queries componentsJoinedByString:@","];
    NSDictionary *params = @{@"q": fullQuery,
                             @"page": @(page),
                             @"count": @(count),
                             @"maturitylevel": @(maturityLevel)};
    
    NSString *path = [NSString stringWithFormat:@"%@/images/multiple", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        NSArray *result = [ORImage arrayWithJSON:data];
        completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)representativeImage:(NSString *)query cb:(ORImageCompletion)completionBlock
{
    if (!query) {
        if (completionBlock) completionBlock(nil, nil);
        return nil;
    }
    
    NSDictionary *params = @{@"q": query};
    NSString *path = [NSString stringWithFormat:@"%@/images/representative", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        completionBlock(nil, [ORImage instanceWithJSON:data]);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

//================================================================================================================
//
//  USER
//
//================================================================================================================
#pragma mark - User

- (MKNetworkOperation *)signInUserEmail:(NSString *)userEmail withPwHash:(NSString *)userPwHash cb:(ORUserCompletion)completionBlock
{
    NSDictionary *params = @{@"EmailAddress": userEmail,
                             @"Password": userPwHash};

    NSString *path = [NSString stringWithFormat:@"%@/signin", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];

        if (data && [data isKindOfClass:[NSDictionary class]]) {
            ORUser *user = [ORUser instanceWithJSON:data];
            if (user) {
                self.currentUserID = user.userId;
                self.defaultBoardId = self.currentUserID;
            }
			completionBlock(nil, user);
        } else {
			completionBlock(nil, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)reauthUserEmail:(NSString *)userEmail withPwHash:(NSString *)userPwHash cb:(ORArrayCompletion)completionBlock
{
    NSDictionary *params = @{@"EmailAddress": userEmail,
                             @"Password": userPwHash};

	NSString *path = [NSString stringWithFormat:@"%@/reauth/pairings", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:data.count];
			for (NSDictionary *item in data) {
				[result addObject:[[OAuthPairingInfo alloc] initWithJson:item]];
			}
			completionBlock(nil, result);
        } else {
			NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)saveUser:(ORUser*)user cb:(ORUserCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/save", SERVICE_PATH_USER];

    MKNetworkOperation *op = [self operationWithPath:path params:[user proxyForJson] httpMethod:@"POST" ssl:self.useSSL];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            ORUser *user = [ORUser instanceWithJSON:data];

            if (user && user.userId) {
                self.currentUserID = user.userId;
                self.defaultBoardId = user.userId;
                completionBlock(nil, user);
            } else {
                completionBlock(nil, nil);
            }
        } else {
			completionBlock(nil, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)deleteUserByEmail:(NSString *)userEmail withPwHash:(NSString *)pwHash cb:(ORBoolCompletion)completionBlock
{
	if (!userEmail || !pwHash) return nil;
    
    NSDictionary *params = @{@"EmailAddress": userEmail,
                             @"Password": pwHash};

    NSString *path = [NSString stringWithFormat:@"%@/delete", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)storePairing:(OAuthPairingInfo *)pairInfo cb:(ORBoolCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/pairing/store", SERVICE_PATH_USER];

    MKNetworkOperation *op = [self operationWithPath:path params:[pairInfo proxyForJson] httpMethod:@"POST" ssl:self.useSSL];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)listPairingsWithCompletion:(ORArrayCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/pairing/list", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:self.useSSL];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:data.count];
			for (NSDictionary *item in data) {
				[result addObject:[[OAuthPairingInfo alloc] initWithJson:item]];
			}
			completionBlock(nil, result);
        } else {
			NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];

    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)removePairing:(OAuthPairingInfo *)pairInfo cb:(ORBoolCompletion)completionBlock
{
    NSDictionary *params = @{@"PairingId": (pairInfo.pairId) ? pairInfo.pairId : @"0"};

    NSString *path = [NSString stringWithFormat:@"%@/pairing/delete", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)userForgotPassword:(NSString *)userEmail cb:(ORBoolCompletion)completionBlock
{
	if (userEmail == nil || [userEmail isEqualToString:@""]) return nil;
	
	NSDictionary *params = @{@"emailAddress": userEmail};
    NSString *path = [NSString stringWithFormat:@"%@/forgotpassword", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)clearHistoryWithCompletion:(ORBoolCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/clearhistory", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"POST" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)emailTypesWithCompletion:(ORArrayCompletion)completion
{
    NSString *path = [NSString stringWithFormat:@"%@/emailtypes", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [OREmailType arrayWithJSON:data];
			completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)saveOptedOutEmails:(NSArray *)emails cb:(ORBoolCompletion)completion
{
    NSString *path = [NSString stringWithFormat:@"%@/saveoptedout", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:@{@"emails": emails} httpMethod:@"POST" ssl:self.useSSL];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completion(nil, YES);
		} else {
			completion(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)registerDeviceForPush:(NSString *)deviceID cb:(ORBoolCompletion)completion
{
    NSString *path = [NSString stringWithFormat:@"%@/regdevice", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:@{@"DeviceID": deviceID} httpMethod:@"POST" ssl:self.useSSL];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			if (completion) completion(nil, YES);
		} else {
			if (completion) completion(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completion) completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)notificationsSince:(NSString *)lastSeenId completion:(ORArrayCompletion)completion
{
    if (!self.currentUserID) { completion(nil, nil); return nil; }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"userId"] = self.currentUserID;
    if (lastSeenId) params[@"lastSeenId"] = lastSeenId;
    
    NSString *path = [NSString stringWithFormat:@"%@/notifications", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORUserMessage arrayWithJSON:data];
			completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}


//  FEEDBACK
//================================================================================================================
#pragma mark - FEEDBACK

- (MKNetworkOperation *)sendFeedback:(NSString *)feedback emailAddress:(NSString*)emailAddress cb:(ORBoolCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/feedback", SERVICE_PATH_USER];
	
    MKNetworkOperation *op = [self operationWithPath:path params:[NSDictionary dictionaryWithObjectsAndKeys:feedback, @"Feedback", emailAddress, @"EmailAddress", nil] httpMethod:@"POST" ssl:self.useSSL];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if ([[completedOperation responseString] isEqualToString:@"true"] == YES) {
			completionBlock(nil, YES);
		} else {
			completionBlock(nil, NO);
		}
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    [self enqueueOperation:op];
    return op;
}

//  ADMIN
//================================================================================================================
#pragma mark - Admin

- (MKNetworkOperation *)getSettingNamed:(NSString*)settingName completion:(ORStringCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/settingstring/%@", SERVICE_PATH_ADMIN, [settingName or_urlPathEncodedString]];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *str = [completedOperation responseString];
		str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		completionBlock(nil, str);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, nil);
    }];
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getAppWithBundleId:(NSString *)bundleId completion:(ORAppCompletion)completion
{
    NSDictionary *params = @{@"bundleId": bundleId};
    MKNetworkOperation *op = [self operationWithURLString:@"http://itunes.apple.com/lookup" params:params httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *result = [completedOperation responseJSON];
        NSArray *items = result[@"results"];
        
        if (items && [items isKindOfClass:[NSArray class]] && items.count > 0) {
            ORITunesApp *app = [ORITunesApp instanceWithJSON:items[0]];
            completion(nil, app);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [super enqueueOperation:op];
    return op;
}

//  LOGGING
//================================================================================================================
#pragma mark - Logging

- (MKNetworkOperation *)startSessionWithCB:(ORStringCompletion)completionBlock
{
    self.currentSessionID = [ORUtility newGuidString];
    NSString *client;
    NSString *debug;
    
#if TARGET_IPHONE_SIMULATOR
    client = @"iOS Simulator";
#else
    client = ISIPAD ? @"iPad" : @"iPhone";
#endif
    
#if DEBUG
    debug = @"true";
#else
    debug = @"false";
#endif
    
    NSMutableDictionary *params = [@{@"SessionId": self.currentSessionID,
                                     @"Client": client,
                                     @"ClientVersion": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                     @"Debug": debug} mutableCopy];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [[locale objectForKey:NSLocaleCountryCode] uppercaseString];
    if (countryCode) [params setObject:countryCode forKey:@"UserCountry"];
    if (self.currentClientID) [params setObject:self.currentClientID forKey:@"ClientId"];
    
    NSString *path = [NSString stringWithFormat:@"%@/startsession", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (completionBlock) completionBlock(nil, [completedOperation responseString]);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    
    NSLog(@"Started a New Session: %@", self.currentSessionID);
    return op;
}

- (MKNetworkOperation *)postLogItem:(ORLogItem*)logItem cb:(ORIntegerCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/postitem", SERVICE_PATH_LOGGING];

    MKNetworkOperation *op = [self operationWithPath:path params:[logItem proxyForJson] httpMethod:@"POST" ssl:self.useSSL];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if (completionBlock) completionBlock(nil, completedOperation.HTTPStatusCode);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, 10000);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)postLogItems:(NSArray*)logItems cb:(ORIntegerCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/postitems", SERVICE_PATH_LOGGING];
    MKNetworkOperation *op = [self operationWithPath:path params:[NSDictionary dictionaryWithObject:logItems forKey:@"logItemBatch"] httpMethod:@"POST" ssl:self.useSSL];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		if (completionBlock) completionBlock(nil, completedOperation.HTTPStatusCode);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (completionBlock) completionBlock(error, 10000);
    }];
    
    [self enqueueOperation:op];
    return op;
}

//================================================================================================================
//
//  BOARDS
//
//================================================================================================================
#pragma mark - Boards

- (MKNetworkOperation *)getBoardsWithCompletion:(ORArrayCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/list", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORBoard arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getBoard:(NSString *)boardId cb:(ORBoardCompletion)completionBlock
{
    NSDictionary *params = @{@"boardId": boardId};
    NSString *path = [NSString stringWithFormat:@"%@/board", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            ORBoard *board = [ORBoard instanceWithJSON:data];
			completionBlock(nil, board);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)deleteBoard:(NSString *)boardId cb:(ORBoolCompletion)completionBlock
{
    NSDictionary *params = @{@"boardId": boardId};
    NSString *path = [NSString stringWithFormat:@"%@/remove", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)saveBoard:(ORBoard *)board cb:(ORBoardCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/save", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:[board proxyForJson] httpMethod:@"POST" ssl:NO];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            ORBoard *board = [ORBoard instanceWithJSON:data];
			completionBlock(nil, board);
        } else {
            if ([[completedOperation responseString] isEqualToString:@"null"]) {
                completionBlock(nil, nil);
            } else {
                NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
                completionBlock(error, nil);
            }
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getBoardItems:(NSString *)boardId cb:(ORArrayCompletion)completionBlock
{
    NSDictionary *params = @{@"boardId": boardId};
    NSString *path = [NSString stringWithFormat:@"%@/items", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORBoardItem arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)saveBoardItem:(ORBoardItem *)item cb:(ORStringCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/items/save", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:[item proxyForJson] httpMethod:@"POST" ssl:NO];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSString *data = [completedOperation responseString];
        
        if (data && [data isKindOfClass:[NSString class]]) {
            if ([data isEqualToString:@"null"]) {
                completionBlock(nil, nil);
            } else {
                completionBlock(nil, data);
            }
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)removeItemFromBoard:(NSString *)boardId itemId:(NSString *)itemId newImageURL:(NSString *)imageURL cb:(ORBoolCompletion)completionBlock
{
    NSDictionary *params;
    
    if (imageURL) {
        params = @{@"boardId": boardId,
                   @"itemId": itemId,
                   @"imageUrl": imageURL};
    } else {
        params = @{@"boardId": boardId,
                   @"itemId": itemId};
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/items/remove", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)publicBoardsFor:(NSString *)userId completion:(ORArrayCompletion)completionBlock
{
    NSAssert(userId, @"UserId parameter is required");
    NSDictionary *params = @{@"userId": userId};
    NSString *path = [NSString stringWithFormat:@"%@/list/public", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORBoard arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)boardsForItem:(NSString *)itemId cb:(ORArrayCompletion)completionBlock
{
    NSDictionary *params = @{@"itemId": itemId};
    NSString *path = [NSString stringWithFormat:@"%@/items/boards", SERVICE_PATH_BOARDS];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
			completionBlock(nil, data);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

#pragma mark - Graph

- (MKNetworkOperation *)followUser:(NSString *)userId completion:(ORBoolCompletion)completionBlock
{
    NSDictionary *params = @{@"UserId": userId};
	NSString *path = [NSString stringWithFormat:@"%@/followuser", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)followBoard:(NSString *)boardId completion:(ORBoolCompletion)completionBlock
{
    NSDictionary *params = @{@"BoardId": boardId};
	NSString *path = [NSString stringWithFormat:@"%@/followboard", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)unfollowUser:(NSString *)userId completion:(ORBoolCompletion)completionBlock
{
    NSDictionary *params = @{@"UserId": userId};
	NSString *path = [NSString stringWithFormat:@"%@/unfollowuser", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)unfollowBoard:(NSString *)boardId completion:(ORBoolCompletion)completionBlock
{
    NSDictionary *params = @{@"BoardId": boardId};
	NSString *path = [NSString stringWithFormat:@"%@/followboard", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)followingUsersFor:(NSString *)userId completion:(ORArrayCompletion)completionBlock
{
    if (!userId) userId = self.currentUserID;
    NSDictionary *params = @{@"userId": userId};
    NSString *path = [NSString stringWithFormat:@"%@/followingusers", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORFriend arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)followingBoardsFor:(NSString *)userId completion:(ORArrayCompletion)completionBlock
{
    if (!userId) userId = self.currentUserID;
    NSDictionary *params = @{@"userId": userId};
    NSString *path = [NSString stringWithFormat:@"%@/followingboards", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORBoard arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)followersForUser:(NSString *)userId completion:(ORArrayCompletion)completionBlock
{
    if (!userId) userId = self.currentUserID;
    NSDictionary *params = @{@"userId": userId};
    NSString *path = [NSString stringWithFormat:@"%@/userfollowers", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORFriend arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)followersForBoard:(NSString *)boardId completion:(ORArrayCompletion)completionBlock
{
    NSAssert(boardId, @"Missing Parameter: boardId");
    NSDictionary *params = @{@"boardId": boardId};
    NSString *path = [NSString stringWithFormat:@"%@/boardfollowers", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORFriend arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)activityFeedWithCompletion:(ORArrayCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/activityfeed", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:nil httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORBoardItem arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)usersForHashes:(NSArray *)hashes completion:(ORArrayCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/usersforhashes", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:@{@"hashes": hashes} httpMethod:@"POST" ssl:NO];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORFriend arrayWithJSON:data];
			completionBlock(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)getFriend:(NSString *)friendId completion:(ORFriendCompletion)completionBlock
{
    NSDictionary *params = @{@"friendId": friendId};
    NSString *path = [NSString stringWithFormat:@"%@/friend", SERVICE_PATH_USER];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            ORFriend *friend = [ORFriend instanceWithJSON:data];
			completionBlock(nil, friend);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completionBlock(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)inviteFriends:(NSArray *)friends sender:(ORContactItem *)sender completion:(ORBoolCompletion)completionBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/invitefriends", SERVICE_PATH_USER];
	NSDictionary *params = @{@"sender": [sender proxyForJson], @"recipients": [ORContactItem proxyForJsonWithArray:friends]};

    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"POST" ssl:self.useSSL];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

#pragma mark - URL Shortening

- (MKNetworkOperation *)resolveURL:(NSString *)url cb:(ORURLCompletion)completion
{
    NSDictionary *params = @{@"u": url};
    
    NSString *path = [NSString stringWithFormat:@"%@/resolveurl", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *result = [completedOperation responseJSON];
        
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            ORURL *newURL = [ORURL instanceWithJSON:result];
            newURL.resolveOperation = completedOperation;
            completion(nil, newURL);
        } else {
            NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)resolveURLs:(NSArray *)urls cb:(ORArrayCompletion)completion
{
    NSString *path = [NSString stringWithFormat:@"%@/resolveurls", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:@{@"urls": urls} httpMethod:@"POST" ssl:NO];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORURL arrayWithJSON:data];
			completion(nil, items);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)submitURL:(ORURL *)url cb:(ORBoolCompletion)completionBlock
{
	NSString *path = [NSString stringWithFormat:@"%@/submiturl", SERVICE_PATH_CONTENT];
    MKNetworkOperation *op = [self operationWithPath:path params:[url proxyForJson] httpMethod:@"POST" ssl:NO];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completionBlock(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)shortenURL:(NSString *)url cb:(ORStringCompletion)completion
{
	if (!url){
		completion(nil, nil);
		return nil;
	}
	
	NSDictionary *params = @{@"url": url};

    NSString *path = [NSString stringWithFormat:@"%@/shorten", SERVICE_PATH_SHARING];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *result = [completedOperation responseJSON];
        
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            NSString *shortURL = [result valueForKey:@"ShortURL"];
            completion(nil, shortURL);
        } else {
            NSError *error = [self errorWithCode:401 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

#pragma mark - SpotMe

- (MKNetworkOperation *)shareSpot:(ORSpotShare *)spot cb:(ORStringCompletion)completion
{
	NSString *path = [NSString stringWithFormat:@"%@/share", SERVICE_PATH_SPOT];
    MKNetworkOperation *op = [self operationWithPath:path params:[spot proxyForJson] httpMethod:@"POST" ssl:NO];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *str = [completedOperation responseString];
		str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		completion(nil, str);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)updateSpots:(ORSpotLocation *)spot cb:(ORBoolCompletion)completion
{
	NSString *path = [NSString stringWithFormat:@"%@/update", SERVICE_PATH_SPOT];
    MKNetworkOperation *op = [self operationWithPath:path params:[spot proxyForJson] httpMethod:@"POST" ssl:NO];
	[op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
	
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completion(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)loadSpot:(NSString *)spotShareID cb:(ORSpotCompletion)completion
{
    NSDictionary *params = @{@"id": spotShareID};
    NSString *path = [NSString stringWithFormat:@"%@/load", SERVICE_PATH_SPOT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *result = [completedOperation responseJSON];
        
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            ORSpotShare *spot = [ORSpotShare instanceWithJSON:result];
            completion(nil, spot);
        } else if ([completedOperation.responseString isEqualToString:@"null"]) {
            completion(nil, nil);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)loadSpotLocations:(NSArray *)spotShareIDs cb:(ORArrayCompletion)completion
{
    NSString *path = [NSString stringWithFormat:@"%@/location", SERVICE_PATH_SPOT];
    MKNetworkOperation *op = [self operationWithPath:path params:@{@"ids": spotShareIDs} httpMethod:@"POST" ssl:NO];
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSArray *data = [completedOperation responseJSON];
        
        if (data && [data isKindOfClass:[NSArray class]]) {
            NSArray *items = [ORSpotLocation arrayWithJSON:data];
			completion(nil, items);
        } else if ([completedOperation.responseString isEqualToString:@"null"]) {
            completion(nil, nil);
        } else {
            NSError *error = [self errorWithCode:500 message:@"Unexpected Response"];
            completion(error, nil);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, nil);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)removeSpot:(NSString *)spotShareID cb:(ORBoolCompletion)completion
{
    NSDictionary *params = @{@"id": spotShareID};
    NSString *path = [NSString stringWithFormat:@"%@/remove", SERVICE_PATH_SPOT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completion(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)resendSpot:(NSString *)spotShareID cb:(ORBoolCompletion)completion
{
    NSDictionary *params = @{@"id": spotShareID};
    NSString *path = [NSString stringWithFormat:@"%@/resend", SERVICE_PATH_SPOT];
    MKNetworkOperation *op = [self operationWithPath:path params:params httpMethod:@"GET" ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSString *data = [completedOperation responseString];
        BOOL result = [data isEqualToString:@"true"];
		completion(nil, result);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completion(error, NO);
    }];
    
    [self enqueueOperation:op];
    return op;
}

@end

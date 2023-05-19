//
//  ORURLResolver.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 15/11/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORURLResolver.h"
#import "ORApiRequestSigner.h"
#import "ORApiEngine.h"
#import "ORURL.h"

@interface ORURLResolver ()

@property (atomic, strong) NSMutableDictionary *resolvedURLs;
@property (atomic, strong) NSMutableDictionary *resolvedIconURLs;
@property (atomic, strong) NSMutableDictionary *completionBlocks;

- (BOOL)match:(NSString *)string with:(NSString *)substring;
- (BOOL)match:(NSString *)string withArray:(NSArray *)substrings;
- (void)urlResolved:(ORURL *)url;

- (BOOL)handleImageURL:(ORURL *)url;
- (BOOL)handleInstagramURL:(ORURL *)url;
- (BOOL)handleYoutubeURL:(ORURL *)url;
- (BOOL)handleTwitpicURL:(ORURL *)url;
- (BOOL)handleYfrogURL:(ORURL *)url;
- (BOOL)handleImgurURL:(ORURL *)url;

- (void)addCompletion:(ORURLResolverCompletion)completion forKey:(NSString *)key;
- (MKNetworkOperation *)handleURL:(ORURL *)url resolve:(BOOL)resolve;

@end

@implementation ORURLResolver

+ (ORURLResolver *)sharedInstance
{
    static dispatch_once_t pred;
    static ORURLResolver *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORURLResolver alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _resolvedURLs = [NSMutableDictionary dictionary];
		_resolvedIconURLs = [NSMutableDictionary dictionary];
        _completionBlocks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL)match:(NSString *)string with:(NSString *)substring
{
    return string && [string rangeOfString:substring options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (BOOL)match:(NSString *)string withArray:(NSArray *)substrings
{
    for (NSString *substring in substrings) {
        if ([self match:string with:substring]) return YES;
    }
    
    return NO;
}

- (void)urlResolved:(ORURL *)url
{
    url.isResolving = NO;
    
    if (url) {
        [url replaceKnownQueryParams];
        self.resolvedURLs[url.originalURL.absoluteString] = url;
        self.resolvedURLs[url.finalURL.absoluteString] = url;
        
        NSMutableArray *array = [self.completionBlocks valueForKey:url.originalURL.absoluteString];
        for (ORURLResolverCompletion completion in array) completion(nil, url);
        [self.completionBlocks removeObjectForKey:url.originalURL.absoluteString];
    }
}

#pragma mark - Custom URL Handling Methods

- (BOOL)handleImageURL:(ORURL *)url
{
    if (url.finalURL.pathExtension) {
        if ([self match:url.finalURL.pathExtension withArray:@[@"jpg", @"png", @"gif", @"jpeg"]]) {
            url.type = ORURLTypeImage;
            url.imageURL = url.finalURL;
            if (!url.pageTitle) url.pageTitle = @"(Image)";
            url.isResolved = YES;
            [self urlResolved:url];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)handleInstagramURL:(ORURL *)url
{
    if ([self match:url.finalURL.host withArray:@[@"instagram.com", @"instagr.am"]]) {
        if ([url.finalURL.path hasPrefix:@"/p/"]) {
            NSString *newURL = nil;
            
            if ([url.finalURL.path hasSuffix:@"/media"] || [url.finalURL.path hasSuffix:@"/media/"]) {
                newURL = [NSString stringWithFormat:@"http://instagram.com%@", url.finalURL.path];
                newURL = [newURL stringByReplacingOccurrencesOfString:@"/media/" withString:@"/media"];
            } else {
                newURL = [NSString stringWithFormat:@"http://instagram.com%@/media", url.finalURL.path];
                newURL = [newURL stringByReplacingOccurrencesOfString:@"//media" withString:@"/media"];
            }

            url.finalURL = [NSURL URLWithString:[newURL stringByReplacingOccurrencesOfString:@"/media" withString:@""]];
            url.type = ORURLTypeInstagram;
            url.imageURL = [NSURL URLWithString:newURL];
            if (!url.pageTitle) url.pageTitle = @"Instagram Photo";
            url.isResolved = YES;
            [self urlResolved:url];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)handleYoutubeURL:(ORURL *)url
{
    NSString *videoID = nil;
    
    if ([self match:url.finalURL.host with:@"youtu.be"]) {
        videoID = [url.finalURL.path lastPathComponent];
    } else if ([self match:url.finalURL.host with:@"youtube.com"]) {
        if ([url.finalURL.path hasPrefix:@"/watch"]) {
            // Extract the video ID from the URL
            NSString *pattern = @"(?<=v=)[a-zA-Z0-9-_]+(?=[&#])|(?<=[0-9]/)[^&\n]+|(?<=v=)[^&\n]+";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:url.finalURL.absoluteString options:0 range:NSMakeRange(0, [url.finalURL.absoluteString length])];
            
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                videoID = [url.finalURL.absoluteString substringWithRange:rangeOfFirstMatch];
            }
        }
    }

    if (videoID) {
        NSString *newURL = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", videoID];
        url.type = ORURLTypeYoutube;
        url.imageURL = [NSURL URLWithString:newURL];
        url.finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/embed/%@", videoID]];
        if (!url.pageTitle) url.pageTitle = @"(Video)";
        url.customData = videoID;
        url.isResolved = YES;
        [self urlResolved:url];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleTwitpicURL:(ORURL *)url
{
    if ([self match:url.finalURL.host with:@"twitpic.com"]) {
        if (![url.finalURL.path hasPrefix:@"/photos"]) {
            NSString *imageID = [url.finalURL.path lastPathComponent];
            NSString *newURL = [NSString stringWithFormat:@"http://twitpic.com/show/large/%@", imageID];
            
            url.type = ORURLTypeTwitpic;
            url.imageURL = [NSURL URLWithString:newURL];
            url.customData = imageID;
            if (!url.pageTitle) url.pageTitle = @"(Image)";
            url.isResolved = YES;
            [self urlResolved:url];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)handleYfrogURL:(ORURL *)url
{
    if ([self match:url.finalURL.host withArray:@[@"yfrog.com", @"yfrog.us"]]) {
        NSString *imageID = [url.finalURL.path lastPathComponent];
        NSString *type = [imageID substringFromIndex:imageID.length-1];
        NSString *newURL = nil;
        
        if ([self match:type withArray:@[@"j", @"p", @"b", @"t", @"g"]]) { // Image
            newURL = [NSString stringWithFormat:@"http://yfrog.com/%@:medium", imageID];
        } else if ([self match:type withArray:@[@"f", @"z"]]) { // Video
            newURL = [NSString stringWithFormat:@"http://yfrog.com/%@:frame", imageID];
        } else { // Not image/video
            return NO;
        }
        
        url.type = ORURLTypeYfrog;
        url.imageURL = [NSURL URLWithString:newURL];
        if (!url.pageTitle) url.pageTitle = @"(Image)";
        url.customData = imageID;
        url.isResolved = YES;
        [self urlResolved:url];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleImgurURL:(ORURL *)url
{
    if ([self match:url.finalURL.host withArray:@[@"imgur.com"]]) {
        if (![url.finalURL.path hasPrefix:@"/a/"]) {
            NSString *newURL = [NSString stringWithFormat:@"http://i.imgur.com%@.jpg", url.finalURL.path];
            url.type = ORURLTypeImgur;
            url.imageURL = [NSURL URLWithString:newURL];
            if (!url.pageTitle) url.pageTitle = @"Imgur Image";
            url.isResolved = YES;
            [self urlResolved:url];
            return YES;
        }
    }
    
    return NO;
}

- (MKNetworkOperation *)handleURL:(ORURL *)url resolve:(BOOL)resolve
{
    // Try all the custom handling methods
    if ([self handleImageURL:url]) return nil;
    if ([self handleInstagramURL:url]) return nil;
    if ([self handleYoutubeURL:url]) return nil;
    if ([self handleTwitpicURL:url]) return nil;
    if ([self handleYfrogURL:url]) return nil;
    if ([self handleImgurURL:url]) return nil;
    
    // No custom method handled the URL
    if (resolve) {
        NSString *originalURL = url.originalURL.absoluteString;
        
        MKNetworkOperation *op = [[ORApiEngine sharedInstance] resolveURL:originalURL cb:^(NSError *error, ORURL *finalURL) {
            ORURL *theURL = [self.resolvedURLs valueForKey:originalURL];

            if (error) {
                theURL.isResolving = NO;
                NSMutableArray *array = [self.completionBlocks valueForKey:originalURL];
                for (ORURLResolverCompletion completion in array) completion(error, nil);
                [self.completionBlocks removeObjectForKey:originalURL];
                [self.resolvedURLs removeObjectForKey:originalURL];
                return;
            }

            [theURL copyDataFrom:finalURL];
            
            theURL.isResolved = YES;
            [self handleURL:theURL resolve:NO];
        }];

        return op;
    } else {
        [self urlResolved:url];
        return nil;
    }
}

#pragma mark - Custom Methods

- (void)addCompletion:(ORURLResolverCompletion)completion forKey:(NSString *)key
{
    if (!completion) return;
    NSMutableArray *array = [self.completionBlocks valueForKey:key];
    
    if (array) {
        [array addObject:[completion copy]];
    } else {
        array = [NSMutableArray arrayWithObject:[completion copy]];
        [self.completionBlocks setValue:array forKey:key];
    }
}

- (MKNetworkOperation *)resolveORURL:(ORURL *)url localOnly:(BOOL)localOnly completion:(ORURLResolverCompletion)completion
{
    // Return immediately if the URL is already resolved
    if (url.isResolved) {
        if (completion) completion(nil, url);
        return nil;
    }
    
    NSString *originalURL = url.originalURL.absoluteString;
    ORURL *finalURL = [self.resolvedURLs valueForKey:originalURL];
    
    // Try also agaist the final URL
    if (!finalURL && ![originalURL isEqualToString:url.finalURL.absoluteString]) {
        finalURL = [self.resolvedURLs valueForKey:url.finalURL.absoluteString];
    }
    
    // Store the completion block
    [self addCompletion:completion forKey:originalURL];
    
    if (finalURL) {
        if (finalURL.isResolving) {
            // Timeout
            if ([[NSDate date] timeIntervalSinceDate:finalURL.resolveStarted] > 30.0f) {
                NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Resolve operation timeout.", NSLocalizedDescriptionKey, nil];
                NSError *error = [NSError errorWithDomain:@"com.orooso.URLResolver.ErrorDomain" code:999 userInfo:ui];

                finalURL.isResolving = NO;
                NSMutableArray *array = [self.completionBlocks valueForKey:originalURL];
                for (ORURLResolverCompletion completion in array) completion(error, nil);
                [self.completionBlocks removeObjectForKey:originalURL];
                [self.resolvedURLs removeObjectForKey:originalURL];
            }
            
            return nil;
        }

        if (finalURL.isResolved) {
            [self urlResolved:finalURL];
            return nil;
        }
    }
    
    // Create a new entry in the Resolved URLs dictionary
    [self.resolvedURLs setValue:url forKey:originalURL];
    
    if (![originalURL isEqualToString:url.finalURL.absoluteString]) {
        [self.resolvedURLs setValue:url forKey:url.finalURL.absoluteString];
    }
    
    // Mark URL as Resolving
    url.isResolving = YES;
    url.resolveStarted = [NSDate date];
    
    // Handle the URL
    return [self handleURL:url resolve:!localOnly];
}

- (MKNetworkOperation *)resolveORURL:(ORURL *)url completion:(ORURLResolverCompletion)completion
{
    return [self resolveORURL:url localOnly:NO completion:completion];
}

- (MKNetworkOperation *)resolveNSURL:(NSURL *)url completion:(ORURLResolverCompletion)completion
{
    if (![url.absoluteString hasPrefix:@"http"]) {
		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url.absoluteString]];
    }
    
    ORURL *newURL = [ORURL URLWithURL:url];
    return [self resolveORURL:newURL completion:completion];
}

- (MKNetworkOperation *)resolveURLString:(NSString *)url completion:(ORURLResolverCompletion)completion
{
    return [self resolveNSURL:[NSURL URLWithString:url] completion:completion];
}

- (MKNetworkOperation *)resolveBatch:(NSArray *)urls completion:(ORURLArrayCompletion)completion
{
    MKNetworkOperation *op = [[ORApiEngine sharedInstance] resolveURLs:urls cb:^(NSError *error, NSArray *result) {
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:result.count];
        
        for (ORURL *url in result) {
            ORURL *theURL = [self findOnCache:url];
            [self handleURL:theURL resolve:NO];
            [urls addObject:theURL];
        }
        
        if (completion) completion(error, urls);
    }];
    
    return op;
}

- (ORURL *)findOnCache:(ORURL *)url
{
    ORURL *fromCache = [self.resolvedURLs valueForKey:url.originalURL.absoluteString];
    if (!fromCache) {
        if (![url.finalURL.absoluteString isEqualToString:url.originalURL.absoluteString]) {
            fromCache = [self.resolvedURLs valueForKey:url.finalURL.absoluteString];
            
            if (!fromCache && url.finalURL) self.resolvedURLs[url.finalURL.absoluteString] = url;
        }
        
        if (url.originalURL) self.resolvedURLs[url.originalURL.absoluteString] = fromCache ?: url;
    }
    
    if (fromCache && url.isResolved && !fromCache.isResolved) [fromCache copyDataFrom:url];
    return fromCache ?: url;
}

@end

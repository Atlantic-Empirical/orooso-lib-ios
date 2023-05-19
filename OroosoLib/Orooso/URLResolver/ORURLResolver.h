//
//  ORURLResolver.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 15/11/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@class ORURL;

typedef void (^ORURLResolverCompletion)(NSError *error, ORURL *finalURL);
typedef void (^ORURLArrayCompletion)(NSError *error, NSArray *finalURLs);

@interface ORURLResolver : NSObject

+ (ORURLResolver *)sharedInstance;

- (MKNetworkOperation *)resolveORURL:(ORURL *)url localOnly:(BOOL)localOnly completion:(ORURLResolverCompletion)completion;
- (MKNetworkOperation *)resolveORURL:(ORURL *)url completion:(ORURLResolverCompletion)completion;
- (MKNetworkOperation *)resolveNSURL:(NSURL *)url completion:(ORURLResolverCompletion)completion;
- (MKNetworkOperation *)resolveURLString:(NSString *)url completion:(ORURLResolverCompletion)completion;
- (MKNetworkOperation *)resolveBatch:(NSArray *)urls completion:(ORURLArrayCompletion)completion;
- (ORURL *)findOnCache:(ORURL *)url;

@end

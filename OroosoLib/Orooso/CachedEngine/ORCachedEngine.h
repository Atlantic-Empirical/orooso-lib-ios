//
//  ORCachedEngine.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/12/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^ORImageBlock) (NSError *error, MKNetworkOperation* op, UIImage* image, BOOL cached);

@interface ORCachedEngine : MKNetworkEngine

@property (readonly) NSUInteger cacheSize;

+ (ORCachedEngine *)sharedInstance;

- (MKNetworkOperation *)imageAtURL:(NSURL *)url
                              size:(CGSize)size
                              fill:(BOOL)fill
                            google:(BOOL)google
                        completion:(ORImageBlock)completion;

- (MKNetworkOperation *)imageAtURL:(NSURL *)url
                              size:(CGSize)size
                              fill:(BOOL)fill
                        completion:(ORImageBlock)completion;

- (MKNetworkOperation *)imageAtURL:(NSURL *)url
                              size:(CGSize)size
                        completion:(ORImageBlock)completion;

- (MKNetworkOperation *)imageAtURL:(NSURL *)url
                        completion:(ORImageBlock)completion;

- (void)emptyCacheWithCompletion:(void(^)(BOOL success))completion;
- (void)cacheCleanup;

@end

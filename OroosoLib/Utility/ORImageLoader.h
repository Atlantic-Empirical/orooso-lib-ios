//
//  ORImageLoader.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/6/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ORImageDownloadCompletion)(NSError *error, UIImage *image);

@interface ORImageLoader : NSObject

+ (void)loadImageFromURL:(NSString *)urlString toImageView:(UIImageView *)imageView cb:(ORImageDownloadCompletion)completion;
+ (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView;
+ (void)loadImageFromURL:(NSString *)url toButton:(UIButton *)targetButton cb:(ORImageDownloadCompletion)completion;
+ (void)loadImageFromURL:(NSString *)url toButton:(UIButton *)targetButton;
+ (void)loadImageFromURL:(NSString *)urlString cb:(ORImageDownloadCompletion)completion;

@end

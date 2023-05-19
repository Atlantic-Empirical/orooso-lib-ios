//
//  ORImageLoader.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/6/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORImageLoader.h"
#import "ORCachedEngine.h"

@implementation ORImageLoader

+ (void)loadImageFromURL:(NSString *)urlString toImageView:(UIImageView *)imageView cb:(ORImageDownloadCompletion)completion
{
	if (!urlString || !imageView) return;
    
    [[ORCachedEngine sharedInstance] imageAtURL:[NSURL URLWithString:urlString] completion:^(NSError *error, MKNetworkOperation *op, UIImage *image, BOOL cached) {
        if (error) {
            completion(error, nil);
            return;
        }

        imageView.image = image;
        completion(nil, image);
    }];
}

+ (void)loadImageFromURL:(NSString *)urlString cb:(ORImageDownloadCompletion)completion
{
	if (!urlString) return;
    
    [[ORCachedEngine sharedInstance] imageAtURL:[NSURL URLWithString:urlString] completion:^(NSError *error, MKNetworkOperation *op, UIImage *image, BOOL cached) {
        if (error) {
            completion(error, nil);
            return;
        }
        completion(nil, image);
    }];
}

/*
+ (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView withCrossFade:(BOOL)fade skipDisplay:(BOOL)skipDisplay cb:(ORImageDownloadCompletion)completion
{
    if (!imageView) return;
    if (!url) { imageView.image = nil; return; }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSURL *nsurl = [NSURL URLWithString:url];
        NSData *data = [NSData dataWithContentsOfURL:nsurl];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (image) {
				if (!skipDisplay) {
					if (fade) {
						UIImageView *loadedImageView = [[UIImageView alloc] initWithImage:image];
						loadedImageView.frame = imageView.frame;
						loadedImageView.alpha = 0;
						loadedImageView.contentMode = UIViewContentModeScaleAspectFit;
						[imageView.superview addSubview:loadedImageView];
						
						[UIView animateWithDuration:0.4 animations:^ {
							loadedImageView.alpha = 1;
							imageView.alpha = 0;
						}
										 completion:^(BOOL finished)
						 {
							 imageView.image = image;
							 imageView.alpha = 1;
							 [loadedImageView removeFromSuperview];
						 }];
					} else {
						imageView.image = image;
					}
				}
				completion(nil, image);
            } else {
                imageView.image = nil;
                NSLog(@"Failed to load image from url: %@", url);
				NSError *err = [[NSError alloc] initWithDomain:@"com.oroooso.ios.SFSummaryCard" code:0 userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"failed to load image", @"message", url, @"url", nil]];
				completion(err, nil);
            }
        });
    });
}
*/

+ (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView
{
	[ORImageLoader loadImageFromURL:url toImageView:imageView cb:^(NSError *error, UIImage *image) {
		//disregard
	}];
}


+ (void)loadImageFromURL:(NSString *)url toButton:(UIButton *)targetButton cb:(ORImageDownloadCompletion)completion
{
    if (url == nil) {
		[targetButton setBackgroundImage:nil forState:UIControlStateNormal];
		[targetButton setBackgroundImage:nil forState:UIControlStateHighlighted];
		[targetButton setBackgroundImage:nil forState:UIControlStateSelected];
		completion(nil, nil);
        return;
    }
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		NSLog(@"Loading image from URL: %@", url);
		
		NSURL *nsurl = [NSURL URLWithString:url];
		NSData *data = [NSData dataWithContentsOfURL:nsurl];
		UIImage *image = [UIImage imageWithData:data];
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			if (image) {
				//                imageView.image = image;
				[targetButton setBackgroundImage:image forState:UIControlStateNormal];
//				[targetButton setBackgroundImage:image forState:UIControlStateHighlighted];
//				[targetButton setBackgroundImage:image forState:UIControlStateSelected];
				completion(nil, image);
			} else {
				//                imageView.image = nil;
				[targetButton setBackgroundImage:nil forState:UIControlStateNormal];
//				[targetButton setBackgroundImage:nil forState:UIControlStateHighlighted];
//				[targetButton setBackgroundImage:nil forState:UIControlStateSelected];
				NSLog(@"Failed to load image.");
				completion(nil, nil);
			}
        });
    });
}

+ (void)loadImageFromURL:(NSString *)url toButton:(UIButton *)targetButton
{
	[ORImageLoader loadImageFromURL:url toButton:targetButton cb:^(NSError *error, UIImage *image) {
		targetButton.hidden = NO;
	}];
}









//OLD MIGHT BE NEEDED
//+ (void) loadImageFromUrl:(NSString*)imgUrl targetView:(UIImageView*)targetImageView {
//    self.imageLoadingOperation = [ORAppDelegate.cachedEngine imageAtURL:[NSURL URLWithString:imgUrl] completionHandler:^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) {
//        if([imgUrl isEqualToString:[url absoluteString]]) {
//            if (isInCache == YES) {
//                targetImageView.image = fetchedImage;
//            } else {
//                UIImageView *loadedImageView = [[UIImageView alloc] initWithImage:fetchedImage];
//                loadedImageView.frame = targetImageView.frame;
//                loadedImageView.alpha = 0;
//                loadedImageView.contentMode = UIViewContentModeScaleAspectFit;
//                [self.view addSubview:loadedImageView];
//                
//                [UIView animateWithDuration:0.4 animations:^ {
//                    loadedImageView.alpha = 1;
//                    targetImageView.alpha = 0;
//                }
//                                 completion:^(BOOL finished)
//                 {
//                     targetImageView.image = fetchedImage;
//                     targetImageView.alpha = 1;
//                     [loadedImageView removeFromSuperview];
//                 }];
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        DLog(@"Error loading image: %@", error);
//    }];
//}

@end

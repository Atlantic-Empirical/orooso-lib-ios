//
//  ORCachedEngine.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/12/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORCachedEngine.h"
#import "MKNetworkOperation.h"
#import "ORGoogleEngine.h"

#define CACHE_MAX_SIZE 100000000 // 100 MB - Size that toggles cleanup
#define CACHE_OPT_SIZE 90000000  //  90 MB - Target size after cleanup

const char * kImageQueueName = "com.orooso.imagequeue";

@interface ORCachedEngine ()
{
    dispatch_queue_t _queue;
}

@property (nonatomic, assign) float scale;
@property (atomic, copy) NSString *cachePath;
@property (atomic, copy) NSString *cacheInfoFile;
@property (atomic, assign) NSUInteger cacheSize;

- (UIImage *)imageFromCache:(NSString *)cacheKey;

@end

@implementation ORCachedEngine

+ (ORCachedEngine *)sharedInstance
{
    static dispatch_once_t pred;
    static ORCachedEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ORCachedEngine alloc] initWithHostName:nil];
    });
    
    return shared;
}

- (id)initWithHostName:(NSString *)hostName
{
    self = [super initWithHostName:hostName];
    
    if (self) {
        self.scale = [[UIScreen mainScreen] scale];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = paths[0];
        
        self.cachePath = [cachesDirectory stringByAppendingPathComponent:@"ORCache"];
        self.cacheInfoFile = [self.cachePath stringByAppendingPathExtension:@"plist"];
        
        _queue = dispatch_queue_create(kImageQueueName, NULL);
        
        dispatch_async(_queue, ^{
            BOOL isDirectory = YES;
            BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:self.cachePath isDirectory:&isDirectory] && isDirectory;
            
            if (!folderExists) {
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) NSLog(@"Error creating cache path: %@", error);
            }
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.cacheInfoFile isDirectory:&isDirectory];
            
            if (fileExists) {
                NSDictionary *cacheInfo = [NSDictionary dictionaryWithContentsOfFile:self.cacheInfoFile];
                self.cacheSize = [[cacheInfo valueForKey:@"cacheSize"] unsignedIntegerValue];
            } else {
                self.cacheSize = 0;
                NSDictionary *cacheInfo = @{@"cacheSize": @(self.cacheSize)};
                [cacheInfo writeToFile:self.cacheInfoFile atomically:YES];
            }
        });
    }
    
    return self;
}

- (void)dealloc
{
    if (_queue) {
        dispatch_release(_queue);
        _queue = nil;
    }
}

- (UIImage *)imageFromCache:(NSString *)cacheKey
{
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:cacheKey];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *cachedData = [NSData dataWithContentsOfFile:filePath];
        return [UIImage imageWithData:cachedData];
    }
    
    return nil;
}

- (void)saveImageDataToCache:(NSData *)imageData key:(NSString *)cacheKey
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:cacheKey];

    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSUInteger fileSize = [[fm attributesOfItemAtPath:filePath error:nil][NSFileSize] unsignedIntegerValue];
        
        if ([fm removeItemAtPath:filePath error:&error]) {
            self.cacheSize -= fileSize;
        } else {
            if (error) NSLog(@"Error removing old cache file: %@", error);
        }
    }
    
    [imageData writeToFile:filePath atomically:YES];
    
    self.cacheSize += [imageData length];
    NSDictionary *cacheInfo = @{@"cacheSize": @(self.cacheSize)};
    [cacheInfo writeToFile:self.cacheInfoFile atomically:YES];
}

- (UIImage *)resampleImage:(UIImage *)image size:(CGSize)size fill:(BOOL)fill
{
    CGSize targetSize = CGSizeMake(size.width * self.scale, size.height * self.scale);
    CGFloat ratio;
    CGSize newSize;
    CGRect newRect;
    
    if (fill) {
        ratio = MAX(targetSize.width / image.size.width, targetSize.height / image.size.height);
        newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);

        if (image.size.height > image.size.width) {
            // Crop the image at the top, to avoid headless people
            newRect = CGRectIntegral(CGRectMake(targetSize.width/2 - newSize.width/2, targetSize.height - newSize.height, newSize.width, newSize.height));
        } else {
            // Crop the image at the middle
            newRect = CGRectIntegral(CGRectMake(targetSize.width/2 - newSize.width/2, targetSize.height/2 - newSize.height/2, newSize.width, newSize.height));
        }
    } else {
        ratio = MIN(targetSize.width / image.size.width, targetSize.height / image.size.height);
        newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
        newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
        targetSize = newSize;
    }
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGImageRef imageRef = image.CGImage;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, targetSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, newRect, imageRef);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return newImage;
}

- (MKNetworkOperation *)imageAtURL:(NSURL *)url size:(CGSize)size fill:(BOOL)fill google:(BOOL)google completion:(ORImageBlock)completion
{
    NSParameterAssert(url != nil);
    
    __block MKNetworkOperation *op = [self operationWithURLString:url.absoluteString params:nil httpMethod:@"GET"];
    
    dispatch_async(_queue, ^{
        NSString *cacheKey = [[NSString stringWithFormat:@"%@", url.absoluteString] mk_md5];
        __block UIImage *image = [self imageFromCache:cacheKey];
        
        if (image) {
            // Only resample if asked for a size that's lower than the image
            if (image && !CGSizeEqualToSize(size, CGSizeZero) && (size.width < image.size.width || size.height < image.size.height) ) {
                image = [self resampleImage:image size:size fill:fill];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, op, image, YES);
            });
            
            return;
        }
        
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            dispatch_async(_queue, ^{
                NSData *data = [completedOperation responseData];
                __block UIImage *newImage = [UIImage imageWithData:data];
                
                // Only resample if asked for a size that's lower than the image
                if (newImage && !CGSizeEqualToSize(size, CGSizeZero) && (size.width < newImage.size.width || size.height < newImage.size.height) ) {
                    newImage = [self resampleImage:newImage size:size fill:fill];
                }

                if (!newImage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [self errorWithCode:404 message:@"Failed to load image"];
                        completion(error, completedOperation, nil, NO);
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, completedOperation, newImage, NO);
                });
                
                [self saveImageDataToCache:data key:cacheKey];
            });
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error, completedOperation, nil, NO);
            });
        }];
        
        if (google) {
            // Workaround: Google needs us to sign image requests with OAuth header
            [[ORGoogleEngine sharedInstance] signRequest:op];
        }
        
        [self enqueueOperation:op];
    });
    
    return op;
}

- (MKNetworkOperation *)imageAtURL:(NSURL *)url size:(CGSize)size fill:(BOOL)fill completion:(ORImageBlock)completion
{
    return [self imageAtURL:url size:size fill:fill google:NO completion:completion];
}

- (MKNetworkOperation *)imageAtURL:(NSURL *)url size:(CGSize)size completion:(ORImageBlock)completion
{
    return [self imageAtURL:url size:size fill:YES completion:completion];
}

- (MKNetworkOperation *)imageAtURL:(NSURL *)url completion:(ORImageBlock)completion
{
    return [self imageAtURL:url size:CGSizeZero completion:completion];
}

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    NSDictionary *ui = @{NSLocalizedDescriptionKey: message};
    NSError *error = [NSError errorWithDomain:@"com.orooso.ORCachedEngine" code:code userInfo:ui];
    return error;
}

- (void)emptyCacheWithCompletion:(void (^)(BOOL))completion
{
    dispatch_async(_queue, ^{
        NSLog(@"Emptying Image Cache...");
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDirectoryEnumerator* en = [fm enumeratorAtPath:self.cachePath];
        NSError* err = nil;
        BOOL res;
        NSString* file;
        
        while (file = [en nextObject]) {
            res = [fm removeItemAtPath:[self.cachePath stringByAppendingPathComponent:file] error:&err];
            if (!res && err) NSLog(@"Failed to Remove File: %@", err);
        }

        self.cacheSize = 0;
        NSDictionary *cacheInfo = @{@"cacheSize": @(self.cacheSize)};
        [cacheInfo writeToFile:self.cacheInfoFile atomically:YES];
        
        NSLog(@"Image Cache emptied successfully.");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(YES);
        });
    });
}

- (void)cacheCleanup
{
    dispatch_async(_queue, ^{
        NSLog(@"Starting cache maintenance routine...");
        
        if (self.cacheSize > CACHE_MAX_SIZE) {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSURL *cachePath = [NSURL fileURLWithPath:self.cachePath];
            NSArray *files = [fm contentsOfDirectoryAtURL:cachePath
                               includingPropertiesForKeys:@[NSURLContentModificationDateKey, NSURLFileSizeKey]
                                                  options:nil
                                                    error:nil];
            
            NSArray *sortedFiles = [files sortedArrayUsingComparator:^NSComparisonResult(NSURL *f1, NSURL *f2) {
                NSDate *d1 = nil, *d2 = nil;
                
                [f1 getResourceValue:&d1 forKey:NSURLContentModificationDateKey error:nil];
                [f2 getResourceValue:&d2 forKey:NSURLContentModificationDateKey error:nil];
                
                return [d1 compare:d2];
            }];

            NSUInteger spaceToSave = self.cacheSize - CACHE_OPT_SIZE;
            NSUInteger spaceSaved = 0;
            NSUInteger removedFiles = 0;

            for (NSURL *f in sortedFiles) {
                NSNumber *size = nil;
                [f getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                
                if ([fm removeItemAtURL:f error:nil]) {
                    spaceSaved += [size unsignedIntegerValue];
                    removedFiles++;
                }
                
                if (spaceSaved >= spaceToSave) break;
            }
            
            self.cacheSize -= spaceSaved;
            NSDictionary *cacheInfo = @{@"cacheSize": @(self.cacheSize)};
            [cacheInfo writeToFile:self.cacheInfoFile atomically:YES];
            
            NSLog(@"Cache maintenance routine completed. Files removed: %d (%d bytes)", removedFiles, spaceSaved);
        } else {
            NSLog(@"Cache maintenance routine completed. No files removed");
        }
    });
}

@end

//
//  ORImage.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 7/25/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

typedef enum {
    ORImageTypeOriginal,
    ORImageTypeCard,
    ORImageTypeThumb
} ORImageType;

@protocol ORImageDelegate;

@interface ORImage : NSObject <NSCoding>

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (ORImage*)initWithUrlString:(NSString*)url andType:(ORImageType)type;
- (ORImage*)initDummy;
- (ORImage*)initWithUIImage:(UIImage*)image andTitle:(NSString*)title;
+ (ORImage *)instanceWithOnlyMediaUrl:(NSString *)mediaUrl;

- (void)loadImage;
- (void)cancelLoad;

- (NSString *)mediaURLwithType:(ORImageType)type;

@property (weak, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) NSString *copyrightInfo;
@property (assign, nonatomic) ORImageType type;
@property (atomic, weak)      id<ORImageDelegate> delegate;

@property (nonatomic, copy) NSString *associatedItemId;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *displayUrl;
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, assign) NSUInteger fileSize;
@property (nonatomic, copy) NSString *idOrooso;
@property (nonatomic, copy) NSString *idProvider;
@property (nonatomic, copy) NSString *mediaUrl;
@property (nonatomic, copy) NSString *origQuery;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *qualityScore;
@property (nonatomic, copy) NSString *sourceUrl;
@property (nonatomic, copy) NSString *thumbContentType;
@property (nonatomic, assign) NSUInteger thumbWidth;
@property (nonatomic, assign) NSUInteger thumbHeight;
@property (nonatomic, assign) NSUInteger thumbFilesize;
@property (nonatomic, copy) NSString *thumbMediaUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL parsed;

@end

@protocol ORImageDelegate <NSObject>

- (void)image:(ORImage *)image imageLoaded:(UIImage *)uiImage local:(BOOL)local;
- (void)imageIsLoading:(ORImage *)image;
- (void)imageFailedToLoad:(ORImage *)image;

@end

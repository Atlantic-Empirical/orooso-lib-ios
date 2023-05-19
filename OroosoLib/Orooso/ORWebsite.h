//
//  ORWebsite.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/23/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORImage.h"

@interface ORWebsite : NSObject

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *urlExpanded;
@property (strong, nonatomic) NSString *pageTitle;
@property (strong, nonatomic) NSString *internalName;
@property (strong, nonatomic) NSString *urlFavicon;
@property (strong, nonatomic) UIImage *favicon;
@property (strong, nonatomic) UIWebView *activeWebview;
@property (strong, nonatomic) UIImage *representativeImage;

@end

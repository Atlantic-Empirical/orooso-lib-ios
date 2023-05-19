//
//  TweetGenerator.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/1/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OREntity.h"

@interface TweetGenerator : NSObject

//@property (strong, nonatomic) OroosoAppDelegate *appDelegate;

+ (NSString*) generateTweet:(OREntity *)title;


@end

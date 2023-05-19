//
//  ORUverseTitle.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 11/25/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UverseConnectedManager.h"
#import "SetTopBox.h"
#import "uveErrors.h"
#import "RemoteKey.h"
#import "uveRemoteButtonCommand.h"
#import "uveInfoCommand.h"

@interface ORUverseTitle : NSObject

- (ORUverseTitle*)initWithUverseProgram:(uverseProgram*)uvProg;

@property (strong, nonatomic) NSString *programTitle;
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *programDescription;
@property (strong, nonatomic) NSString *episodeName;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSString *programType;
@property (strong, nonatomic) NSString *tuneString;
@property (strong, nonatomic) NSString *dvrStatus;
@property (strong, nonatomic) NSString *ratings;

@end

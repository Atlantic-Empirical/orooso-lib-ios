//
//  ORUVerse.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/27/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UverseConnectedManager.h"
#import "SetTopBox.h"
#import "uveErrors.h"
#import "RemoteKey.h"
#import "uveRemoteButtonCommand.h"
#import "uveInfoCommand.h"
#import	"ORUverseTitle.h"

// NSNotification names
extern NSString *const uvStatus;
extern NSString *const uvGotProgramInfo;

@interface ORUVerse : NSObject

@property (strong, nonatomic) UverseConnectedManager *uvSTBManager;

// DISCOVERY & PAIRING
- (void) discoverReceiversOnNetwork;
-(void)associateWithSTB:(SetTopBox*)stb;

@property (nonatomic, strong) NSMutableArray *receiverList;
@property (nonatomic, strong) SetTopBox *currentSTB;
@property (assign, nonatomic) BOOL unknownSTBs;


// INFO QUERY
- (void) queryCurrentProgramInfo;

// REMOTE CONTROL
- (void) pausePlay;
- (void) sendButtonCommand:(uveRemoteButtonCommand*)cmd;

@end

//
//  uveBaseCommand.h
//
//  Created by Chris Woodard on 5/2/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SetTopBox;
@class uveSetTopBoxCommandSender;
extern NSInteger correlatorValue;

typedef enum CommandResult {
  cmdFailed = 0,    /**< The Command failed. */
  cmdSucceeded = 1  /**< The Command was successful. */
} DaisCommandResult;

//! Base class for all Command objects, should not be instantiated directly
@interface uveBaseCommand : NSObject
{
    NSInteger correlator;
    DaisCommandResult cmdResult;
    NSMutableArray *commands;
    BOOL ignoreResult;
}

@property (nonatomic, assign) NSInteger correlator;
@property (nonatomic, assign) DaisCommandResult cmdResult;
@property (nonatomic, retain) NSArray *commands;
@property (nonatomic, assign) BOOL ignoreResult;

-(BOOL)processResponse:(NSData *)responseData;
-(uveSetTopBoxCommandSender *)sender;

@end

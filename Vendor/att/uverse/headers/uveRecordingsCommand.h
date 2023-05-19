//
//  uveRecordingsCommand.h
//
//  Created by Arnold Goldberg on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"
#import "uverseProgram.h"

//! Command object for requesting the list of recordings from the SetTopBox.
/*!
 The uveRecordingsCommand is used to request the list of recordings from the SetTopBox
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveRecordingsCommand : uveBaseCommand {
  NSMutableArray * recordings;
  int index;
  int totalResults;
  NSMutableString * currentString;
}
/**
 An NSMutableArray of uverseProgram objects representing scheduled or recorded programs.
 */
@property (nonatomic, retain) NSMutableArray * recordings;
/** The index into the list of DVR Recordings. Defaults to 0. */
@property (nonatomic, assign) int index;
/** The number of DVR recordings available */
@property (nonatomic, readonly ) int totalResults;

@end

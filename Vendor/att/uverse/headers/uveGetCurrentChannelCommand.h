//
//  uveGetCurrentChannelCommand.h
//  DAIS
//
//  Created by Arnold Goldberg on 9/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "uveBaseCommand.h"
#import "uverseProgram.h"
#import "uverseChannel.h"

//! Command object for for obtaining information regarding the channel currently tuned on the SetTopBox.
/*!
 The uveGetCurrentChannelCommand is used to obtain information regarding the channel currently tuned onSetTopBox
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveGetCurrentChannelCommand : uveBaseCommand <NSXMLParserDelegate>

/**
 A uverseChannel object representing the currently tuned channel. 
 */
@property (nonatomic, retain) uverseChannel * channel;
/**
 A uverseProgram object reprenseting the currently tuned program.
 */
@property (nonatomic, retain) uverseProgram * program;

@end
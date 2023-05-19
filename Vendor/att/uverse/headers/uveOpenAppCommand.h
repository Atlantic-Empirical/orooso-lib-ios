//
//  uveOpenAppCommand.h
//
//  Created by Chris Woodard on 5/2/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"

//! Command object for instructing the SetTopBox to open an MPF application URL
/*!
 The uveOpenAppCommand is used to open an MPF appliation on the SetTopBox. 
 
 Since MPF applications are nor commonly developed externally, most developer's will not 
 use this command object.
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveOpenAppCommand : uveBaseCommand {
}
/** 
 Initializes and returns a newly allocated uveOpenAppCommand object with the specified MPF Application URL. 
 @param url The MPF Application URL that this command will request the SetTopBox to open.  
 @returns An initialized uveOpenAppCommand object or nil if the object couldn't be created.
 */
-(id)initWithAppURL:(NSString *)url;

@end

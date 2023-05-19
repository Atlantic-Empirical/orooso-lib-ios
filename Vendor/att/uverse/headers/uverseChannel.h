//
//  uverseChannel.h
//  DAIS
//
//  Created by Arnold Goldberg on 9/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! \file uverseChannel.h
 */

//! This is a simple data class representing a channel.
@interface uverseChannel : NSObject
{
  int number;
  int ref;
  NSString * callLetters;
  NSString * name;
  NSString * tuneString;
}

/** Channel number of the program. */
@property(nonatomic, assign) int number;
/** Internal channel reference number used for tuning. */
@property(nonatomic, assign) int ref;
/** Channel Call Letters. */
@property(nonatomic, retain) NSString * callLetters;
/** The name of the channel. */
@property(nonatomic, retain) NSString * name;
@property(nonatomic, retain) NSString * tuneString;

@end

//
//  DaisListenCommand.h
//  DAIS
//
//  Created by Arnold Goldberg on 5/12/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"

@interface uveListenCommand : uveBaseCommand {
    
}
-(id)initWithIPAddress: (NSString*)ipAddress Event: (NSString*)event expiryDate: (NSDate*)exp;

@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSDate   * expiryDate;

@end

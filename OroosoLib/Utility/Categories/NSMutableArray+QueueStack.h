//
//  NSMutableArray+Queue.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/23/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueStack)

-(id)queuePop;
-(void)queuePush:(id)obj;

-(id)stackPop;
-(void)stackPush:(id)obj;

@end
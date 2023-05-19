//
//  ORATTSpeechEngine.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 10/5/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ATTSpeechKit.h"

@protocol ORATTSpeechEngineDelegate <NSObject>

//- (void) speechSucceeded:(NSString*)text;
//- (void) speechFailed:(NSString*)msg;

@end

@interface ORATTSpeechEngine : NSObject //<ATTSpeechServiceDelegate>

//@property (retain) id <ORATTSpeechEngineDelegate> delegate;
//- (ORATTSpeechEngine*)initShowMeterUI:(BOOL)show;
//- (void)listen;
//@property (assign, nonatomic) BOOL showUI;

@end

//
//  uveActionTune.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/** This action allows the tuning of a uveVideo object to a particular channel or a resource file. 
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionTune : uveAction { }

/** The channel to which the uveVideo object will be tuned. */
@property (nonatomic, assign) unsigned int channel;
/** The call letters to which the uveVideo object will be tuned, such as CNN. */
@property (nonatomic, retain) NSString *callLetters;
/** The URL to which the uveVideo object will be tuned. */
@property (nonatomic, retain) NSURL *tuneURL;
/** YES will cause the target to detune */
@property (nonatomic, assign) BOOL detune;



/**
Initializes the uveActionTune object with a particular channel specified as a number. This will throw an exception if nil is given as a parameter.
@param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
@param targetControlName The name of the control to be affected.
@param channel The channel number of the desired channel. 
@returns The initialized uveActionTune object.
*/
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
                  channel:(unsigned int)channel;


/**
 Initializes the uveActionTune object with a particular channel specified as call letters, such as CNN. This will throw an exception if nil is given as a parameter.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @param callLetters The call letters of the desired channel, such as CNN.
 @returns The initialized uveActionTune object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
              callLetters:(NSString*)callLetters;


/**
 Initializes the uveActionTune object with a specified URL. This will throw an exception if nil is given as a parameter.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @param tuneURL The URL of the resource to be played.
 @returns The initialized uveActionTune object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
                  tuneURL:(NSURL*)tuneURL;


/**
 Initializes the uveActionTune object so that when invoked it will "detune" the target uveVideo object. This will throw an exception if nil is given as a parameter.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be detuned.
 @returns The initialized uveActionTune object.
 */
- (id) initActionWithName:(NSString*)name
    nameOfTargetControlToDetune:(NSString*)targetControlName;



@end


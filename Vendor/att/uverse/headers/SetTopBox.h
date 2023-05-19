//
//  SetTopBox.h
//
//  Created by Arnold Goldberg on 3/16/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

//#define USE_FAKE_SetTopBoxes 1
#import <Foundation/Foundation.h>
#import "RemoteKey.h"
#import "uveTVApplicationDelegate.h"

//! A notification that a SetTopBox command was successful
extern NSString * const uveSetTopBoxCommandDidSucceed;
//! A notification that a SetTopBox command failed
extern NSString * const uveSetTopBoxCommandDidFail;
//! An NSDictionary Key used to obtain the Dais Command object from the userInfo dictionary of the previous two NSNotifications.
extern NSString * const uveSetTopBoxCommandKey;
//! A notification that the SetTopBox engagement was successful
extern NSString * const uveSetTopBoxEngagementDidSucceed;
//! A notification that the SetTopBox engagement attempt failed
extern NSString * const uveSetTopBoxEngagementDidFail;
//! An NSDictionary key used to obtain the NSError* object from the userInfo dictionary with any failure notifications
extern NSString * const uveSetTopBoxErrorKey;
//! A notification that the channel or program has changed on the SetTopBox
extern NSString * const uveSetTopBoxChannelOrProgramChanged;
//! A notification that a registered custom event has occurred.
extern NSString * const uveSetTopBoxCustomEventOccurred;
//! An NSDictionary key used to obtain the NSString* eventName object from the userInfo dictionary
extern NSString * const uveSetTopBoxCustomEventKey;

/*! \file SetTopBox.h
 */

/*! \enum UverseMode
 An enumeration of Uverse Connected Association Modes
 */
typedef enum
{
  UverseModeUnknown = 0,  /**< Uverse Connected has not been enabled on the SetTopBox yet */
  UverseModeClosed,       /**< Uverse Connected has been disabled on the SetTopBox. */
  UverseModeOpen,         /**< Uverse Connected is enabled in open mode allowing anyone to engage. */
  UverseModeManaged       /**< Uverse Connected is enabled in managed mode, requiring a user to supply a nonce to associate. */
}UverseMode;

/*! \enum UverseSetTopBoxPowerMode
 An enumeration of possible power states the SetTopBox may be in
 */
typedef enum
{
  UverseSetTopBoxPowerModeOff,        /**< The SetTopBox is off , or has not responded to discovery. */
  UverseSetTopBoxPowerModeStandBy,    /**< The SetTopBox is in Sleep/StandBy mode. */
  UverseSetTopBoxPowerModeOn,         /**< The SetTopBox is Powered On and awake. */
  UverseSetTopBoxPowerModeOnOrStandby /**< The SetTopBox is in either Sleep/StandBy or Awake, we cannot distinguish without associating with the SetTopBox. */
}UverseSetTopBoxPowerMode;

#import "uverseProgram.h"

@class uveBaseCommand;

@class Codec;
@class SessionInfo;

//! This class represents a physical SetTopBox.

/*! 
 After the discovery process has completed, the developer has access to the list of SetTopBoxes which are found on the local Uverse network
 they are currently connected to via Wi-fi. 
 
 The developer may engage with a particular SetTopBox by calling it's associateAndEngageWithOneTimeToken method. If the SetTopBox is in Managed mode, this function call will require a Nonce token obtained 
 via the U-verse Connect channel on the television at the channel specified in UverseConnectedManager's UverseConnectedChannel property.
 
 After the developer has succesfully engaged the application with a SetTopBox they may begin sending commands to it. 
 */

@interface SetTopBox : NSObject {
  uverseProgram * currentProgram;       

  BOOL isAssociated;                    
  BOOL isEngaged;
  
  NSString * ipAddress;
  NSString * deviceId;
  NSString * location;
  NSString * friendlyName;
  UverseMode mode;
  NSDate * lastModifiedDate;
  UverseSetTopBoxPowerMode powerMode;
  
  @private
  NSMutableString * currentString;
  Codec           * codec;
  uint              sequenceNumber;
  SessionInfo     * sessionInfo;
  int               port;
  NSOperationQueue * operationQueue;
  NSTimer          * listenTimer;
}

/** 
 Associates and engages the application with the SetTopBox. This call is only used for SetTopBoxes which are in the custom mode and are not already associated.  
 @param oneTimeToken A token used to associate with a SetTopBox in Custom Mode. This token is obtained by the user from the SetTopBox by tuning to the channel specified in the UverseConnectedManager's UverseConnectedChannel property.   
 */
-(void) associateAndEngageWithOneTimeToken:(NSString*)oneTimeToken;
/**
 Engages the application with the SetTopBox. This call must be completed before any calls to sendSetTopBoxCommand.  
*/
-(void) engage;

/** 
 Sends any of the concrete command objects to the SetTopBox.  
 @param cmd The concrete command object we are sending to the SetTopBox.  
 */
-(void)sendSetTopBoxCommand:(uveBaseCommand *)cmd;

/** 
 Starts the application server in the U-verse Enabled library.
 @param delegate The object that implements the uveTVApplicationDelegate protocol
 */
-(void) startTVApplicationWithDelegate:(id<uveTVApplicationDelegate>)delegate;
/** 
 Displays a U-verse Page on the receiver.  
 @param pageName The name of the page that will be requested by the server
 */
-(void) displayPageWithName:(NSString*)pageName;

/** The current program playing on the SetTopBox. */
@property (nonatomic, retain) uverseProgram * currentProgram;
/** A Boolean value that indicates whether the SetTopBox is currently associated. */
@property (nonatomic, assign) BOOL isAssociated;
/** A Boolean value that indicates whether the SetTopBox is currently engaged. */
@property (nonatomic, assign) BOOL isEngaged;
/** The current Uverse Connected Mode of the SetTopBox. */
@property (nonatomic, assign) UverseMode mode;
/** The current power status of the SetTopBox. */
@property (nonatomic, assign) UverseSetTopBoxPowerMode powerMode;
@property (nonatomic, retain) NSString * location;
/** The IP address of the SetTopBox. */
@property (nonatomic, retain) NSString * ipAddress;
/** The Device Id of the SetTopBox. */
@property (nonatomic, retain) NSString * deviceId;
/** The friendly name of the SetTopBox. */
@property (nonatomic, retain) NSString * friendlyName;
/** A Boolean value that indicates whether the SetTopBox is in sleep mode or awake. */
@property (nonatomic, assign) BOOL isAwake;
/** A Boolean value that indicates whether the SetTopBox is currently recording. */
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) int port;
/** The date/time the SetTopBox Uverse Connected mode was previously changed. */
@property (nonatomic, retain) NSDate * lastModifiedDate;
/** The delegate that will receive callbacks requesting new TV Application screens. */
@property (nonatomic, retain) id<uveTVApplicationDelegate> tvAppDelegate;

@end



//
//  UverseConnectedManager.h
//
//  Created by Arnold Goldberg on 4/5/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SetTopBox.h"

/*! \file UverseConnectedManager.h  */
//! A notification that the UverseConnectedManager discovery state has changed
extern NSString * const UverseConnectedManagerDidChangeState;
//! A notification that the UverseConnectedManager initialization has failed
extern NSString * const UverseConnectedManagerErrorOccurred;
//! The NSDictionary Key used to obtaining the discovery error
extern NSString * const UverseConnectedManagerErrorKey;

//! A notification that the UverseConnectedManager has been forced to shutdown by the network administrator
extern NSString * const UverseConnectedManagerForcedShutdown;
//! A notification that the attempt to retrieve the last enabled SetTopBox was succesful
extern NSString * const UverseConnectedManagerDidObtainLastEnabledSetTopBox;
//! A notification that the attempt to retrieve the last enabled SetTopBox has failed
extern NSString * const UverseConnectedManagerDidFailToObtainLastEnabledSetTopBox;
//! The NSDictionary Key used to obtain the last enabled SetTopBox
extern NSString * const UverseConnectedManagerLastEnabledSetTopBoxKey;
//! The unique application/developer key obtained when requesting an AAP file
extern NSString * const UverseEnabledDeveloperKey;

/*! \enum DiscoveryState
 An enumeration of Uverse Connected Discovery States
 */
typedef enum
{
  LibraryNotReady          =0,    /**< The Library is not ready for use. */
  DiscoveringNetwork,             /**< The Library is discovering the network. */
  LibraryReady,                   /**< The Library is ready for use. */
  LibraryBlocked,                 /**< The library has been blocked for use by this application. */
  WaitingForWiFiConnection,       /**< The Library is waiting for a Wi-Fi connection. */
} DiscoveryState;

/*! \enum AppServerState
 An enumeration of Uverse Enabled Application Server States
 */
typedef enum
{
  AppServerNotStarted  =0,  /**< The Application Server has not started. */
  AppServerStarting,        /**< The Application Server is in the process of starting. */
  AppServerStarted,         /**< The Application Server has started. */
  AppServerStopping,        /**< The Application Server has started. */
} AppServerState;


@class attHTTPServer;

//! The UverseConnectedManager class provides a centralized point of control for the Uverse Connected ADK
/*! 
 This class is implemented as a Singleton, so every application will have exactly one 
 instance of UverseConnectedManager.
 */
@interface UverseConnectedManager : NSObject {
  NSArray * SetTopBoxes; 
  SetTopBox * mostRecentlyEngagedSetTopBox;
  DiscoveryState state;
  AppServerState appServerState;
  int UverseConnectedChannel;
  NSMutableDictionary * userInfo;
  NSError * lastError;
  NSString * overrideURL;
  
  @private
  NSThread * discoveryThread;
  BOOL userInitiatedDiscovery;
  BOOL allowBackgroundOperation;
}

/** Returns the singleton UverseConnectedManager instance 
 
 @return The UverseConnectedManager instance created on the first call to sharedManager. */
+ (UverseConnectedManager*)sharedManager;

/** This function kicks off the Uverse Connected discovery process.  Subscribe to the UverseConnectedManagerDidChangeState notification to receive state change information. When the library is in the DiscoveryComplete state, the SetTopBoxes list is available for use. */
- (void) startDiscovery;

/** This function shuts down the library and returns it to a LibraryNotReady state. */
- (void) shutDown;

/** This function causes the UverseConnectedManager to refresh the information in the SetTopBox List */
- (void) getLastEnabledSetTopBox;

/** This function will upload the Uverse Connected logs to our server for internal review. */
- (void) uploadLogFile;


/** A list of SetTopBoxes that have been discovered on the subscriber network. */
@property (nonatomic, retain) NSArray * SetTopBoxes;

/** The most recently engaged SetTopBox, or nil if there is not one. */
@property (nonatomic, retain) SetTopBox * mostRecentlyEngagedSetTopBox;

/** The current state of the UverseConnectedManager initialization process. */
@property (nonatomic, assign) DiscoveryState state;

/** The channel number the user may tune to for enabling/managing Uverse Connected. */
@property (nonatomic, assign) int UverseConnectedChannel;

@property (nonatomic, retain) NSMutableDictionary *userInfo;

/** The last error encountered by the UverseConnectedManager during discovery. */
@property (nonatomic, retain) NSError * lastError;

@property (nonatomic, retain) NSString * overrideURL;

/** The current state of the U-verse Enabled Application Server. */
@property (nonatomic, assign) AppServerState appServerState;

/** The name of the AAP file, if a name is not provided "resource" will be used. */
@property (nonatomic, retain) NSString  * fileNameAAP;

/** This property determines if the library should continue running while the app is in the background. This is used for applications that are able to execute from the background per Apples requirements. */
@property (nonatomic, assign) BOOL allowBackgroundOperation;

@end



/**
 * @mainpage Uverse Enabled Library
 * @date 7/24/2012
 *
 * @section section_overview Usage
 *
 * For Library initialization to occur the device must be on a Uverse network. If the device is not
 * on a Uverse network, then an initialization failure will occur. Some applications may be configured
 * to require that the device be on the subscriber's own home network. These applications will also
 * require a supported authentication token.
 *
 * The first thing a developer using the Uverse Enabled library must do is obtain a reference to the shared
 * UverseConnectedManager instance. The first attempt to obtain this instance will actually instantiate the object.
 *
 * The developer should also register notification handlers for the following NSNotifications:
 *
 * <ul>
 * <li>#UverseConnectedManagerDidChangeState</li>
 * <li>#UverseConnectedManagerErrorOccurred</li>
 * </ul>
 *
 * After obtaining the reference to the UverseConnectedManager, the developer may call startDiscovery. Any authentication 
 * token's that must be supplied should be provided before making this call. 
 *
 * As the initialization processes, the application will receive the #UverseConnectedManagerDidChangeState notification,
 * if the new state is DiscoveryComplete , the developer may proceed to use the Uverse Enabled library.
 *
 * Upon successful completion of Discovery, the SetTopBoxes property of the #UverseConnectedManager shared instance will contain
 * a list of SetTopBoxes the user may associate with. The developer can choose to display a list of SetTopBoxes
 * for the user to engage with, or  may choose instead to auto-engage with the last used SetTopBox.
 *
 * If the SetTopBox is in Managed Mode, and the application/device has not previously Associated with this SetTopBox (the isAssociated property is NO), then 
 * the developer must call associateAndEngageWithOneTimeToken with a one time token; to both associate and engage with the SetTopBox.
 * 
 * If the SetTopBox is in Open Mode, or the application/device has previously Associated with this SetTopBox (the isAssociated property is YES), then 
 * the developer may simply call engage on the SetTopBox object.
 * 
 * If engagement is successful, the application will receive the #uveSetTopBoxEngagementDidSucceed notification.
 * After receiving this notification, the developer may proceed to allow for sending commands to the SetTopBox.
 */


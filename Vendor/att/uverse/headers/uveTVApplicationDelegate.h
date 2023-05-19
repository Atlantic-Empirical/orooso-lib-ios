//
//  uveTVApplicationDelegate.h
//  DAIS
//
//  Created by Arnold Goldberg on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
@class uveGadget;

//! Protocol for obtaining TV Application page requests as well as App Server state changes.
/*!
 The uveTVApplicationDelegate is used to register for callbacks when a TV Application requests a new page from the iOS device. It is also used for receiving a callback whent he applicationServer has succesfully started or failed to start.
 */
@protocol uveTVApplicationDelegate <NSObject>

/** This protocol method is called by the Application Server when a new page is requested.
 @param pageName The name of the requested page or subpage.  
 @param params A Dictionary containing key/value pairs of params for the requested page. This may be nil.
 @param tvFrame The frame for the television screen. This value is CGRectZero if the information was unavailable.
 */
- (uveGadget*)pageForName:(NSString*)pageName withParams:(NSMutableDictionary*)params forFrame:(CGRect)tvFrame;

/** This protocol method is called by the Application Server when a resource is requested. We attempt this call if the pageForName call returned nil.
 @param resourceName The name of the requested resource.  
 @param params A Dictionary containing key/value pairs of params for the requested resource. This may be nil.
 */
- (NSData*)resourceForName:(NSString*)resourceName withParams:(NSMutableDictionary*)params;

@optional

/** This protocol method is called by the library when the Application Server has succesfully started.
 */
- (void)applicationServerDidStart;

/** This protocol method is called by the library when the Application Server has failed to start.
 @param error An NSError object indicating why the Application Server failed to start.
 */
- (void)applicationServerDidFailToStartWithError:(NSError*)error;
@end

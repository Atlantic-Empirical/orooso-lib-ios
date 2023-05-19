//
//  uveSubPage.h
//  DAIS
//
//  Created by Erik Smith on 6/28/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"
#import "uveLocalDataSource.h"

/** This allows the loading of a panel from a uveLocalDataSource. Do not use datasource or datapath, only use localDataSource. Do not place a uveSubpage within a panel. The uveSubpage name must be unique. 
Do not place uveSubPage inside the uveSubpageContent panel.
 Use unique attribute names in the uveSubpageContent. These names must be unique throughout the uvePage and uveSubpage that the uveSubpageContent is located on.
 Bindings on a uvePage that reference attribute names in the uveSubpageContent are ignored.
 Actions located on the uvePage can specify a target that is inside the uveSubpageContent.
 */
@interface uveSubPage : uveGadget

/** The action(s) that will occur when the uveSubPage load results in an error. */
@property (nonatomic, retain) uveAction             *onError;

/** The action(s) that will occur when the uveSubPage is ready. */
@property (nonatomic, retain) uveAction             *onReady;

/** If true, automatically purge the uveSubPage in response to a system limit warning.  */
@property (nonatomic, assign) BOOL autoPurge;

/** The uveLocalDataSource for the panel. Also add this uveLocalDataSource object to the uvePage with addGadget. */
@property (nonatomic, retain) uveLocalDataSource    *localDataSource;

/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;

/**
 Initializes the object.
 @param name An identifier for the uveSubPage object.
 @returns The initialized object.
 */
- (id) initSubPageWithName:(NSString*)name;



@end

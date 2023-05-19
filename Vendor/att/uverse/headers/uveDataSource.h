//
//  uveDataSource.h
//  DAIS
//
//  Created by Erik Smith on 4/4/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveGadget.h"
#import "uveAction.h"

/** This class allows an XML source to be queried using XPath. */
@interface uveDataSource : uveGadget


/** This bool will indicate whether or not the data will be loaded when the page is loaded. */
@property (nonatomic, assign) BOOL autoLoad;

/** The URL to which the datasource will bind. Use https. */
@property (nonatomic, retain) NSURL *URL;

/** The action(s) that will occur when the uveDataSource load results in an error. */
@property (nonatomic, retain) uveAction             *onError;

/** The action(s) that will occur when the uveDataSource is ready. */
@property (nonatomic, retain) uveAction             *onReady;

/** If true, automatically purge the datasource in response to a system limit warning.  */
@property (nonatomic, assign) BOOL autoPurge;

/** A set of control names to submit data. */
@property (nonatomic, retain) NSSet *requestData;

/** YES indicates a get and NO indicates a post for submitting requestedData. */
@property (nonatomic, assign) BOOL requestMethod;


/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;

/**
 Initializes the object.
 @param name An identifier for the uveDataSource object.
 @returns The initialized object.
 */
- (id) initDataSourceWithName:(NSString*)name;


/**
 Initializes the object.
 @param name An identifier for the uveDataSource object.
 @param URL The URL to which the datasource will bind.
 @returns The initialized object.
 */
- (id) initDataSourceWithName:(NSString*)name URL:(NSURL*)URL;


@end


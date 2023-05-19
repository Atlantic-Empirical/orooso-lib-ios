//
//  uveGadget.h
//  DAIS
//
//  Created by Arnold Goldberg on 7/21/11.
//  Modified by Erik Smith
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveNode.h"
#import "uveAnimationContainer.h"
#import "uveAction.h"
#import <UIKit/UIColor.h>
#import <CoreGraphics/CGGeometry.h>
#import "uveActionContainer.h"

@class uveDataSource;

/** This class should be considered an abstract class. If a user has three gadgets, A, B and C, where A and B have identical name property values and then gadget A is added to gadget C and then gadget B is added to gadget C, gadget B will replace gadget A because they have the same name property values. */
@interface uveGadget : uveNode { }
/** Frame is used to set the origin coordinates, the width and the height of the gadget. */
@property (nonatomic, assign) CGRect frame;
/** The alpha value of the gadget determines its transparency. The range is a float from 0 to 1, inclusive. Do not use for uveBusyIndicator, uveDataSource. */
@property (nonatomic, assign) float alpha;
/** Determines if the gadget is visible on the page. Do not use for uveBusyIndicator, uveDataSource, uvePage. */
@property (nonatomic, assign) BOOL visible;
/** The color of the background of the gadget. If both an image and a color are set for the background, the image will be used.Do not use for uveDataSource.  */
@property (nonatomic, retain) UIColor *backgroundColor;
/** The image that will be used as the background for this gadget. If both an image and a color are set for the background, the image will be used. Do not use for uveDataSource. */
@property (nonatomic, retain) NSURL *backgroundImage;

/** Allows for animations to occur as the gadget is first rendered on the page. The string should be the name of the desired animation. Do not set for uvePage. Do not use for 	uveBoundList, uveBusyindicator, uveDatasource. */
@property (nonatomic, retain) NSString *inAnimations;
/** Allows for animations to occur as a hidden gadget is made visible. The string should be the name of the desired animation. Do not set for uvePage. Do not use for uveBusyIndicator, uveDataSource, uveVideoListItem. */
@property (nonatomic, retain) NSString *showAnimations;
/** Allows for animations to occur as the gadget is hidden. The string should be the name of the desired animation. Do not set for uvePage. Do not use for uveBusyIndicator. Do not use for uveBoundList, uveBusyindicator, uveDataSource, uveVideoListItem */
@property (nonatomic, retain) NSString *hideAnimations;

/** Margin is used to create an area around the control for layout. Do not use for uveBusyIndicator, uveDataSource, uvePage. */
@property (nonatomic, assign) CGRect margin;
/** The uveDatasource object for the gadget. Do not use for uveBusyIndicator, uvePage, uvePanel, uveSubPage, uveDataSource. */
@property (nonatomic, retain) uveDataSource *datasource;
/** The Xpath into the datasource. Do not use for uveBusyIndicator, uvePage, uvePanel, uveSubPage, uveDataSource. */
@property (nonatomic, retain) NSString *datapath;


@end


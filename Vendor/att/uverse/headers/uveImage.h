//
//  uveImage.h
//  DAIS
//
//  Created by Arnold Goldberg on 7/21/11.
//  Modified by Erik Smith
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveGadget.h"
#import "uveAction.h"
#import <CoreGraphics/CGGeometry.h>



/** Displays an image on a uvePage. The image formats that are supported are PNG, JPEG, and GIF89A. The size and number of images on a pages should be kept minimal and for maximum performance the number should be kept to less than 15. */
@interface uveImage : uveGadget { }

/** The URL for the image file. */
@property (nonatomic, retain) NSURL *image;

/** A rectangle that can be used to crop an image. */
@property (nonatomic, assign) CGRect cropArea;

/** True will load from images from the cache. */
@property (nonatomic, assign) BOOL useCache;
/**  Helps maintain aspect ratio if different aspect images are sent to the same object. */
@property (nonatomic, assign) BOOL keepAspectRatio;


/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;

/**
 Initializes the object.
 @param name An identifier for the uveImage object.
 @returns The initialized object.
 */
- (id) initImageWithName:(NSString*)name;

/**
 Initializes the object.
 @param name An identifier for the uveImage object.
 @param imageURL The URL for image to be used.
 @returns The initialized object.
 */
- (id) initImageWithName:(NSString*)name imageURL:(NSURL *)imageURL;

/**
 Initializes the object.
 @param name An identifier for the uveImage object.
 @param imageURL The URL for image to be used.
 @param frame The location and dimensions of the image on the uvePage.
 @returns The initialized object.
 */
- (id) initImageWithName:(NSString*)name imageURL:(NSURL *)imageURL frame:(CGRect)frame;


@end

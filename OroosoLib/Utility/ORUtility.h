//
//  ORUtility.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/6/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORUtility : NSObject

// IMAGES
+ (UIImage *)scaleImage:(UIImage*)inputImage toSize:(CGSize)size;
+ (UIImage *)toGrayscale:(UIImage*)img;
//- (UIImage*)mergeQuizImages;
+ (UIImage*)compositeImage:(UIImage*)imageA ontoImage:(UIImage*)imageB strength:(float)strength position:(CGPoint)position;

// VIEWS
+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view size:(CGSize)size;
+ (void)cancelAnimationsForView:(UIView*)viewForAnimationCancel;

// NUMBERS
+ (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber;

// STRINGS
+ (NSString *)first:(int)length charactersOfString:(NSString*)inString;
+ (NSString *)first:(int)length sentencesOfString:(NSString *)inString;

// COLORS
+ (UIColor *)randomColor;

// VALIDATION / REGEX
+ (BOOL)validateEmailorPhone:(NSString *)candidate;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (BOOL)validateEmail_RFC2822:(NSString *)candidate;
+ (BOOL)validatePhoneNumber:(NSString*)candidate;
+ (BOOL)beginsWithNumber:(NSString*)candidate;

// GUID
+ (NSString*)newGuidString;

// Slug
+ (NSString *)slugForString:(NSString *)string;

@end

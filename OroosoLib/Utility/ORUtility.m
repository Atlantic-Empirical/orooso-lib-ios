//
//  ORUtility.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/6/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "Guid.h"

@implementation ORUtility

//================================================================================================================
//
//  IMAGES
//
//================================================================================================================
#pragma mark - IMAGES

+ (UIImage *)scaleImage:(UIImage*)inputImage toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [inputImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// USEFUL IMAGE MERGING CODE
//- (UIImage*)mergeQuizImages
//{
//	//	[1] [2]
//	//	[3] [4]
//
//	// build merged size
//
//	float sizeFactor = 0.5;
//
//	float compositeCardWidth = self.sfc.cardWidth * sizeFactor;
//	float compositeCardHeight = self.sfc.cardHeight * sizeFactor;
//
//	float contextWidth = compositeCardWidth;
//	float contextHeight = compositeCardHeight;
//	if (quizItems >1) contextWidth = contextWidth*2;
//	if (quizItems >2) contextHeight = contextHeight*2;
//	CGSize mergedSize = CGSizeMake(contextWidth, contextHeight);
//	DLog(@"%@", NSStringFromCGSize(mergedSize));
//
//	// capture image context ref
//	UIGraphicsBeginImageContextWithOptions(mergedSize, YES, 0.0);
//
//	//Draw images onto the context
//	UIImage *tmpImg;
//	if (quizItems > 0) {
//		tmpImg = self.btnQuizItem_1.imageView.image;
//		tmpImg = [self scaleImage:tmpImg toSize:CGSizeMake(compositeCardWidth, compositeCardHeight)];
//		[tmpImg drawInRect:CGRectMake(0, 0, compositeCardWidth, compositeCardHeight)];
//	}
//	if (quizItems > 1) {
//		tmpImg = self.btnQuizItem_2.imageView.image;
//		tmpImg = [self scaleImage:tmpImg toSize:CGSizeMake(compositeCardWidth, compositeCardHeight)];
//		[tmpImg drawInRect:CGRectMake(compositeCardWidth, 0, compositeCardWidth, compositeCardHeight)];
//	}
//	if (quizItems > 2) {
//		tmpImg = self.btnQuizItem_3.imageView.image;
//		tmpImg = [self scaleImage:tmpImg toSize:CGSizeMake(compositeCardWidth, compositeCardHeight)];
//		[tmpImg drawInRect:CGRectMake(0, compositeCardHeight, compositeCardWidth, compositeCardHeight)];
//	}
//	if (quizItems > 3) {
//		tmpImg = self.btnQuizItem_4.imageView.image;
//		tmpImg = [self scaleImage:tmpImg toSize:CGSizeMake(compositeCardWidth, compositeCardHeight)];
//		[tmpImg drawInRect:CGRectMake(compositeCardWidth, compositeCardHeight, compositeCardWidth, compositeCardHeight)];
//	}
//
//	// assign context to new UIImage
//	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//	DLog(@"%@", NSStringFromCGSize(newImage.size));
//
//	// end context
//	UIGraphicsEndImageContext();
//
//	return newImage;
//}

+ (UIImage*)compositeImage:(UIImage*)imageA ontoImage:(UIImage*)imageB strength:(float)strength position:(CGPoint)position {
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageB.size.width, imageB.size.height), YES, 0.0);
	[imageB drawAtPoint: CGPointMake(0,0)];
	[imageA drawAtPoint: position
			  blendMode: kCGBlendModeNormal // you can play with this
				  alpha: strength]; // 0 - 1
	UIImage *answer = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return answer;
}

+ (UIImage *)toGrayscale:(UIImage*)img
{
    if (!img) return nil;
    
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
	
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, img.size.width * img.scale, img.size.height * img.scale);
	
    int width = imageRect.size.width;
    int height = imageRect.size.height;
	
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
	
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
			
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
	
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:img.scale
                                           orientation:UIImageOrientationUp];
	
    // we're done with image now too
    CGImageRelease(image);
	
    return resultUIImage;
}

//================================================================================================================
//
//  NUMBERS
//
//================================================================================================================
#pragma mark - NUMBERS

+ (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
	float diff = bigNumber - smallNumber;
	return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

//================================================================================================================
//
//  STRINGS
//
//================================================================================================================
#pragma mark - STRINGS

+ (NSString *)first:(int)length charactersOfString:(NSString*)inString {
	NSUInteger lgt = inString.length;
	if (lgt > length)
		return [inString substringToIndex:length-1];
	else
		return inString;
}

+ (NSString *)first:(int)length sentencesOfString:(NSString *)inString
{
    NSMutableArray *sentences = [NSMutableArray array];
    
    [inString enumerateSubstringsInRange:NSMakeRange(0, [inString length]) options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [sentences addObject:substring];
    }];
    
    if (sentences.count <= length) return inString;
    NSMutableString *result = [NSMutableString string];
    int count = 0;
    
    for (NSString *sentence in sentences) {
        [result appendString:sentence];
        count++;
        if (count >= length) break;
    }
    
    return result;
}

//================================================================================================================
//
//  VIEWS
//
//================================================================================================================
#pragma mark - VIEWS

+ (UIImage *)imageFromView:(UIView *)view
{
	UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
	[[view layer] renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return screenshot;
}

+ (UIImage *)imageFromView:(UIView *)view size:(CGSize)size
{
	UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
	[[view layer] renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return screenshot;
}

+ (void)cancelAnimationsForView:(UIView*)viewForAnimationCancel {
    // Cancel any animation of the position of the strings.
    //http://stackoverflow.com/questions/554997/cancel-a-uiview-animation
	
    // WORKS!
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{viewForAnimationCancel.frame = ((CALayer *)viewForAnimationCancel.layer.presentationLayer).frame;}
                     completion:^(BOOL finished){}
     ];
}

//================================================================================================================
//
//  COLORS
//
//================================================================================================================
#pragma mark - COLORS

+ (UIColor *) randomColor
{
	CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
}

//================================================================================================================
//
//  VALIDATION / REGEX
//
//================================================================================================================
#pragma mark - VALIDATION / REGEX

+ (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

// http://stackoverflow.com/a/1149894/1449618
+ (BOOL)validateEmail_RFC2822:(NSString *)candidate {
    NSString *emailRegex =
	@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
	@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
	@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
	@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
	@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
	@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
	@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	
    return [emailTest evaluateWithObject:candidate];
}

+ (BOOL)validatePhoneNumber:(NSString*)candidate
{
    NSCharacterSet *digitSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *digits = [[candidate componentsSeparatedByCharactersInSet:digitSet] componentsJoinedByString:@""];
	NSUInteger len = digits.length;
    
    if (len == 10) return YES;
    if (len == 11 && [digits hasPrefix:@"1"]) return YES;
    return NO;
}

+ (BOOL)validateEmailorPhone:(NSString *)candidate
{
	if ([self validateEmail:candidate])return YES;
	if ([self validatePhoneNumber:candidate])return YES;
	return NO;
}

+ (BOOL)beginsWithNumber:(NSString*)candidate{
	NSString *regexString = @"^[0-9]";
    NSPredicate *text = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    BOOL result = [text evaluateWithObject:candidate];
	
	return result;
}

//================================================================================================================
//
//  GUID
//
//================================================================================================================
#pragma mark - GUID

+ (NSString*)newGuidString{
	Guid* randomGuid = [Guid randomGuid];
	// Convert a GUID to a string
	return [randomGuid stringValueWithFormat:GuidFormatDashed];
}

+ (NSString *)slugForString:(NSString *)string
{
    // Remove all non ASCII characters
    NSData *asciiEncoded = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *unfiltered = [[NSString alloc] initWithData:asciiEncoded encoding:NSASCIIStringEncoding];
    
    // Remove any other characters
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    NSString *resultString = [[unfiltered componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    
    // Return it lowercase
    return [resultString lowercaseString];
}

@end

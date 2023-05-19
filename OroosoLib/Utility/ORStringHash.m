//
//  ORStringHash.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 8/8/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORStringHash.h"
#include <CommonCrypto/CommonHMAC.h>
#import "NSData+MKBase64.h"

@implementation ORStringHash

//http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1
+ (NSString*) computeHash_HMACSHA256:(NSString*)stringToHash withKey:(NSString*)key {

	const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
	const char *cData = [stringToHash cStringUsingEncoding:NSASCIIStringEncoding];

	unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

	CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

	NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
										  length:sizeof(cHMAC)];

	//	NSString *hash = [HMAC base64Encoding];
	NSString *hash = [HMAC base64EncodedString];
	return hash;
}

+ (NSString *) createSHA512:(NSString *)source {
	
    const char *s = [source cStringUsingEncoding:NSASCIIStringEncoding];
	
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
	
    CC_SHA512(keyData.bytes, keyData.length, digest);
	
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
	
    return [out description];
}

@end

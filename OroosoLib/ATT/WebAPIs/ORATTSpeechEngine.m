//
//  ORATTSpeechEngine.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 10/5/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORATTSpeechEngine.h"
//#import "SpeechAuth.h"

// Replace the URLs below with the appropriate ones for your Speech API account.
#define SPEECH_URL @"https://api.att.com/rest/1/SpeechToText"
#define OAUTH_URL @"https://api.att.com/oauth/token"
//#error Add code to unobfuscate your Speech API credentials in the macros below, then delete this line.
#define API_KEY @"f99c39be158e18a10239b50f06a5f055" //MY_UNOBFUSCATOR(my_obfuscated_api_key)
#define API_SECRET @"b09e014bc2112995" //MY_UNOBFUSCATOR(my_obfuscated_api_key)

@implementation ORATTSpeechEngine
//
//- (ORATTSpeechEngine*)initShowMeterUI:(BOOL)show {
//	self = [super init];
//	if (self) {
//		self.showUI = show;
//		[self prepareSpeech];
//	}
//	return self;
//}
//
//// Initialize SpeechKit for this app.
//- (void) prepareSpeech
//{
//    // Access the SpeechKit singleton.
//    ATTSpeechService* speechService = [ATTSpeechService sharedSpeechService];
//    
//    // Point to the SpeechToText API.
//    speechService.recognitionURL = [NSURL URLWithString: SPEECH_URL];
//    
//    // Hook ourselves up as a delegate so we can get called back with the response.
//    speechService.delegate = self;
//    
//    // Use default speech UI.
//    speechService.showUI = self.showUI;
//    
//    // Choose the speech recognition package.
//	//    speechService.speechContext = @"BusinessSearch";
//	speechService.speechContext = @"UVerseEPG";
//    
//    // Start the OAuth background operation, disabling the Talk button until it's done.
//	
//    [[SpeechAuth authenticatorForService: [NSURL URLWithString: OAUTH_URL]
//                                  withId: API_KEY secret: API_SECRET]
//	 fetchTo: ^(NSString* token, NSError* error) {
//		 if (token) {
//			 speechService.bearerAuthToken = token;
//		 }
//		 else
//			 [self speechAuthFailed: error];
//	 }];
//	
//    // Wake the audio components so there is minimal delay on the first request.
//    [speechService prepare];
//}
//
//#pragma mark -
//#pragma mark Actions
//
//- (void)listen
//{
//    NSLog(@"Starting speech request");
//    ATTSpeechService* speechService = [ATTSpeechService sharedSpeechService];
//    [speechService startWithMicrophone];
//}
//
//#pragma mark -
//#pragma mark Speech Service Delegate Methods
//
//- (void) speechServiceSucceeded: (ATTSpeechService*) speechService
//{
//    DLog(@"Speech service succeeded");
//    
//    // Extract the needed data from the SpeechService object:
//    // For raw bytes, read speechService.responseData.
//    // For a JSON tree, read speechService.responseDictionary.
//    // For the n-best ASR strings, use speechService.responseStrings.
//    
//    // In this example, use the ASR strings.
//    // There can be 0 strings, 1 empty string, or 1 non-empty string.
//    // Display the recognized text in the interface is it's non-empty,
//    // otherwise have the user try again.
//    NSArray* nbest = speechService.responseStrings;
//    NSString* recognizedText = @"";
//    if (nbest != nil && nbest.count > 0)
//        recognizedText = [nbest objectAtIndex: 0];
//    if (recognizedText.length) { // non-empty?
//		[self.delegate speechSucceeded:recognizedText];
//	} else {
//		[self.delegate speechFailed:@"Not recognized"];
//
////        UIAlertView* alert =
////		[[UIAlertView alloc] initWithTitle: @"Didn't recognize speech"
////								   message: @"Please try again."
////								  delegate: self
////						 cancelButtonTitle: @"OK"
////						 otherButtonTitles: nil];
////        [alert show];
//    }
//}
//
//- (void) speechService: (ATTSpeechService*) speechService
//	   failedWithError: (NSError*) error
//{
//    if ([error.domain isEqualToString: ATTSpeechServiceErrorDomain]
//        && (error.code == ATTSpeechServiceErrorCodeCanceledByUser)) {
//        DLog(@"Speech service canceled");
//		[self.delegate speechFailed:@"Speech service cancelled"];
//        // Nothing to do in this case
//        return;
//    }
//    DLog(@"Speech service had an error: %@", error);
//	[self.delegate speechFailed:[error localizedDescription]];
//    
////    UIAlertView* alert =
////	[[UIAlertView alloc] initWithTitle: @"An error occurred"
////							   message: @"Please try again later."
////							  delegate: self
////					 cancelButtonTitle: @"OK"
////					 otherButtonTitles: nil];
////    [alert show];
//}
//
//#pragma mark -
//#pragma mark OAuth
//
///* The SpeechAuth authentication failed. */
//- (void) speechAuthFailed: (NSError*) error
//{
//    DLog(@"OAuth error: %@", error);
//	[self.delegate speechFailed:[error localizedDescription]];
//	
////    UIAlertView* alert =
////	[[UIAlertView alloc] initWithTitle: @"Speech Unavailable"
////							   message: @"This app was rejected by the speech service.  Contact the developer for an update."
////							  delegate: self
////					 cancelButtonTitle: @"OK"
////					 otherButtonTitles: nil];
////    [alert show];
//}
//

@end

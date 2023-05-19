//
//  ORUVerse.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/27/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORUVerse.h"

//#define __DCS_PRODUCTION__ 1
#define __DCS_ZDEV__ 1
//#define __DCS_FOUNDRY__ 1

#ifdef __DCS_PRODUCTION__
#define DCS_SERVER @"https://vsapps.asp.att.net/dais/"
#define AAP_RESOURCE_FILE @"prodca.resource"
#define AAP_DEVELOPER_KEY @"prodca.satoken"
#elif defined __DCS_ZDEV__
#define DCS_SERVER @"https://zdevsa.asp.att.net/dais/"
#define AAP_RESOURCE_FILE @"zdevca.resource"
#define AAP_DEVELOPER_KEY @"zdevca.satoken"
#elif defined __DCS_FOUNDRY__
#define DCS_SERVER @"https://swsdcs.foundry.att.com/dais/"
#define AAP_RESOURCE_FILE @"testca.resource"
#define AAP_DEVELOPER_KEY @"testca.satoken"
#endif

// Notification message names
NSString *const uvStatus = @"uvStatus";
NSString *const uvGotProgramInfo = @"uvGotProgramInfo";

@implementation ORUVerse
@synthesize uvSTBManager, currentSTB, unknownSTBs;
@synthesize receiverList;

- (ORUVerse*) init {

	NSURL *url = [[NSBundle mainBundle] URLForResource:AAP_DEVELOPER_KEY withExtension:nil];
    NSString *sharedSecret = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];

    uvSTBManager = [UverseConnectedManager sharedManager];
    [uvSTBManager.userInfo setObject:sharedSecret forKey:UverseEnabledDeveloperKey];
    uvSTBManager.fileNameAAP = AAP_RESOURCE_FILE;
    uvSTBManager.overrideURL = DCS_SERVER;    

	[self registerForNotifications];
	unknownSTBs = NO;
	
    if(uvSTBManager.state == LibraryNotReady){
        [self discoverReceiversOnNetwork];
    } else {
		if (uvSTBManager.mostRecentlyEngagedSetTopBox == nil){
			[self associateWithSTB:uvSTBManager.mostRecentlyEngagedSetTopBox];
		} else {
			DLog(@"STB: %@", uvSTBManager.mostRecentlyEngagedSetTopBox.friendlyName);
		}
	}
	
	return self;
}

//  DISCOVERY & PAIRING
//================================================================================================================
#pragma mark - DISCOVERY & PAIRING

- (void) discoverReceiversOnNetwork {
	UverseConnectedManager *uvcMgr = [UverseConnectedManager sharedManager];
    if (uvcMgr.state == LibraryReady && uvcMgr.SetTopBoxes != nil){
		[self setupListOfSTBsAfterDiscovery];
    } else if (uvcMgr.state == LibraryNotReady) {
        [uvcMgr startDiscovery];
    } else {
        // if the middle of Discovery
    }
}

-(void)associateToSTBAfterDiscovery {
    UverseConnectedManager *uvcMgr = [UverseConnectedManager sharedManager];
    SetTopBox *lastUsedSTB = uvcMgr.mostRecentlyEngagedSetTopBox;
    if (lastUsedSTB != nil){
        if (lastUsedSTB.mode == UverseModeOpen || (lastUsedSTB.mode == UverseModeManaged && lastUsedSTB.isAssociated)){
            [lastUsedSTB associateAndEngageWithOneTimeToken:nil];
        }else {
			[self setupListOfSTBsAfterDiscovery];
        }
    } else {
		[self setupListOfSTBsAfterDiscovery];
    }
}

-(void)associateWithSTB:(SetTopBox*)stb {
    if (stb != nil){
        if (stb.mode == UverseModeOpen || (stb.mode == UverseModeManaged && stb.isAssociated)){
            [stb associateAndEngageWithOneTimeToken:nil];
        }else {
//			[self setupListOfSTBsAfterDiscovery];
        }
    } else {
//		[self setupListOfSTBsAfterDiscovery];
    }
}

-(void)setupListOfSTBsAfterDiscovery{
	DLog(@"UVERSE SETUP LIST OF STBs");
    unknownSTBs = NO;
    UverseConnectedManager *uvcMgr = [UverseConnectedManager sharedManager];
	self.receiverList = [[NSMutableArray alloc] init];

    for (SetTopBox *stb in  [uvcMgr SetTopBoxes]) {
        
        switch (stb.mode) {
				// if the mode is open or mananged, add the stb to the list of the stbs to display    
            case UverseModeOpen:
            case UverseModeManaged:
                [self.receiverList addObject:stb];
                break;
            case UverseModeUnknown:
				unknownSTBs = YES;
                break;
            case UverseModeClosed:
                break;
            default:
                break;
        }
    }
    [self.receiverList sortedArrayUsingComparator:^(SetTopBox *first, SetTopBox *second){
        return [first.friendlyName localizedCaseInsensitiveCompare:second.friendlyName];
    }];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"uverse_stbListReady" object:nil];
}

//  INFO QUERY
//================================================================================================================
#pragma mark - INFO QUERY

- (void) queryCurrentProgramInfo {
    UverseConnectedManager *uvcMgr = [UverseConnectedManager sharedManager];
    uverseProgram *tmpCurrentProgram = [uvcMgr.mostRecentlyEngagedSetTopBox currentProgram];
//    NSLog(@"Program title: %@", tmpCurrentProgram.title);
//    NSLog(@"Channel: %d", tmpCurrentProgram.channel);
//    NSLog(@"Time: %@", tmpCurrentProgram.time);
//    NSLog(@"Description: %@", tmpCurrentProgram.description);
//    NSLog(@"Episode: %@", tmpCurrentProgram.episode);
//    NSLog(@"Duration: %@", tmpCurrentProgram.duration);
//    NSLog(@"Type: %d", tmpCurrentProgram.type);
//    NSLog(@"tuneString: %@", tmpCurrentProgram.tuneString);
//    NSLog(@"dvrStatus: %d", tmpCurrentProgram.dvrStatus);
//    NSLog(@"Ratings: %@", tmpCurrentProgram.ratings);
	if (tmpCurrentProgram) {
		[[NSNotificationCenter defaultCenter] postNotificationName:uvGotProgramInfo object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[[ORUverseTitle alloc] initWithUverseProgram:tmpCurrentProgram], @"currentProgram", nil]];
//		[[NSNotificationCenter defaultCenter] postNotificationName:uvGotProgramInfo object:self userInfo:[self dictForProgram:tmpCurrentProgram]];
	}
}

//  REMOTE CONTROL
//================================================================================================================
#pragma mark - REMOTE CONTROL

- (void) pausePlay {
	if (isUversePaused == YES) {
		[self sendButtonCommand:[[uveRemoteButtonCommand alloc] initWithRemoteKey:RK_play]];
		isUversePaused = NO;
	} else {
		[self sendButtonCommand:[[uveRemoteButtonCommand alloc] initWithRemoteKey:RK_pause]];
		isUversePaused = YES;
	}
}
bool isUversePaused = NO;

- (void) sendButtonCommand:(uveRemoteButtonCommand*)cmd {
//	uveRemoteButtonCommand *buttonCommand =[[uveRemoteButtonCommand alloc] initWithRemoteKey:button.tag];
	[uvSTBManager.mostRecentlyEngagedSetTopBox sendSetTopBoxCommand:cmd];
}

//  NOTIFICATIONS
//================================================================================================================
#pragma mark - NOTIFICATIONS

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uveSTBCommandSucceeded:) name:uveSetTopBoxCommandDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uveSTBCommandFailed:) name:uveSetTopBoxCommandDidFail object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uvcSTBAssociationDidSucceed:) name:uveSetTopBoxEngagementDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uvcSTBAssociationDidFail:) name:uveSetTopBoxEngagementDidFail object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uveMgrDidChangeState:) name:UverseConnectedManagerDidChangeState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uveMgrErrorOccurred:) name:UverseConnectedManagerErrorOccurred object:nil];
}

-(void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uveSetTopBoxCommandDidFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uveSetTopBoxCommandDidSucceed object:nil];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uveSetTopBoxEngagementDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:uveSetTopBoxEngagementDidFail object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UverseConnectedManagerDidChangeState object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UverseConnectedManagerErrorOccurred  object:nil];
}

-(void)uveMgrDidChangeState:(NSNotification *)notification{
    switch(uvSTBManager.state) {
        case LibraryReady:
            NSLog(@"NOTIFICATION UverseConnectedManagerDidChangeState: LibraryReady");
			[self sendStatusNote:@"connectionSuccess"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"uverse_libraryReady" object:self];
			[self associateToSTBAfterDiscovery];
            break;
            
        case LibraryNotReady:{
			[self sendStatusNote:@"connectionFailed"];
            NSLog(@"NOTIFICATION UverseConnectedManagerDidChangeState: LibraryNotReady");                 
            [self.receiverList removeAllObjects];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"uverse_libraryNotReady" object:self];
            break;
        }
        case DiscoveringNetwork:
            NSLog(@"NOTIFICATION UverseConnectedManagerDidChangeState: DiscoveringNetwork");                
			[[NSNotificationCenter defaultCenter] postNotificationName:@"uverse_discoveringNetwork" object:self];
            break;
            
        case LibraryBlocked:
			[self sendStatusNote:@"connectionFailed"];
            NSLog(@"NOTIFICATION UverseConnectedManagerDidChangeState: LibraryBlocked");                
            break;
            
        case WaitingForWiFiConnection:
            NSLog(@"NOTIFICATION UverseConnectedManagerDidChangeState: WaitingForWiFiConnection");      
            break;
    }
}

-(void)uveMgrErrorOccurred:(NSNotification *)notification{
	DLog(@"UVERSE MANAGER ERROR OCCURRED");
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:UverseConnectedManagerErrorKey];
    
    NSString *msg = @"Unknown Error";
    switch(error.code)
    {
        case uveNotOnAUverseNetwork:
            msg = @"Not on Uverse Network";
            break;
        case uveInternalError:
            msg = @"Zeus Internal Error";
            break;
        case uveNetworkError:
            msg = @"Zeus Network Error";
            break;
        case uveApplicationBlocked:
            msg = @"This applicaiton has been dsiabled";
            break;
        case uveDeviceRegistrationError:
            msg = @"Zeus Device Registration Error";
            break;
        case uveAuthTokenRequired:
            msg = @"Zeus Auth Token Required";
            break;
        case uveAuthTokenInvalid:
            msg = @"Zeus Auth Token Invalid";
            break;
        case uveNotOnSubscriberNetwork:
            msg = @"Not on Subscriber Network";
            break;
        case uveDeviceNotAllowedToRun:
            msg = @"This DAIS device is not allowed to be used in this household.";
            break;
        case uveLibrarySessionExpired:
            msg = @"Your Session has expired. Please restart discovery";
            break;
        default:
            break;
    }
    NSLog(@"NOTIFICATION UverseConnectedManagerErrorOccurred: %@", msg);

//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
}

- (void) uvcSTBAssociationDidSucceed:(NSNotification *) notification{
	DLog(@"UVERSE ASSOCIATION DID SUCCEED");
    UverseConnectedManager *uvcMgr = [UverseConnectedManager sharedManager];
	SetTopBox *lastUsedSTB = uvcMgr.mostRecentlyEngagedSetTopBox;
	NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:1];
	[info setObject:lastUsedSTB.deviceId forKey:@"deviceId"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"uverse_associationSucceeded" object:self userInfo:info];
	[self queryCurrentProgramInfo];
}

-(void)uvcSTBAssociationDidFail:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:UverseConnectedManagerErrorKey];
	DLog(@"UVERSE ASSOCIATION DID FAIL. Error: %@ %d", [error localizedDescription], error.code);
    switch (error.code) {
        case uveNonceInvalid:
			NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uveNonceInvalid");
			//            if ([self.navigationController.visibleViewController isKindOfClass:[PasswordViewController class]]){
			//                PasswordViewController *passwordController = 
			//                (PasswordViewController *)self.navigationController.visibleViewController;
			//                passwordController.bottomLabel.textColor = [UIColor redColor];
			//                passwordController.bottomLabel.text = @"Please retry Password";
			//            }
            break;
        case uveAuthTokenInvalid: 
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcAuthTokenInvalid");
            break;
        case uveNotOnSubscriberNetwork: 
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcNotOnSubscriberNetwork");
            break;
        case uveSetTopBoxNotRegistered:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcSetTopBoxNotRegistered");
            break;
        case uveSetTopBoxNotAllowed: 
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcSetTopBoxNotAllowed");
            break;
        case uveNonceRequired:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcNonceRequired");
            break;
        case uveNotOnAUverseNetwork: {
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcNotOnAUverseNetwork");
			//            InfoViewController *noUverseViewController = [[InfoViewController alloc] initWithStyle:uvcNotOnAUverseNetworkStyle];
			//            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noUverseViewController];
			//            [self presentModalViewController:navController animated:YES];
            break;
        }
        case uveURLNotAllowed: 
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcURLNotAllowed");
            break;
        case uveOperationNotAllowed: 
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcOperationNotAllowed");
            break;
        case uveAllSetTopBoxInUse:{
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcAllSetTopBoxInUse");
            break;
        }
        case uveApplicationBlocked:{
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcApplicationBlocked");
            break;
        }
        case uveDeviceRegistrationError:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcDeviceRegistrationError");
            break;
        case uveInternalError:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcInternalError");
            break;
        case uveNetworkError:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcNetworkError");
			//            InfoViewController *networkViewController = [[InfoViewController alloc] initWithStyle:uvcNetworkErrorStyle];
			//            UINavigationController *nav2Controller = [[UINavigationController alloc] initWithRootViewController:networkViewController];
			//            [self presentModalViewController:nav2Controller animated:YES];
            break;
        case uveAuthTokenRequired:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcAuthTokenRequired");
            break;
        case uveNonceExpired:
            NSLog(@"NOTIFICATION uvcSetTopBoxAssociationDidFail:uvcNonceExpired");
            break;
            
        default:
            break;
    }
    
}

-(void)uveSTBCommandSucceeded:(NSNotification *)notification{
//	for (id key in notification.userInfo) {
//        NSLog(@"key: %@, value: %@", key, [notification.userInfo objectForKey:key]);
//    }
	id cmd = [notification.userInfo objectForKey:[notification.userInfo.allKeys objectAtIndex:0]];
	if ([cmd isKindOfClass:[uveInfoCommand class]]) {
		uveInfoCommand *infoCmd = (uveInfoCommand*)cmd;
		[[NSNotificationCenter defaultCenter] postNotificationName:uvGotProgramInfo object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[[ORUverseTitle alloc] initWithUverseProgram:infoCmd.program], @"currentProgram", nil]];
//		[[NSNotificationCenter defaultCenter] postNotificationName:uvGotProgramInfo object:self userInfo:[self dictForProgram:infoCmd.program]];
	}
    NSLog(@"NOTIFICATION uvcSetTopBoxCommandDidSucceed");
}

-(void)uveSTBCommandFailed:(NSNotification *)notification{
    NSLog(@"NOTIFICATION uveSetTopBoxCommandDidFail");
}

- (void) sendStatusNote:(NSString*)status {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:status forKey:@"status"];
	[[NSNotificationCenter defaultCenter] postNotificationName:uvStatus object:self userInfo:userInfo];
}

- (NSMutableDictionary*) dictForProgram:(uverseProgram*)prog {
	NSMutableDictionary *program = [[NSMutableDictionary alloc] init];
	if (prog.title) [program setObject:prog.title forKey:@"title"];
	if (prog.channel) [program setObject:[NSString stringWithFormat:@"%d", prog.channel] forKey:@"channel"];
	if (prog.time) [program setObject:prog.time forKey:@"time"];
	if (prog.description) [program setObject:prog.description forKey:@"description"];
	if (prog.episode) [program setObject:prog.episode forKey:@"episode"];
	if (prog.duration) [program setObject:prog.duration forKey:@"duration"];
	if (prog.type) [program setObject:[NSString stringWithFormat:@"%d", prog.type] forKey:@"type"];
	//	if (prog.tuneString) [program setObject:prog.tuneString forKey:@"tuneString"];
	if (prog.dvrStatus) [program setObject:[NSString stringWithFormat:@"%d", prog.dvrStatus] forKey:@"dvrStatus"];
	//	if (prog.ratings) [program setObject:prog.ratings forKey:@"ratings"];
	return program;
}

@end

//
//  ORStrings.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 21/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORStrings.h"

// GENERAL
//================================================================================================================
#pragma mark - GENERAL

NSString *appName = @"Portl";
NSString *appDomain = @"portl.it";
NSString *appUrl = @"http://www.portl.it";
NSString *appStoreUrl = @"http://www.appstore.com/portl";

// STATIC HOSTED IMAGES
//================================================================================================================
#pragma mark - STATIC HOSTED IMAGES

NSString *urlSentFromPortl = @"https://s3.amazonaws.com/portl-static/portl-email-badge-240x128.jpg";
NSString *appStoreBadgeUrl = @"https://s3.amazonaws.com/orooso-static/Download_on_the_App_Store_Badge_US-UK_108x32.png";
NSString *urlWikiGlobe100x = @"https://s3.amazonaws.com/orooso-static/wiki-globe-100x100.png";
NSString *urlTwitterBlueBird100x = @"https://s3.amazonaws.com/orooso-static/twitter-blue-bird_100x100.png";
NSString *urlFacebookTile80x = @"https://s3.amazonaws.com/orooso-static/facebook-tile-80x80.png";

// SIGN-IN / OUT
//================================================================================================================
#pragma mark - SIGN-IN / OUT

NSString *orPresentDialog_SignIn = @"orPresentDialog_SignIn";
NSString *orSignedIn = @"orSignedIn";
NSString *orSignedOut = @"orSignedOut";
NSString *orPerformSignout = @"orPerformSignout";

// CURTAIN
//================================================================================================================
#pragma mark - CURTAIN

NSString *orHideCurtain = @"orHideCurtain";
NSString *orCurtainWasHidden = @"orCurtainWasHidden";

// ENTITIES
//================================================================================================================
#pragma mark - ENTITIES

NSString *orAddEntity = @"orAddEntity";
NSString *orRemoveEntity = @"orRemoveEntity";
NSString *orPreloadEntity = @"orPreloadEntity";
NSString *orCancelPreload = @"orCancelPreload";
NSString *orLoadDynamicEntity = @"orLoadDynamicEntity";
NSString *orReloadCurrentEntity = @"orReloadCurrentEntity";
NSString *orTopicLoaded = @"orTopicLoaded";
NSString *orAssociatedEntityLoaded = @"orAssociatedEntityLoaded";
NSString *orEntityPinnedStatus = @"orEntityPinnedStatus";

// DIALOGS
//================================================================================================================
#pragma mark - DIALOGS

NSString *orPresentDialog = @"orPresentDialog";
NSString *orDismissDialog = @"orDismissDialog";
NSString *orRemoveAllDialogs = @"orRemoveAllDialogs";

// SHARING
//================================================================================================================
#pragma mark - SHARING

NSString *orShareThis = @"orShareThis";
NSString *orPresentDialog_SocialConsole = @"orPresentDialog_SocialConsole";
NSString *orStoreSharable = @"orStoreSharable";
NSString *orInviteFriends = @"orInviteFriends";

// TWITTER
//================================================================================================================
#pragma mark - TWITTER

NSString *orPresentDialog_TwitterUserView = @"orPresentDialog_TwitterUserView";
NSString *orPresentDialog_TwitterHashtagView = @"orPresentDialog_TwitterHashtagView";
NSString *orPresentDialog_TwitterConversationView = @"orPresentDialog_TwitterConversationView";

// IMAGES
//================================================================================================================
#pragma mark - IMAGES

NSString *orPresentImageViewer = @"orPresentImageViewer";
NSString *orPictureCellImageFailed = @"orPictureCellImageFailed";

// WEBVIEWER
//================================================================================================================
#pragma mark - WEBVIEWER

NSString *orPresentWebViewer = @"orPresentWebViewer";
NSString *orDismissWebViewSoft = @"orDismissWebViewSoft";
NSString *orWebViewDismissed = @"orWebViewDismissed";

// PROFILE AREA / USER
//================================================================================================================
#pragma mark - PROFILE AREA / USER

NSString *orPresentFindFriends = @"orPresentFindFriends";
NSString *orPresentUserInspector = @"orPresentUserInspector";
NSString *orPresentProfileArea = @"orPresentProfileArea";
NSString *orDismissProfileArea = @"orDismissProfileArea";
NSString *orUserProfileUpdated = @"orUserProfileUpdated";
NSString *orPairAfterSignIn = @"orPairAfterSignIn";

// RECENT AREA
//================================================================================================================
#pragma mark - RECENT AREA

NSString *orPresentRecentArea = @"orPresentRecentArea";
NSString *orClearRecents = @"orClearRecents";
NSString *orDismissRecentArea = @"orDismissRecentArea";

// NOTIFICATION BOX
//================================================================================================================
#pragma mark - NOTIFICATION BOX

NSString *orPresentNotification = @"orPresentNotification";
NSString *noteRetweeted = @"Retweeted!";
NSString *noteRetweetRetracted = @"Un-Retweeted!!";
NSString *noteFavorited = @"Favorited!";
NSString *noteUnfavorited = @"Unfavorited!!";
NSString *noteSent = @"Sent!";
NSString *noteFollowed = @"Followed!";
NSString *noteUnfollowed = @"Un-Followed!!";
NSString *noteSaved = @"Saved!";

// INSTRUCTIONALS
//================================================================================================================
#pragma mark - INSTRUCTIONALS

NSString *orPresentInstructional = @"orPresentInstructional";
NSString *orInstructionalGoNext = @"orInstructionalGoNext";
NSString *orInstructionalGoPrevious = @"orInstructionalGoPrevious";
NSString *orInstructionalGoToPage = @"orInstructionalGoToPage";

// PAIRING
//================================================================================================================
#pragma mark - PAIRING

NSString *orPromptPair = @"orPromptPair";
NSString *orPairService = @"orPairService";
NSString *orUnpairService = @"orUnpairService";
NSString *orPresentDialog_OAuth = @"orPresentDialog_OAuth";
NSString *orServicePaired = @"orServicePaired";
NSString *orServiceUnpaired = @"orServiceUnpaired";

// MEDIA PLAYER
//================================================================================================================
#pragma mark - MEDIA PLAYER

NSString *orHideMediaPlayer = @"orHideMediaPlayer";
NSString *orCollapseMediaPlayer = @"orCollapseMediaPlayer";
NSString *orExpandMediaPlayer = @"orExpandMediaPlayer";
NSString *orPresentMediaPlayer = @"orPresentMediaPlayer";
NSString *orToggleMediaPlayer = @"orToggleMediaPlayer";
NSString *orDismissMediaPlayer = @"orDismissMediaPlayer";
NSString *orMediaPlayerHidden = @"orMediaPlayerHidden";
NSString *orMediaPlayerRevealed = @"orMediaPlayerRevealed";

NSString *orVideoError = @"orVideoError";
NSString *orVideoPlaying = @"orVideoPlaying";
NSString *orVideoPaused = @"orVideoPaused";
NSString *orPauseVideo = @"orPauseVideo";
NSString *orUnpauseVideo = @"orUnpauseVideo";
NSString *orStopVideo = @"orStopVideo";
NSString *orTogglePauseVideo = @"orTogglePauseVideo";
NSString *orNextVideo = @"orNextVideo";
NSString *orPrevVideo = @"orPrevVideo";
NSString *orPlayerReload = @"orPlayerReload";

// DISCOVERY
//================================================================================================================
#pragma mark - DISCOVERY

NSString *orDiscoveryOpened = @"orDiscoveryOpened";
NSString *orDiscoveryClosed = @"orDiscoveryClosed";
NSString *orHideDiscoveryDetail = @"orHideDiscoveryDetail";
NSString *orPresentDiscoveryDetail = @"orPresentDiscoveryDetail";
NSString *orDiscoveryDetailImageReload = @"orDiscoveryDetailImageReload";
NSString *orDiscoveryDetailWillFlip = @"orDiscoveryDetailWillFlip";
NSString *orDiscoveryDetailFlipped = @"orDiscoveryDetailFlipped";

// VIEW
//================================================================================================================
#pragma mark - VIEW

NSString *orViewOpened = @"orViewOpened";
NSString *orViewClosed = @"orViewClosed";

// SYNCFLOW
//================================================================================================================
#pragma mark - SYNCFLOW

NSString *orStartAutoScroll = @"orStartAutoScroll";
NSString *orStopAutoScroll = @"orStopAutoScroll";
NSString *orPauseAutoScroll = @"orPauseAutoScroll";
NSString *orUnpauseAutoScroll = @"orUnpauseAutoScroll";
NSString *orToggleAutoScroll = @"orToggleAutoScroll";
NSString *orResumeSyncFlow = @"orResumeSyncFlow";

// FAVORITING & PINNING
//================================================================================================================
#pragma mark - FAVORITING & PINNING

NSString *orPin = @"orPin";
NSString *orUnpin = @"orUnpin";
NSString *orPinned = @"orPinned";
NSString *orUnpinned = @"orUnpinned";
NSString *orBoardChanged = @"orBoardChanged";
NSString *orFollowStateChanged = @"orFollowStateChanged";

// IN-APP NOTIFICATIONS
//================================================================================================================
#pragma mark - IN-APP NOTIFICATIONS
NSString *orInAppNotificationCountUpdated = @"orInAppNotificationCountUpdated";

// ETC
//================================================================================================================
#pragma mark - ETC

NSString *orLogoTapped = @"orLogoTapped";
NSString *orPauseUniversalLpgr = @"orPauseUniversalLpgr";
NSString *orEndEditing = @"orEndEditing";
NSString *orPauseSyncFlowGestureRecognizer = @"orPauseSyncFlowGestureRecognizer";
NSString *orCleanUpGoHome = @"orCleanUpGoHome";

// LOGGING
//================================================================================================================
#pragma mark - LOGGING

NSString *logEvent_Loaded = @"Loaded";
NSString *logEvent_Unloaded = @"Unloaded";
NSString *logEvent_Tapped = @"Tapped";

NSString *logLocation_App = @"App";
NSString *logLocation_User = @"User";
NSString *logLocation_SignUp = @"SignUp";
NSString *logLocation_SignIn = @"SignIn";
NSString *logLocation_Discovery = @"Discovery";
NSString *logLocation_Search = @"Search";
NSString *logLocation_NowPlaying = @"NowPlaying";
NSString *logLocation_EntityHome = @"EntityHome";
NSString *logLocation_EntityList = @"EntityList";
NSString *logLocation_EntityListDrawer = @"EntityListDrawer";
NSString *logLocation_SyncFlow = @"SyncFlow";
NSString *logLocation_SyncFlowCard_Tweet = @"SyncFlowCard_Tweet";
NSString *logLocation_VideoViewer = @"VideoViewer";
NSString *logLocation_PictureViewer = @"PictureViewer";
NSString *logLocation_WebViewer = @"WebViewer";
NSString *logLocation_TwitterAccountViewer = @"TwitterAccountViewer";
NSString *logLocation_HashtagViewer = @"HashtagViewer";
NSString *logLocation_Share = @"Share";
NSString *logLocation_Settings = @"Settings";
NSString *logLocation_Entity = @"Entity";
NSString *logLocation_Performance = @"Performance";

#pragma mark - SyncFlow Engine

NSString *sfeEnterBackground = @"sfeEnterBackground";
NSString *sfeResumeFromBackground = @"sfeResumeFromBackground";
NSString *sfeLocationUpdated = @"sfeLocationUpdated";
NSString *sfeSummaryCellImageFailed = @"sfeSummaryCellImageFailed";
NSString *sfeFatalFailure = @"sfeFatalFailure";
NSString *sfeItemsReloaded = @"sfeItemsReloaded";
NSString *sfeItemsChanged = @"sfeItemsChanged";
NSString *sfeItemsArrived = @"sfeItemsArrived";
NSString *sfeCurrentRunningTime = @"sfeCurrentRunningTime";
NSString *sfeEntityPreloaded = @"sfeEntityPreloaded";
NSString *sfeEntityAdded = @"sfeEntityAdded";

#pragma mark - SpotMe
NSString *smSharedSpotAdded = @"smSharedSpotAdded";
NSString *smFollowedSpotAdded = @"smFollowedSpotAdded";
NSString *smSharedSpotRemoved = @"smSharedSpotRemoved";
NSString *smFollowedSpotRemoved = @"smFollowedSpotRemoved";
NSString *smSharedSpotsUpdated = @"smSharedSpotsUpdated";
NSString *smFollowedSpotsUpdated = @"smFollowedSpotsUpdated";

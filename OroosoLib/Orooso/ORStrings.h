//
//  ORStrings.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 21/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#ifndef ORStrings_h
#define ORStrings_h

// GENERAL
extern NSString *appName;
extern NSString *appDomain;
extern NSString *appUrl;
extern NSString *appStoreUrl;

// STATIC HOSTED IMAGES
extern NSString *urlSentFromPortl;
extern NSString *appStoreBadgeUrl;
extern NSString *urlWikiGlobe100x;
extern NSString *urlTwitterBlueBird100x;
extern NSString *urlFacebookTile80x;

// SIGN-IN / OUT
extern NSString *orPresentDialog_SignIn;
extern NSString *orSignedIn;
extern NSString *orSignedOut;
extern NSString *orPerformSignout;

// CURTAIN
extern NSString *orHideCurtain;
extern NSString *orCurtainWasHidden;

// ENTITIES
extern NSString *orAddEntity;
extern NSString *orRemoveEntity;
extern NSString *orPreloadEntity;
extern NSString *orCancelPreload;
extern NSString *orLoadDynamicEntity;
extern NSString *orReloadCurrentEntity;
extern NSString *orTopicLoaded;
extern NSString *orAssociatedEntityLoaded;
extern NSString *orEntityPinnedStatus;

// DIALOGS
extern NSString *orPresentDialog;
extern NSString *orDismissDialog;
extern NSString *orRemoveAllDialogs;

// SHARING
extern NSString *orShareThis;
extern NSString *orPresentDialog_SocialConsole;
extern NSString *orStoreSharable;
extern NSString *orInviteFriends;

// TWITTER
extern NSString *orPresentDialog_TwitterUserView;
extern NSString *orPresentDialog_TwitterHashtagView;
extern NSString *orPresentDialog_TwitterConversationView;

// IMAGES
extern NSString *orPresentImageViewer;
extern NSString *orPictureCellImageFailed;

// WEBVIEWER
extern NSString *orPresentWebViewer;
extern NSString *orDismissWebViewSoft;
extern NSString *orWebViewDismissed;

// PROFILE AREA / USER
extern NSString *orPresentFindFriends;
extern NSString *orPresentUserInspector;
extern NSString *orPresentProfileArea;
extern NSString *orDismissProfileArea;
extern NSString *orUserProfileUpdated;
extern NSString *orPairAfterSignIn;

// RECENT AREA
extern NSString *orPresentRecentArea;
extern NSString *orClearRecents;
extern NSString *orDismissRecentArea;

// NOTIFICATION BOX
extern NSString *orPresentNotification;
extern NSString *noteRetweeted;
extern NSString *noteRetweetRetracted;
extern NSString *noteFavorited;
extern NSString *noteUnfavorited;
extern NSString *noteSent;
extern NSString *noteFollowed;
extern NSString *noteUnfollowed;
extern NSString *noteSaved;

// INSTRUCTIONALS
extern NSString *orPresentInstructional;
extern NSString *orInstructionalGoNext;
extern NSString *orInstructionalGoPrevious;
extern NSString *orInstructionalGoToPage;

// PAIRING
extern NSString *orPromptPair;
extern NSString *orPairService;
extern NSString *orUnpairService;
extern NSString *orPresentDialog_OAuth;
extern NSString *orServicePaired;
extern NSString *orServiceUnpaired;

// MEDIA PLAYER
extern NSString *orHideMediaPlayer;
extern NSString *orCollapseMediaPlayer;
extern NSString *orExpandMediaPlayer;
extern NSString *orPresentMediaPlayer;
extern NSString *orToggleMediaPlayer;
extern NSString *orDismissMediaPlayer;
extern NSString *orMediaPlayerHidden;
extern NSString *orMediaPlayerRevealed;

extern NSString *orVideoError;
extern NSString *orVideoPlaying;
extern NSString *orVideoPaused;
extern NSString *orPauseVideo;
extern NSString *orUnpauseVideo;
extern NSString *orStopVideo;
extern NSString *orTogglePauseVideo;
extern NSString *orNextVideo;
extern NSString *orPrevVideo;
extern NSString *orPlayerReload;

// DISCOVERY
extern NSString *orDiscoveryOpened;
extern NSString *orDiscoveryClosed;
extern NSString *orHideDiscoveryDetail;
extern NSString *orPresentDiscoveryDetail;
extern NSString *orDiscoveryDetailImageReload;
extern NSString *orDiscoveryDetailWillFlip;
extern NSString *orDiscoveryDetailFlipped;

// VIEW
extern NSString *orViewOpened;
extern NSString *orViewClosed;

// SYNCFLOW
extern NSString *orStartAutoScroll;
extern NSString *orStopAutoScroll;
extern NSString *orPauseAutoScroll;
extern NSString *orUnpauseAutoScroll;
extern NSString *orToggleAutoScroll;
extern NSString *orResumeSyncFlow;

// FAVORITING & PINNING
extern NSString *orPin;
extern NSString *orUnpin;
extern NSString *orPinned;
extern NSString *orUnpinned;
extern NSString *orBoardChanged;
extern NSString *orFollowStateChanged;

// IN-APP NOTIFICATIONS
extern NSString *orInAppNotificationCountUpdated;

// ETC
extern NSString *orLogoTapped;
extern NSString *orPauseUniversalLpgr;
extern NSString *orEndEditing;
extern NSString *orPauseSyncFlowGestureRecognizer;
extern NSString *orCleanUpGoHome;

// LOGGING
extern NSString *logEvent_Loaded;
extern NSString *logEvent_Unloaded;
extern NSString *logEvent_Tapped;
extern NSString *logLocation_App;
extern NSString *logLocation_User;
extern NSString *logLocation_SignUp;
extern NSString *logLocation_SignIn;
extern NSString *logLocation_Discovery;
extern NSString *logLocation_Search;
extern NSString *logLocation_NowPlaying;
extern NSString *logLocation_EntityHome;
extern NSString *logLocation_EntityList;
extern NSString *logLocation_EntityListDrawer;
extern NSString *logLocation_SyncFlow;
extern NSString *logLocation_SyncFlowCard_Tweet;
extern NSString *logLocation_VideoViewer;
extern NSString *logLocation_PictureViewer;
extern NSString *logLocation_WebViewer;
extern NSString *logLocation_TwitterAccountViewer;
extern NSString *logLocation_HashtagViewer;
extern NSString *logLocation_Share;
extern NSString *logLocation_Settings;
extern NSString *logLocation_Entity;
extern NSString *logLocation_Performance;

// SyncFlow Engine
extern NSString *sfeEnterBackground;
extern NSString *sfeResumeFromBackground;
extern NSString *sfeLocationUpdated;
extern NSString *sfeSummaryCellImageFailed;
extern NSString *sfeFatalFailure;
extern NSString *sfeItemsReloaded;
extern NSString *sfeItemsChanged;
extern NSString *sfeItemsArrived;
extern NSString *sfeCurrentRunningTime;
extern NSString *sfeEntityPreloaded;
extern NSString *sfeEntityAdded;

// SpotMe
extern NSString *smSharedSpotAdded;
extern NSString *smFollowedSpotAdded;
extern NSString *smSharedSpotRemoved;
extern NSString *smFollowedSpotRemoved;
extern NSString *smSharedSpotsUpdated;
extern NSString *smFollowedSpotsUpdated;

#endif

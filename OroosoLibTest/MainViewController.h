//
//  ViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 20/07/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface MainViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *googleUser;
@property (weak, nonatomic) IBOutlet UILabel *facebookUser;
@property (weak, nonatomic) IBOutlet UILabel *attUser;
@property (weak, nonatomic) IBOutlet UILabel *twitterUser;
@property (weak, nonatomic) IBOutlet UILabel *totalContacts;
@property (weak, nonatomic) IBOutlet UILabel *selectedContact;
@property (weak, nonatomic) IBOutlet UITextField *searchQuery;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *googleImage;
@property (weak, nonatomic) IBOutlet UIImageView *facebookImage;
@property (weak, nonatomic) IBOutlet UIImageView *twitterImage;
@property (weak, nonatomic) IBOutlet UIButton *btnFbLinkToOwnWall;

- (void)searchContactsFor:(NSString *)string;
- (void)fillContactsArray;
- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView;
- (void)handleImageTap:(UITapGestureRecognizer *)sender;

- (void)handleGoogleURL:(NSURL *)url;
- (IBAction)googleSignIn:(id)sender;
- (IBAction)googleSignOut:(id)sender;
- (IBAction)googleRefreshContacts:(id)sender;
- (IBAction)googleClearContacts:(id)sender;
- (IBAction)googleSendEmail:(id)sender;
- (IBAction)googleShortenURL:(id)sender;

- (void)handleFacebookURL:(NSURL *)url;
- (IBAction)facebookSignIn:(id)sender;
- (IBAction)facebookSignOut:(id)sender;
- (IBAction)facebookRefreshContacts:(id)sender;
- (IBAction)facebookClearContacts:(id)sender;
- (IBAction)facebookPostToUsersWall:(id)sender;
- (IBAction)facebookPostToFriendsWall:(id)sender;
- (IBAction)facebookImageToUsersWall:(id)sender;
- (IBAction)facebookImageToFriendsWall:(id)sender;
- (IBAction)facebookLinkToOwnWall:(id)sender;

- (void)handleATTURL:(NSURL *)url;
- (IBAction)attSignIn:(id)sender;
- (IBAction)attSignOut:(id)sender;
- (IBAction)attSendSMS:(id)sender;
- (IBAction)attSendMMS:(id)sender;

- (void)handleTwitterURL:(NSURL *)url;
- (IBAction)twitterSignIn:(id)sender;
- (IBAction)twitterSignOut:(id)sender;
- (IBAction)twitterSendTweet:(id)sender;
- (IBAction)twitterSendImage:(id)sender;
- (IBAction)twitterHomeTimeline:(id)sender;
- (IBAction)twitterUserTimeline:(id)sender;
- (IBAction)twitterSearch:(id)sender;
- (IBAction)twitterStartStreaming:(id)sender;
- (IBAction)twitterStopStreaming:(id)sender;

- (IBAction)roviGetMedia:(id)sender;
- (IBAction)showYouTube:(id)sender;
- (IBAction)showIMDB:(id)sender;
- (IBAction)showBing:(id)sender;
- (IBAction)showBoards:(id)sender;

- (IBAction)resolveURL:(id)sender;

- (IBAction)viewTapped:(id)sender;

@end

//
//  ViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 20/07/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "MainViewController.h"
//#import "BingViewController.h"
//#import "IMDBViewController.h"
//#import "RoviViewController.h"
#import "YouTubeViewController.h"
#import "BoardsViewController.h"
#import "ORSyncFlowEngine.h"

@interface MainViewController () <ORGoogleEngineDelegate, ORFacebookEngineDelegate, ORATTEngineDelegate, ORTwitterEngineDelegate>

@property (nonatomic, strong) ORGoogleEngine *googleEngine;
@property (nonatomic, strong) ORFacebookEngine *facebookEngine;
@property (nonatomic, strong) ORATTEngine *attEngine;
@property (nonatomic, strong) ORTwitterEngine *twitterEngine;
@property (nonatomic, strong) ORURLResolver *urlResolver;
@property (nonatomic, strong) ORContact *contact;
@property (nonatomic, strong) ORSyncFlowEngine *sfe;

@property (nonatomic, strong) NSArray *googleContacts;
@property (nonatomic, strong) NSArray *facebookContacts;
@property (nonatomic, strong) NSMutableArray *allContacts;
@property (nonatomic, strong) NSMutableArray *filteredContacts;
@property (nonatomic, copy) NSString *documentsDirectory;

@property (nonatomic, assign) BOOL isResolvingURLs;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ORApiEngine *apiEngine = [ORApiEngine sharedInstanceWithHostname:@"testapi.orooso.com" portNumber:80 useSSL:NO];
    //ORApiEngine *apiEngine = [ORApiEngine sharedInstanceWithHostname:@"devapi.orooso.com" portNumber:2511 useSSL:NO];
    
    apiEngine.currentUserID = @"f5492f89-a901-4570-a4e2-9724a81dd2ab";
    apiEngine.currentAppCode = @"X";
    
    [apiEngine reauthUserEmail:@"rt1@sharpcube.com" withPwHash:@"<9d09a06e 960fadeb 7439aa32 3d3adb3f c57b5167 3bfe5d4d 20faffdc ec3231b6 bb702a98 2d4d9959 4e39b422 b6facfb9 16d3cfb5 27108b59 5cca8e7b 93b070dd>" cb:^(NSError *error, NSArray *result) {
        NSLog(@"%@", result);
    }];
    
    self.webView.hidden = YES;
    self.googleEngine = [[ORGoogleEngine alloc] initWithDelegate:self];
    self.facebookEngine = [[ORFacebookEngine alloc] initWithDelegate:self];
    self.attEngine = [[ORATTEngine alloc] initWithDelegate:self];
    self.twitterEngine = [ORTwitterEngine sharedInstance];
    self.urlResolver = [ORURLResolver sharedInstance];
    
    self.twitterEngine.delegate = self;
    
    // Check if previously authenticated with Google
    if (self.googleEngine.isAuthenticated) {
        self.googleUser.text = self.googleEngine.userName;
        [self loadImageFromURL:self.googleEngine.profilePicture toImageView:self.googleImage];
    }

    // Check if previously authenticated with Google
    if (self.facebookEngine.isAuthenticated) {
        self.facebookUser.text = self.facebookEngine.userName;
        [self loadImageFromURL:self.facebookEngine.profilePicture toImageView:self.facebookImage];
    }
    
    // Check if previously authenticated with AT&T
    if (self.attEngine.isAuthenticated) {
        self.attUser.text = @"Signed In";
    }
    
    // Check if previously authenticated with Twitter
    if (self.twitterEngine.isAuthenticated) {
        self.twitterUser.text = self.twitterEngine.userName;
        [self loadImageFromURL:self.twitterEngine.profilePicture toImageView:self.twitterImage];
    }
    
    // Get the default Documents path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [paths objectAtIndex:0];
    
    // Refresh the contacts array
    self.googleContacts = nil;
    self.facebookContacts = nil;
    self.contact = nil;
    [self fillContactsArray];
    
    // Add a double tap handler to the images
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imageTap.numberOfTapsRequired = 2;
    self.googleImage.userInteractionEnabled = YES;
    [self.googleImage addGestureRecognizer:imageTap];
    
    imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imageTap.numberOfTapsRequired = 2;
    self.facebookImage.userInteractionEnabled = YES;
    [self.facebookImage addGestureRecognizer:imageTap];
    
    imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imageTap.numberOfTapsRequired = 2;
    self.twitterImage.userInteractionEnabled = YES;
    [self.twitterImage addGestureRecognizer:imageTap];
}

- (void)viewDidUnload
{
    [self setStatusLabel:nil];
    [self setGoogleUser:nil];
    [self setFacebookUser:nil];
    [self setTotalContacts:nil];
    [self setSearchQuery:nil];
    [self setSelectedContact:nil];
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [self setTableView:nil];
    [self setAttUser:nil];
    [self setTwitterUser:nil];
    [self setTwitterImage:nil];
    [self setFacebookImage:nil];
    [self setGoogleImage:nil];
    [self setBtnFbLinkToOwnWall:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    // Unload the cached contacts
    // They will be loaded again when needed
    self.facebookContacts = nil;
    self.googleContacts = nil;
    
    NSLog(@"Memory warning! Contacts cache unloaded");
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    // The cell only shows the contact name
    ORContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
	cell.textLabel.text = contact.name;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ORContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    // Hide the keyboard (if shown)
    [self.searchQuery resignFirstResponder];
    
    // Store the selected contact in the property
    self.contact = contact;
    
    // Show the selected contact name and type
    self.selectedContact.text = [NSString stringWithFormat:@"%@ (%@)", 
                                 contact.name, (contact.type == ORContactTypeGoogle) ? @"Google" : @"Facebook"];
    
    NSLog(@"Selected: %@", contact);
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Get the current query
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    
    [self searchContactsFor:substring];
    
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    // This method is called when the clear button is pressed
    // We just reload all contacts in the table view
    [self searchContactsFor:@""];
    return YES;
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [NSString stringWithFormat:@"%@://%@%@", request.URL.scheme, request.URL.host, request.URL.path];
    
    if ([url isEqualToString:self.facebookEngine.callbackURL]) {
        [self handleFacebookURL:request.URL];
        return NO;
    } else if ([url isEqualToString:self.googleEngine.callbackURL]) {
        [self handleGoogleURL:request.URL];
        return NO;
    } else if ([url isEqualToString:self.attEngine.callbackURL]) {
        [self handleATTURL:request.URL];
        return NO;
    } else if ([url isEqualToString:self.twitterEngine.callbackURL]) {
        [self handleTwitterURL:request.URL];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Facebook auth will sometimes throw the following errors
    // It's safe to ignore them
    if (error.code == NSURLErrorCancelled) return;
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
    
    [self.activityIndicator stopAnimating];
    NSLog(@"Error (UIWebView): %@", [error localizedDescription]);
}

#pragma mark - RSGoogleEngine Delegate Methods

- (void)googleEngine:(ORGoogleEngine *)engine needsToOpenURL:(NSURL *)url
{
    // Uncomment the following block to remove Google cookies from the UIWebView
    // and force the login screen to appear every time
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *googleCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://accounts.google.com"]];
    
    for (NSHTTPCookie *cookie in googleCookies) {
        [cookies deleteCookie:cookie];
    }

    // Clear the webview to avoid flashing the previous page
    [self.view bringSubviewToFront:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    self.webView.hidden = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)googleEngine:(ORGoogleEngine *)engine statusUpdate:(NSString *)message
{
    self.statusLabel.text = message;
    NSLog(@"Google Status: %@", message);
}

#pragma mark - RSFacebookEngine Delegate Methods

- (void)facebookEngine:(ORFacebookEngine *)engine needsToOpenURL:(NSURL *)url
{
    // Uncomment the following block to remove Facebook cookies from the UIWebView
    // and force the login screen to appear every time
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://m.facebook.com"]];

    for (NSHTTPCookie *cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }

    // Clear the webview to avoid flashing the previous page
    [self.view bringSubviewToFront:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    self.webView.hidden = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)facebookEngine:(ORFacebookEngine *)engine statusUpdate:(NSString *)message
{
    self.statusLabel.text = message;
    NSLog(@"Facebook Status: %@", message);
}

#pragma mark - RSATTEngine Delegate Methods

- (void)attEngine:(ORATTEngine *)engine needsToOpenURL:(NSURL *)url
{
    // Clear the webview to avoid flashing the previous page
    [self.view bringSubviewToFront:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    self.webView.hidden = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)attEngine:(ORATTEngine *)engine statusUpdate:(NSString *)message
{
    self.statusLabel.text = message;
    NSLog(@"AT&T Status: %@", message);
}

#pragma mark - RSTwitterEngine Delegate Methods

- (void)twitterEngine:(ORTwitterEngine *)engine needsToOpenURL:(NSURL *)url
{
    // Clear the webview to avoid flashing the previous page
    [self.view bringSubviewToFront:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    self.webView.hidden = NO;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)twitterEngine:(ORTwitterEngine *)engine statusUpdate:(NSString *)message
{
    self.statusLabel.text = message;
    NSLog(@"Twitter Status: %@", message);
}

- (void)twitterEngine:(ORTwitterEngine *)engine newTweet:(ORTweet *)tweet
{
    if (self.isResolvingURLs) {
        for (ORURL *obj in tweet.media) {
            NSLog(@"%@", obj);
        }

        for (ORURL *obj in tweet.urls) {
            NSLog(@"%@", obj);
        }
    } else {
        NSLog(@"\n%@", tweet.debugDescription);
    }
}

#pragma mark - Custom Methods

- (void)searchContactsFor:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        // Empty string just shows all contacts
        self.filteredContacts = [self.allContacts mutableCopy];
    } else {
        [self.filteredContacts removeAllObjects];
        
        // Find all contacts starting with the string
        for (ORContact *contact in self.allContacts) {
            if (contact.name) {
                NSComparisonResult result = [contact.name compare:string options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [string length])];
                
                if (result == NSOrderedSame) {
                    [self.filteredContacts addObject:contact];
                }
            }
        }
    }
    
    // Reload the table view to show the results
    [self.tableView reloadData];
}

- (void)fillContactsArray
{
    if (!self.googleContacts) {
        NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"googleContacts.dat"];

        // Load Google contacts from a previously stored file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            self.googleContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            NSLog(@"Google contacts loaded: %d", [self.googleContacts count]);
        }
    }

    if (!self.facebookContacts) {
        NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"facebookContacts.dat"];
        
        // Load Facebook contacts from a previously stored file
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            self.facebookContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            NSLog(@"Facebook contacts loaded: %d", [self.facebookContacts count]);
        }
    }

    // Join Google and Facebook contacts in one array
    self.allContacts = [NSMutableArray arrayWithCapacity:[self.googleContacts count] + [self.facebookContacts count]];
    [self.allContacts addObjectsFromArray:self.googleContacts];
    [self.allContacts addObjectsFromArray:self.facebookContacts];
    
    // Sort the contacts alphabetically
    [self.allContacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ORContact *contact1 = obj1;
        ORContact *contact2 = obj2;
        
        NSComparisonResult comparison = [contact1.name localizedCaseInsensitiveCompare:contact2.name];
        return comparison;
    }];
    
    // Clear any previous search query and reload the table view
    self.totalContacts.text = [NSString stringWithFormat:@"%d", [self.allContacts count]];
    self.filteredContacts = [self.allContacts mutableCopy];
    self.searchQuery.text = @"";
    [self.tableView reloadData];
}

- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView
{
    if (url == nil) {
        imageView.image = nil;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"Loading image from URL: %@", url);
        
        NSURL *nsurl = [NSURL URLWithString:url];
        NSData *data = [NSData dataWithContentsOfURL:nsurl];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (image) {
                imageView.image = image;
            } else {
                imageView.image = nil;
                NSLog(@"Failed to load image.");
            }
        });
    });
}

- (void)handleImageTap:(UITapGestureRecognizer *)sender
{
    UIImageView *view = (UIImageView *)sender.view;
    CGRect theFrame = view.frame;
    UIViewContentMode mode;

    [self.view bringSubviewToFront:view];
    
    if (theFrame.size.width == 48) {
        theFrame = CGRectMake(0, 0, 1024, 768);
        mode = UIViewContentModeCenter;
    } else {
        mode = UIViewContentModeScaleAspectFit;
        if (view == self.googleImage) {
            theFrame = CGRectMake(384, 49, 48, 48);
        } else if (view == self.facebookImage) {
            theFrame = CGRectMake(384, 240, 48, 48);
        } else {
            theFrame = CGRectMake(384, 476, 48, 48);
        }
    }
    
    UIImage *image = view.image;
    view.image = nil;
    
    [UIView animateWithDuration:0.5f animations:^{
        view.frame = theFrame;
    } completion:^(BOOL finished) {
        view.contentMode = mode;
        view.image = image;
    }];
}

#pragma mark - Google Methods

- (void)handleGoogleURL:(NSURL *)url
{
    self.webView.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    if ([url.query hasPrefix:@"error"]) {
        if (self.googleEngine) [self.googleEngine cancelAuthentication];
    } else {
        if (self.googleEngine) [self.googleEngine resumeAuthenticationFlowWithURL:url];
    }
}

- (IBAction)googleSignIn:(id)sender
{
    // Sign out first to clear the previous data
    [self googleSignOut:nil];
    
    [self.googleEngine authenticateWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Google): %@", [error localizedDescription]);
            self.googleUser.text = @"<Not Signed In>";
            self.googleImage.image = nil;
        } else {
            NSLog(@"User is signed in (Google): %@ (%@)", self.googleEngine.userName, self.googleEngine.userEmail);
            self.googleUser.text = self.googleEngine.userName;
            [self loadImageFromURL:self.googleEngine.profilePicture toImageView:self.googleImage];
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)googleSignOut:(id)sender
{
    [self.googleEngine resetOAuthToken];
    self.googleUser.text = @"<Not Signed In>";
    self.googleImage.image = nil;
}

- (IBAction)googleRefreshContacts:(id)sender
{
    if (!self.googleEngine.isAuthenticated) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"You need to Sign In first."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.googleEngine listContactsWithCompletion:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error (Google): %@", [error localizedDescription]);
        } else {
            self.googleContacts = items;
            
            // Store Google contacts in a file
            NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"googleContacts.dat"];
            if ([NSKeyedArchiver archiveRootObject:self.googleContacts toFile:path]) {
                NSLog(@"Google contacts stored: %d", [items count]);
            }

            [self fillContactsArray];
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)googleClearContacts:(id)sender
{
    self.googleContacts = nil;

    // Remove Google contacts file
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"googleContacts.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    [self fillContactsArray];
}

- (IBAction)googleSendEmail:(id)sender
{
    if (!self.contact) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"You need to select a Google contact first."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.contact.type != ORContactTypeGoogle) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"Selected contact is not a Google contact."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    if (!self.contact.email) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"Selected contact doesn't have an e-mail address."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    NSString *toAddress = [NSString stringWithFormat:@"%@ <%@>", self.contact.name, self.contact.email];
    [self.googleEngine sendMessageTo:toAddress subject:@"RSOAuthEngine Test Message" body:@"Hello, world! This is a test message." completion:^(NSError *error) {
        if (error) {
            NSLog(@"E-mail send failed: (%d) %@", error.code, error.localizedDescription);
        } else {
            NSLog(@"E-mail message sent.");
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)googleShortenURL:(id)sender
{
    NSString *url = @"http://www.sharpcube.com";
    
    [self.googleEngine shortenURL:url completion:^(NSError *error, NSString *item) {
        if (error) {
            NSLog(@"Error: (%d) %@", error.code, error.localizedDescription);
        } else {
            NSLog(@"Short URL: %@", item);
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

#pragma mark - Facebook Methods

- (void)handleFacebookURL:(NSURL *)url
{
    self.webView.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    if ([url.query hasPrefix:@"error"]) {
        if (self.facebookEngine) [self.facebookEngine cancelAuthentication];
    } else {
        if (self.facebookEngine) [self.facebookEngine resumeAuthenticationFlowWithURL:url];
    }
}

- (IBAction)facebookSignIn:(id)sender
{
    // Sign out first to clear the previous data
    [self facebookSignOut:nil];
    
    self.facebookEngine.optionalPermissions = @"publish_stream";
    
    [self.facebookEngine authenticateWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
            self.facebookUser.text = @"<Not Signed In>";
            self.facebookImage.image = nil;
        } else {
            NSLog(@"User is signed in (Facebook): %@ (%@)", self.facebookEngine.userName, self.facebookEngine.userID);
            self.facebookUser.text = self.facebookEngine.userName;
            [self loadImageFromURL:self.facebookEngine.profilePicture toImageView:self.facebookImage];
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)facebookSignOut:(id)sender
{
    [self.facebookEngine resetOAuthToken];
    self.facebookUser.text = @"<Not Signed In>";
    self.facebookImage.image = nil;
}

- (IBAction)facebookRefreshContacts:(id)sender
{
    if (!self.facebookEngine.isAuthenticated) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"You need to Sign In first."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.facebookEngine listContactsWithCompletion:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
        } else {
            self.facebookContacts = items;
            
            // Store Facebook contacts in a file
            NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"facebookContacts.dat"];
            if ([NSKeyedArchiver archiveRootObject:self.facebookContacts toFile:path]) {
                NSLog(@"Facebook contacts stored: %d", [items count]);
            }
            
            [self fillContactsArray];
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)facebookClearContacts:(id)sender
{
    self.facebookContacts = nil;

    // Remove Facebook contacts file
    NSString *path = [self.documentsDirectory stringByAppendingPathComponent:@"facebookContacts.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    [self fillContactsArray];
}

- (IBAction)facebookPostToUsersWall:(id)sender
{
    [self.facebookEngine postMessage:@"Hello, world!" withLink:nil andLinkName:nil andCaption:nil andDescription:nil andPictureUrl:nil toWallForUserID:Nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
        } else {
            NSLog(@"Posted to user's wall.");
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)facebookPostToFriendsWall:(id)sender
{
    if (!self.contact) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"You need to select a Facebook contact first."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.contact.type != ORContactTypeFacebook) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacts Autocomplete"
                                                        message:@"Selected contact is not a Facebook contact."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    [self.facebookEngine postMessage:@"Hello, world!" withLink:nil andLinkName:nil andCaption:nil andDescription:nil andPictureUrl:nil toWallForUserID:self.contact.id completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
        } else {
            NSLog(@"Posted to %@'s wall.", self.contact.name);
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)facebookImageToUsersWall:(id)sender
{
    // Load a sample image from the App bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if (!image) {
        NSLog(@"Unable to load image: %@", path);
        return;
    }
    
    [self.facebookEngine postImage:image withMessage:@"Hello, world!" toWallForUserID:nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
        } else {
            NSLog(@"Posted image to user's wall.");
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)facebookImageToFriendsWall:(id)sender
{
    // Load a sample image from the App bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if (!image) {
        NSLog(@"Unable to load image: %@", path);
        return;
    }
    
    [self.facebookEngine postImage:image withMessage:@"Hello, world!" toWallForUserID:self.contact.id completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Facebook): %@", [error localizedDescription]);
        } else {
            NSLog(@"Posted image to %@'s wall.", self.contact.name);
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)facebookLinkToOwnWall:(id)sender {
	[self.facebookEngine postMessage:@"Oy" withLink:@"http://www.orooso.com" andLinkName:@"orooso site" andCaption:@"caption is here" andDescription:@"description is here" andPictureUrl:@"https://s3.amazonaws.com/orooso-static/orlo-128x.png" toWallForUserID:nil completion:^(NSError *error) {
		if (error){
			DLog(@"failure: %@", [error	localizedDescription]);
		} else {
			DLog(@"success");
		}
	}];
}

#pragma mark - AT&T Methods

- (void)handleATTURL:(NSURL *)url
{
    self.webView.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    if ([url.query hasPrefix:@"code"]) {
        if (self.attEngine) [self.attEngine resumeAuthenticationFlowWithURL:url];
    } else {
        if (self.attEngine) [self.attEngine cancelAuthentication];
    }
}

- (IBAction)attSignIn:(id)sender
{
    // Sign out first to clear the previous data
    [self attSignOut:nil];
    
    [self.attEngine authenticateWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (AT&T): %@", [error localizedDescription]);
            self.attUser.text = @"<Not Signed In>";
        } else {
            NSLog(@"User is signed in (AT&T)");
            self.attUser.text = @"Signed In";
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)attSignOut:(id)sender
{
    [self.attEngine resetOAuthToken];
    self.attUser.text = @"<Not Signed In>";
}

- (IBAction)attSendSMS:(id)sender
{
    // Google Voice: 415-237-1934
    NSString *toAddress = @"415-935-1772";
    [self.attEngine sendSMS:@"RSOAuthEngine Test SMS" toNumber:toAddress withCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"SMS send failed: (%d) %@", error.code, error.localizedDescription);
        } else {
            NSLog(@"SMS message sent.");
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)attSendMMS:(id)sender
{
    // Load a sample image from the App bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_small" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];

    // Fill the Message fields
    NSString *to = @"415-374-9247";
    NSString *subject = @"RSOAuthEngine Test Subject (No SMIL Test)";
    NSString *body = @"RSOAuthEngine Test Body (should also have an image)";
    
    [self.attEngine sendMMS:body subject:subject number:to image:image completion:^(NSError *error) {
        if (error) {
            NSLog(@"MMS send failed: (%d) %@", error.code, error.localizedDescription);
        } else {
            NSLog(@"MMS message sent.");
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

#pragma mark - Twitter Methods

- (void)handleTwitterURL:(NSURL *)url
{
    self.webView.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    if ([url.query hasPrefix:@"denied"]) {
        if (self.twitterEngine) [self.twitterEngine cancelAuthentication];
    } else {
        if (self.twitterEngine) [self.twitterEngine resumeAuthenticationFlowWithURL:url];
    }
}

- (IBAction)twitterSignIn:(id)sender
{
    // Sign out first to clear the previous data
    [self twitterSignOut:nil];
    
    [self.twitterEngine authenticateWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Twitter): %@", [error localizedDescription]);
            self.twitterUser.text = @"<Not Signed In>";
            self.twitterImage.image = nil;
        } else {
            NSLog(@"User is signed in (Twitter): %@ (%@)", self.twitterEngine.userName, self.twitterEngine.screenName);
            self.twitterUser.text = self.twitterEngine.userName;
            [self loadImageFromURL:self.twitterEngine.profilePicture toImageView:self.twitterImage];
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)twitterSignOut:(id)sender
{
    [self.twitterEngine resetOAuthToken];
    self.twitterUser.text = @"<Not Signed In>";
    self.twitterImage.image = nil;
}

- (IBAction)twitterSendTweet:(id)sender
{
    // Add a random string to the tweet
    // Otherwise Twitter will complain about "duplicate status" while testing
    NSString *tweet = [NSString stringWithFormat:@"Hello, world! (%ld)", time(NULL)];

    [self.twitterEngine postTweet:tweet completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Twitter): %@", [error localizedDescription]);
        } else {
            NSLog(@"Tweet posted.");
        }
    }];
}

- (IBAction)twitterSendImage:(id)sender
{
    // Load a sample image from the App bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    // Add a random string to the tweet
    // Otherwise Twitter will complain about "duplicate status" while testing
    NSString *tweet = [NSString stringWithFormat:@"Hello, world! (%ld)", time(NULL)];
    
    if (!image) {
        NSLog(@"Unable to load image: %@", path);
        return;
    }
    
    [self.twitterEngine postTweet:tweet withImage:image completion:^(NSError *error) {
        if (error) {
            NSLog(@"Error (Twitter): %@", [error localizedDescription]);
        } else {
            NSLog(@"Image posted on Twitter.");
        }
        
        self.statusLabel.text = @"Idle";
    }];
}

- (IBAction)twitterHomeTimeline:(id)sender
{
    [self.twitterEngine homeTimeline:20 maxID:0 sinceID:0 completion:^(NSError *error, NSArray *tweets) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            for (ORTweet *tweet in tweets) {
                NSLog(@"\n%@", tweet.debugDescription);
            }
        }
    }];
}

- (IBAction)twitterUserTimeline:(id)sender
{
    [self.twitterEngine userTimeline:@"aplusk" count:20 completion:^(NSError *error, NSArray *tweets) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            for (ORTweet *tweet in tweets) {
                NSLog(@"\n%@", tweet.debugDescription);
            }
        }
    }];
}

- (IBAction)twitterSearch:(id)sender
{
    [self.twitterEngine searchTweets:@"#BigBangTheory" count:20 maxID:NSNotFound sinceID:NSNotFound completion:^(NSError *error, NSArray *tweets) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            for (ORTweet *tweet in tweets) {
                NSLog(@"\n%@", tweet.debugDescription);
            }
        }
    }];
}

- (IBAction)twitterStartStreaming:(id)sender
{
    self.isResolvingURLs = NO;
	//@aplusk,@abfoundation
	//new years eve,alias
	NSLog(@"token: %@", self.twitterEngine.token);
	NSLog(@"token secret: %@", self.twitterEngine.tokenSecret);
	NSLog(@"consumer key: %@", self.twitterEngine.consumerKey);
	NSLog(@"consumer secret: %@", self.twitterEngine.consumerSecret);

	[self.twitterEngine startStreamingStatuses:@"#himym" andAccountIds:nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"Streaming finished with error: %@", error);
        } else {
            NSLog(@"Streaming finished successfuly");
        }
    }];
}

- (IBAction)twitterStopStreaming:(id)sender
{
    [self.twitterEngine stopStreaming];
}

#pragma mark - Rovi Methods

- (IBAction)roviGetMedia:(id)sender
{
//    RoviViewController *vc = [[RoviViewController alloc] initWithNibName:nil bundle:nil];
//    self.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)showYouTube:(id)sender
{
    YouTubeViewController *vc = [[YouTubeViewController alloc] initWithNibName:nil bundle:nil];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)showIMDB:(id)sender
{
//    IMDBViewController *vc = [[IMDBViewController alloc] initWithNibName:nil bundle:nil];
//    self.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)showBing:(id)sender
{
//    BingViewController *vc = [[BingViewController alloc] initWithNibName:nil bundle:nil];
//    self.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Other Methods

- (IBAction)resolveURL:(id)sender
{
    NSArray *urls = @[
        @"http://www.google.com",
        @"http://instagram.com/p/SF0KEQDjKy/",
        @"http://instagram.com/p/SF0KEQDjKy",
        @"http://instagram.com/p/SF0KEQDjKy/media",
        @"http://instagram.com/p/SF0KEQDjKy/media/",
        @"http://instagr.am/p/SF0KEQDjKy/",
        @"http://instagram.com/rsieiro",
        @"http://www.youtube.com/watch?v=9bZkp7q19f0",
        @"http://youtu.be/9bZkp7q19f0",
        @"http://t.co/0o6YhMLx",
        @"http://t.co/KXVdOtLE",
        @"pic.twitter.com/nZQZWaFt",
        @"http://yfrog.com/0kratsj",
        @"http://yfrog.com/0u6mcz",
        @"http://twitpic.com/9630pn",
        @"http://andrewharlow.co/post/36748219203",
        @"http://techcrunch.com/2012/11/28/kickstarter-myled-adds-another-led-to-your-iphone/",
        @"http://bit.ly/98ijqJ",
        @"http://www.youtube.com/watch?v=iymz3LtigL8#t=13s",
        @"http://youtu.be/iymz3LtigL8#t=13s",
        @"http://bit.ly/11aWMMx",
        @"http://bit.ly/TcvNXx",
        @"http://mashable.com/2013/02/12/best-of-toy-fair-2013/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+Mashable+%28Mashable%29"
    ];
    
    NSUInteger totalRequests = 0;
    self.isResolvingURLs = YES;

    // Try to resolve with a list of known URLs
    for (NSString *obj in urls) {
        totalRequests++;
        [self.urlResolver resolveURLString:obj completion:^(NSError *error, ORURL *finalURL) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"%@", finalURL);
            }
        }];
    }
    
    NSLog(@"Total Resolver Requests: %d", totalRequests);

    /*
    // Try to resolve URLs from Home Timeline
    [self.twitterEngine homeTimeline:200 maxID:0 sinceID:0 completion:^(NSError *error, NSArray *tweets) {
        for (ORTweet *tweet in tweets) {
            for (ORURL *obj in tweet.media) {
                totalRequests++;
                NSLog(@"%@", obj);
            }
            
            for (ORURL *obj in tweet.urls) {
                totalRequests++;
                [self.urlResolver resolveORURL:obj completion:^(NSError *error, ORURL *finalURL) {
                    if (error) {
                        NSLog(@"Error: %@", error);
                    } else {
                        NSLog(@"%@", finalURL);
                    }
                }];
            }
        }
        
        NSLog(@"Total Resolver Requests: %d", totalRequests);
    }];
    */
    
    /*
    // Try to resolve URLs from Twitter streaming
    [self.twitterEngine startStreamingStatuses:@"justin bieber" completion:^(NSError *error) {
        self.isResolvingURLs = NO;
        if (error) {
            NSLog(@"Streaming finished with error: %@", error);
        } else {
            NSLog(@"Streaming finished successfuly");
        }
    }];
    */
}

- (void)viewTapped:(id)sender
{
}

- (void)showBoards:(id)sender
{
    BoardsViewController *vc = [[BoardsViewController alloc] initWithNibName:nil bundle:nil];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end

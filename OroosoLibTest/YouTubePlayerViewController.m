//
//  YouTubePlayerViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "YouTubePlayerViewController.h"

@interface YouTubePlayerViewController ()

@property (strong, nonatomic) NSURL *videoURL;

@end

@implementation YouTubePlayerViewController

- (id)initWithVideoID:(NSString *)videoID
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        self.videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/embed/%@", videoID]];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.videoURL]];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"URL: %@", request.URL);
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error (UIWebView): %@", [error localizedDescription]);
}

#pragma mark - Custom Methods

- (IBAction)closePlayer:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

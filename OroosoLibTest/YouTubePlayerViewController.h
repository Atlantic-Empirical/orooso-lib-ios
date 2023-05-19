//
//  YouTubePlayerViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface YouTubePlayerViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (id)initWithVideoID:(NSString *)videoID;
- (IBAction)closePlayer:(id)sender;

@end

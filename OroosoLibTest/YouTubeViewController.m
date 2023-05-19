//
//  YouTubeViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "YouTubeViewController.h"
#import "YouTubePlayerViewController.h"

@interface YouTubeViewController ()

@property (strong, nonatomic) ORYouTubeEngine *youtube;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) ORYouTubeVideo *video;

@end

@implementation YouTubeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.youtube = [[ORYouTubeEngine alloc] init];
}

- (void)viewDidUnload
{
    [self setSearchQuery:nil];
    [self setTableView:nil];
    [self setResultsLabel:nil];
    [self setYtTitle:nil];
    [self setYtAuthor:nil];
    [self setYtCategory:nil];
    [self setYtPublished:nil];
    [self setYtDuration:nil];
    [self setYtDescription:nil];
    [self setYtViews:nil];
    [self setYtFavorites:nil];
    [self setYtLikes:nil];
    [self setYtDislikes:nil];
    [self setYtThumbnail:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
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
    
    ORYouTubeVideo *video = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = video.title;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ORYouTubeVideo *video = [self.items objectAtIndex:indexPath.row];
    self.video = video;
    
    self.ytTitle.text = video.title;
    self.ytAuthor.text = video.author;
    self.ytCategory.text = video.category;
    self.ytPublished.text = [NSString stringWithFormat:@"%@", video.published];
    self.ytDuration.text = [NSString stringWithFormat:@"%@ seconds", video.duration];
    self.ytDescription.text = video.description;
    self.ytViews.text = [NSString stringWithFormat:@"%@", video.views];
    self.ytFavorites.text = [NSString stringWithFormat:@"%@", video.favorites];
    self.ytLikes.text = [NSString stringWithFormat:@"%@", video.likes];
    self.ytDislikes.text = [NSString stringWithFormat:@"%@", video.dislikes];
    
    [self loadImageFromURL:video.thumbnailURL toImageView:self.ytThumbnail];
}

#pragma mark - Custom Methods

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

- (void)showMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)fetchVideos:(id)sender
{
    if ([self.searchQuery.text isEqualToString:@""]) {
        [self showMessage:@"Type a search query first."];
        return;
    }
    
    [self.searchQuery resignFirstResponder];
    
    [self.youtube fetchVideosForString:self.searchQuery.text page:0 count:25 maturityLevel:0 cb:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            self.resultsLabel.text = [NSString stringWithFormat:@"%d Videos found:", [items count]];
            self.items = items;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)playVideo:(id)sender
{
    YouTubePlayerViewController *vc = [[YouTubePlayerViewController alloc] initWithVideoID:self.video.videoID];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

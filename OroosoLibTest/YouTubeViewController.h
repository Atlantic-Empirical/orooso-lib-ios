//
//  YouTubeViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface YouTubeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchQuery;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;

@property (weak, nonatomic) IBOutlet UILabel *ytTitle;
@property (weak, nonatomic) IBOutlet UILabel *ytAuthor;
@property (weak, nonatomic) IBOutlet UILabel *ytCategory;
@property (weak, nonatomic) IBOutlet UILabel *ytPublished;
@property (weak, nonatomic) IBOutlet UILabel *ytDuration;
@property (weak, nonatomic) IBOutlet UITextView *ytDescription;
@property (weak, nonatomic) IBOutlet UILabel *ytViews;
@property (weak, nonatomic) IBOutlet UILabel *ytFavorites;
@property (weak, nonatomic) IBOutlet UILabel *ytLikes;
@property (weak, nonatomic) IBOutlet UILabel *ytDislikes;
@property (weak, nonatomic) IBOutlet UIImageView *ytThumbnail;

- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView;
- (void)showMessage:(NSString *)message;

- (IBAction)fetchVideos:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)goBack:(id)sender;

@end

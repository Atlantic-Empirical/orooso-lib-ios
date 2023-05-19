//
//  BingViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 20/10/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface BingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UILabel *resultsLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView;
- (IBAction)findImages:(id)sender;
- (IBAction)goBack:(id)sender;

@end

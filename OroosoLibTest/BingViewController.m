//
//  BingViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 20/10/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "BingViewController.h"

@interface BingViewController ()

@property (nonatomic, strong) ORBingSearchEngine *bingEngine;
@property (nonatomic, strong) NSArray *tableData;

- (void)handleImageTap:(UITapGestureRecognizer *)sender;
- (void)showMessage:(NSString *)message;

@end

@implementation BingViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bingEngine = [[ORBingSearchEngine alloc] init];
    
    // Add a double tap handler to the image
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imageTap.numberOfTapsRequired = 2;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:imageTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setResultsLabel:nil];
    [self setTableView:nil];
    [self setImageView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    ORBingImageResultItem *item = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", item.Title];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ORBingImageResultItem *item = [self.tableData objectAtIndex:indexPath.row];
    
    [self loadImageFromURL:item.MediaUrl toImageView:self.imageView];
    NSLog(@"Selected: %@", item.MediaUrl);
}

#pragma mark - Custom Methods

- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView
{
    imageView.image = nil;
    if (url == nil) return;
    
    [self.activityIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"Loading image from URL: %@", url);
        
        NSURL *nsurl = [NSURL URLWithString:url];
        NSData *data = [NSData dataWithContentsOfURL:nsurl];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.activityIndicator stopAnimating];
            
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
    
    [self.view bringSubviewToFront:view];
    [self.view bringSubviewToFront:self.activityIndicator];
    
    if (theFrame.size.width == 494) {
        theFrame = CGRectMake(0, 0, 1024, 768);
    } else {
        theFrame = CGRectMake(510, 152, 494, 443);
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        view.frame = theFrame;
    }];
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

- (IBAction)findImages:(id)sender
{
    [self.searchField resignFirstResponder];
    
    [self.bingEngine getImagesForString:self.searchField.text count:@"20" filters:nil cb:^(NSError *error, NSMutableArray *imageResultItems) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!imageResultItems || [imageResultItems count] == 0) {
                [self showMessage:@"No results found"];
                return;
            }
            
            self.resultsLabel.text = [NSString stringWithFormat:@"%d Images found:", [imageResultItems count]];
            self.tableData = imageResultItems;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

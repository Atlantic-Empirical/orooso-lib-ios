//
//  RoviViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 25/08/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface RoviViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UILabel *selectedTitle;
@property (weak, nonatomic) IBOutlet UILabel *selectedPerson;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *synopsisField;
@property (weak, nonatomic) IBOutlet UITextField *resultCount;

- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView;
- (void)showMessage:(NSString *)message;

- (IBAction)performAutocomplete:(id)sender;
- (IBAction)matchTitles:(id)sender;
- (IBAction)findTitle:(id)sender;
- (IBAction)matchPeople:(id)sender;
- (IBAction)findPerson:(id)sender;
- (IBAction)fetchCrew:(id)sender;
- (IBAction)fetchCast:(id)sender;
- (IBAction)fetchFilmography:(id)sender;
- (IBAction)fetchSynopsis:(id)sender;
- (IBAction)fetchBio:(id)sender;
- (IBAction)fetchTwitter:(id)sender;
- (IBAction)titleImage:(id)sender;
- (IBAction)personImage:(id)sender;
- (IBAction)getMedia:(id)sender;
- (IBAction)personImages:(id)sender;
- (IBAction)goBack:(id)sender;

@end

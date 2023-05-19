//
//  RoviViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 25/08/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "RoviViewController.h"

typedef enum _ORDataType
{
    ORDataString,
    ORDataRoviMovie,
    ORDataRoviTVShow,
    ORDataRoviPerson,
    ORDataRoviCrew,
    ORDataRoviCast,
    ORDataRoviImage
}
ORDataType;


@interface RoviViewController ()

@property (strong, nonatomic) ORRoviController *rovi;
@property (assign, nonatomic) ORDataType tableDataType;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) ORRoviTitle *titleObj;
@property (strong, nonatomic) ORRoviPerson *personObj;

- (void)handleImageTap:(UITapGestureRecognizer *)sender;

@end

@implementation RoviViewController
@synthesize selectedTitle = _selectedTitle;
@synthesize selectedPerson = _selectedPerson;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rovi = [[ORRoviController alloc] init];
    self.tableDataType = ORDataString;
    
    // Add a double tap handler to the image
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imageTap.numberOfTapsRequired = 2;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:imageTap];
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setTableView:nil];
    [self setStatusLabel:nil];
    [self setImageView:nil];
    [self setActivityIndicator:nil];
    [self setSynopsisField:nil];
    [self setResultCount:nil];
    [self setSelectedPerson:nil];
    [self setSelectedTitle:nil];
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
    
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    switch (self.tableDataType) {
        case ORDataString: {
            NSString *text = [self.tableData objectAtIndex:indexPath.row];
            cell.textLabel.text = text;

            break;
        }
        case ORDataRoviMovie:
        case ORDataRoviTVShow: {
            ORRoviTitle *data = [self.tableData objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) [%@]", data.name, data.releaseYear, data.typeDescription];

            break;
        }
        case ORDataRoviPerson: {
            ORRoviPerson *data = [self.tableData objectAtIndex:indexPath.row];
            cell.textLabel.text = data.name;
            
            break;
        }
        case ORDataRoviCrew:
        case ORDataRoviCast: {
            ORRoviPerson *data = [self.tableData objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", data.name, data.role];
            
            break;
        }
        case ORDataRoviImage: {
            ORRoviImage *data = [self.tableData objectAtIndex:indexPath.row];
            
            if (data.imageType != nil) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@ x %@)", data.imageType, data.width, data.height];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ x %@ (Format: %@)", data.width, data.height, data.formatId];
            }
            
            break;
        }
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.tableDataType) {
        case ORDataString: {
            NSString *str = [[self.tableData objectAtIndex:indexPath.row] precomposedStringWithCompatibilityMapping];
            self.searchField.text = str;
    
            NSLog(@"Autocomplete result selected: %@", str);
            break;
        }
        case ORDataRoviMovie:
        case ORDataRoviTVShow: {
            ORRoviTitle *data = [self.tableData objectAtIndex:indexPath.row];
            self.selectedTitle.text = [NSString stringWithFormat:@"%@ [%@]", data.name, data.typeDescription];;
            self.titleObj = data;
            
            NSLog(@"Title result selected: %@ (%@)", data.name, data.cosmoId);
            break;
        }
        case ORDataRoviPerson: {
            ORRoviPerson *data = [self.tableData objectAtIndex:indexPath.row];
            self.selectedPerson.text = [NSString stringWithFormat:@"%@", data.name];;
            self.personObj = data;
            
            NSLog(@"Person result selected: %@ (%@)", data.name, data.cosmoId);
            break;
        }
        case ORDataRoviCrew: {
            ORRoviPerson *data = [self.tableData objectAtIndex:indexPath.row];
            self.selectedPerson.text = [NSString stringWithFormat:@"%@ (Crew)", data.name];;
            self.personObj = data;
            
            NSLog(@"Crew Member Selected: %@ (%@)", data.name, data.amgId);
            break;
        }
        case ORDataRoviCast: {
            ORRoviPerson *data = [self.tableData objectAtIndex:indexPath.row];
            self.selectedPerson.text = [NSString stringWithFormat:@"%@ (Cast)", data.name];;
            self.personObj = data;
            
            NSLog(@"Cast Member Selected: %@ (%@)", data.name, data.amgId);
            break;
        }
        case ORDataRoviImage: {
            ORRoviImage *data = [self.tableData objectAtIndex:indexPath.row];
            [self loadImageFromURL:data.mediaUrl toImageView:self.imageView];
            
            NSLog(@"Image selected: %@ x %@ (%@)", data.width, data.height, data.formatId);
            break;
        }
    }
}

#pragma mark - Custom Methods

- (void)loadImageFromURL:(NSString *)url toImageView:(UIImageView *)imageView
{
    if (url == nil) {
        imageView.image = nil;
        return;
    }
    
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

- (void)showMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleImageTap:(UITapGestureRecognizer *)sender
{
    UIImageView *view = (UIImageView *)sender.view;
    CGRect theFrame = view.frame;
    UIViewContentMode mode;
    
    [self.view bringSubviewToFront:view];
    [self.view bringSubviewToFront:self.activityIndicator];
    
    if (theFrame.size.width == 320) {
        theFrame = CGRectMake(0, 0, 1024, 768);
        mode = UIViewContentModeCenter;
    } else {
        mode = UIViewContentModeScaleAspectFit;
        theFrame = CGRectMake(597, 443, 320, 240);
    }
    
    UIImage *image = view.image;
    view.image = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        view.frame = theFrame;
    } completion:^(BOOL finished) {
        view.contentMode = mode;
        view.image = image;
    }];
}

- (IBAction)performAutocomplete:(id)sender
{
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi autocompleteTitlesForString:self.searchField.text cb:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!items) {
                [self showMessage:@"No autocomplete results found"];
                return;
            }
            
            self.statusLabel.text = [NSString stringWithFormat:@"%d Titles found:", [items count]];
            self.tableDataType = ORDataString;
            self.tableData = items;
            [self.tableView reloadData];
            
            // Uncomment the following block to try matching the results against "titleWithString"
            // Will probably exceed dev quota because of the number of simultaneous requests
            
            /*
            for (NSString *theTitle in items) {
                [self.rovi titleWithString:[theTitle precomposedStringWithCompatibilityMapping] cb:^(NSError *error, ORRoviTitle *title) {
                    if (error) {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    } else {
                        if ([title.name isEqualToString:[theTitle precomposedStringWithCompatibilityMapping]]) {
                            NSLog(@"Match: %@", title.name);
                        } else {
                            NSLog(@"No Match: %@ | %@", title.name, theTitle);
                        }
                    }
                }];
            }
            */
        }
    }];
}

- (IBAction)matchTitles:(id)sender
{
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi titlesWithString:self.searchField.text cb:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!items) {
                [self showMessage:@"No Titles found"];
                return;
            }
            
            self.statusLabel.text = [NSString stringWithFormat:@"%d Titles found:", [items count]];
            self.tableDataType = ORDataRoviMovie;
            self.tableData = items;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)findTitle:(id)sender
{
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi titleWithString:self.searchField.text cb:^(NSError *error, ORRoviTitle *title) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!title) {
                [self showMessage:@"No Titles found"];
                return;
            }
            
            self.selectedTitle.text = [NSString stringWithFormat:@"%@ [%@]", title.name, title.typeDescription];;
            self.titleObj = title;
            
            NSLog(@"Title result selected: %@ (%@)", title.name, title.cosmoId);
        }
    }];
}

- (IBAction)matchPeople:(id)sender
{
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi personsWithString:self.searchField.text cb:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!items) {
                [self showMessage:@"No Persons found"];
                return;
            }
            
            self.statusLabel.text = [NSString stringWithFormat:@"%d Persons found:", [items count]];
            self.tableDataType = ORDataRoviPerson;
            self.tableData = items;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)findPerson:(id)sender
{
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi personWithString:self.searchField.text cb:^(NSError *error, ORRoviPerson *person) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!person) {
                [self showMessage:@"No Persons found"];
                return;
            }
            
            self.selectedPerson.text = [NSString stringWithFormat:@"%@", person.name];;
            self.personObj = person;
            
            NSLog(@"Person result selected: %@ (%@)", person.name, person.cosmoId);
        }
    }];
}

- (IBAction)fetchCrew:(id)sender
{
    if (!self.titleObj) {
        [self showMessage:@"Select a Movie/TV Show first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadCrewForTitle:self.titleObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.titleObj.crew) {
                [self showMessage:@"No Crew Members found"];
                return;
            }

            self.statusLabel.text = [NSString stringWithFormat:@"%d Crew Members found:", [self.titleObj.crew count]];
            self.tableDataType = ORDataRoviCrew;
            self.tableData = self.titleObj.crew;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)fetchCast:(id)sender
{
    if (!self.titleObj) {
        [self showMessage:@"Select a Movie/TV Show first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadCastForTitle:self.titleObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.titleObj.cast) {
                [self showMessage:@"No Cast Members found"];
                return;
            }
            
            self.statusLabel.text = [NSString stringWithFormat:@"%d Cast Members found:", [self.titleObj.cast count]];
            self.tableDataType = ORDataRoviCast;
            self.tableData = self.titleObj.cast;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)fetchFilmography:(id)sender
{
    if (!self.personObj) {
        [self showMessage:@"Select a Person first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadFilmographyForPerson:self.personObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.personObj.filmography) {
                [self showMessage:@"No Titles found"];
                return;
            }
            
            self.statusLabel.text = [NSString stringWithFormat:@"%d Titles found:", [self.personObj.filmography count]];
            self.tableDataType = ORDataRoviMovie;
            self.tableData = self.personObj.filmography;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)fetchSynopsis:(id)sender
{
    if (!self.titleObj) {
        [self showMessage:@"Select a Movie/TV Show first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadSynopsisForTitle:self.titleObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.titleObj.synopsis) {
                [self showMessage:@"No Synopsis found"];
                return;
            }

            self.synopsisField.text = self.titleObj.synopsis;
        }
    }];
}

- (IBAction)fetchBio:(id)sender
{
    if (!self.personObj) {
        [self showMessage:@"Select a Person first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadBioForPerson:self.personObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.personObj.bio) {
                [self showMessage:@"No Bio found"];
                return;
            }
            
            self.synopsisField.text = self.personObj.bio;
        }
    }];
}

- (IBAction)fetchTwitter:(id)sender
{
    if (!self.personObj) {
        [self showMessage:@"Select a Person first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadTwitterForPerson:self.personObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.personObj.twitter) {
                [self showMessage:@"No Twitter found"];
                return;
            }
            
            [self showMessage:[NSString stringWithFormat:@"%@'s Twitter: @%@", self.personObj.name, self.personObj.twitter]];
        }
    }];
}

- (IBAction)titleImage:(id)sender
{
    if (!self.titleObj) {
        [self showMessage:@"Select a Movie/TV Show first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadMainImageForTitle:self.titleObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.titleObj.mainImage) {
                [self showMessage:@"No Images found"];
                return;
            } else {
                [self loadImageFromURL:self.titleObj.mainImage.mediaUrl toImageView:self.imageView];
            }
        }
    }];
}

- (IBAction)personImage:(id)sender
{
    if (!self.personObj) {
        [self showMessage:@"Select a Person first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadMainImageForPerson:self.personObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.personObj.mainImage) {
                [self showMessage:@"No Images found"];
                return;
            } else {
                [self loadImageFromURL:self.personObj.mainImage.mediaUrl toImageView:self.imageView];
            }
        }
    }];
}

- (IBAction)getMedia:(id)sender
{
    if (!self.titleObj) {
        [self showMessage:@"Select a Movie/TV Show first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadOtherImagesForTitle:self.titleObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.titleObj.otherImages) {
                [self showMessage:@"No Images found"];
                return;
            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"%d Images found:", [self.titleObj.otherImages count]];
                self.tableDataType = ORDataRoviImage;
                self.tableData = self.titleObj.otherImages;
                [self.tableView reloadData];
            }
        }
    }];
}

- (IBAction)personImages:(id)sender {
    if (!self.personObj) {
        [self showMessage:@"Select a Person first."];
        return;
    }
    
    [self.searchField resignFirstResponder];
    [self.resultCount resignFirstResponder];
    
    [self.rovi loadOtherImagesForPerson:self.personObj cb:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!self.personObj.otherImages) {
                [self showMessage:@"No Images found"];
                return;
            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"%d Images found:", [self.personObj.otherImages count]];
                self.tableDataType = ORDataRoviImage;
                self.tableData = self.personObj.otherImages;
                [self.tableView reloadData];
            }
        }
    }];
}

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

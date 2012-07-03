//
//  SettingsViewController.m
//  IPGateway
//
//  Created by Meng Shengbin on 2/1/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "SettingsViewController.h"
#import "ToggleSwitchCell.h"

@implementation SettingsViewController

@synthesize backViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
    } else {
        return YES;
    }
}

#pragma mark Actions

- (void) autoLoginToggled:(id)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"autoLogin"];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"autoLogin"];
    }
}


#pragma mark - Table View delegate and data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"styleValue1Cell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"styleValue1Cell"] autorelease];
        }
        [cell.textLabel setText:@"Go to Website"];
        [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
        [cell.detailTextLabel setText:@"http://its.pku.edu.cn"];
        return cell;
    }
    
    static NSString *CellIdentifier = @"ToggleSwitchCell";
    ToggleSwitchCell *cell = (ToggleSwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ToggleSwitchCell"owner:nil options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[ToggleSwitchCell class]])
                cell = (ToggleSwitchCell *)oneObject;
    }
    
    if ([indexPath section] == 0) {
        [[cell label] setText:@"Auto Login"];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"] isEqualToString:@"YES"]){
            [[cell toggle] setOn:YES];
        } else {
            [[cell toggle] setOn:NO];
        }
        [[cell toggle] addTarget:self action:@selector(autoLoginToggled:) forControlEvents:UIControlEventValueChanged];
    } else if ([indexPath section] == 1) {
        //[[cell label] setText:@"Show Warning"];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *footerText = @"";
    if (section == 0) {
        footerText = @"automatically try to login when the app became active";
    } else if (section == 1) {
        //footerText = @"show up a warning message when try to login with Global Access on";
    }
    return footerText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:@"http://its.pku.edu.cn"] autorelease]];
    }
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 1) {
        header = @"More";
    }
	return header;
}



- (IBAction)doneButtonPressed:(id)sender {
    self.view.window.rootViewController = backViewController;
}

@end

//
//  SettingsViewController.m
//  IPGateway
//
//  Created by Meng Shengbin on 2/1/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "SettingsViewController.h"
#import "ToggleSwitchCell.h"
#import "ValuePickerCell.h"

#define SECTION_NUM 4

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

- (void) remindMeToggled:(id)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"remindMe"];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"remindMe"];
    }
}


#pragma mark - Table View delegate and data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUM;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_NUM - 1) {
        return 2;
    }
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == SECTION_NUM - 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"styleValue1Cell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"styleValue1Cell"] autorelease];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:NSLocalizedString(@"goto_website", @"Go to Website")];
            [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
            [cell.detailTextLabel setText:@"http://its.pku.edu.cn"];
        }
        if ([indexPath row] == 1) {
            [cell.textLabel setText:NSLocalizedString(@"support_developer", @"Support Developer")];
            [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
            [cell.detailTextLabel setText:@"shengbin.me"];
        }
        return cell;
    }
    
    if ([indexPath section] == 0) {
        static NSString *CellIdentifier = @"ToggleSwitchCell";
        ToggleSwitchCell *cell = (ToggleSwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ToggleSwitchCell"owner:nil options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[ToggleSwitchCell class]])
                    cell = (ToggleSwitchCell *)oneObject;
        }

        if ([indexPath row] == 0) {
            [[cell label] setText:NSLocalizedString(@"auto_login", @"Auto Login")];
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"] isEqualToString:@"YES"]){
                [[cell toggle] setOn:YES];
            } else {
                [[cell toggle] setOn:NO];
            }
            [[cell toggle] addTarget:self action:@selector(autoLoginToggled:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    
    if ([indexPath section] == 1) {
        static NSString *CellIdentifier = @"ToggleSwitchCell";
        ToggleSwitchCell *cell = (ToggleSwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ToggleSwitchCell"owner:nil options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[ToggleSwitchCell class]])
                    cell = (ToggleSwitchCell *)oneObject;
        }
        
        if ([indexPath row] == 0) {
            [[cell label] setText:NSLocalizedString(@"remind_me", @"Remind Me")];
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"remindMe"] isEqualToString:@"YES"]){
                [[cell toggle] setOn:YES];
            } else {
                [[cell toggle] setOn:NO];
            }
            [[cell toggle] addTarget:self action:@selector(remindMeToggled:) forControlEvents:UIControlEventValueChanged];
        }
        
        return cell;
    }
    
    if ([indexPath section] == 2) {
        static NSString *CellIdentifier = @"ValuePickerCell";
        ValuePickerCell *cell = (ValuePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ValuePickerCell"owner:nil options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[ValuePickerCell class]])
                    cell = (ValuePickerCell *)oneObject;
        }
        
        if ([indexPath row] == 0) {
            [[cell label] setText:@"Period (hours):"];
            [[cell valueLable] setText:[NSString stringWithFormat:@"%.1f",cell.stepper.value]];
        }
        
        return cell;
        
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *footerText = @"";
    if (section == 0) {
        footerText = NSLocalizedString(@"auto_login_explain", @"automatically try to login when the app became active");
    } else if (section == 1) {
        footerText = NSLocalizedString(@"remind_me_explain", @"show a reminder message when you turn Global Access on");
    } else if (section == 2) {
        footerText = NSLocalizedString(@"notification_period_explain", @"notify you to turn off the Glabal Access after a period of time");
    }
    return footerText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == SECTION_NUM - 1) {
        if ([indexPath row] == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:@"http://its.pku.edu.cn"] autorelease]];
        }
        if ([indexPath row] == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:@"http://www.shengbin.me/apps/ipgateway"] autorelease]];
        }
    }
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == SECTION_NUM - 1) {
        header = NSLocalizedString(@"more", @"More");
    }
	return header;
}



- (IBAction)doneButtonPressed:(id)sender {
    self.view.window.rootViewController = backViewController;
    
}

@end

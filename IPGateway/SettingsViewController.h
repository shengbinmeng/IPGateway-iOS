//
//  SettingsViewController.h
//  IPGateway
//
//  Created by Meng Shengbin on 2/1/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UIViewController *backViewController;

- (IBAction)doneButtonPressed:(id)sender;

@end

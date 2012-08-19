//
//  IPGWViewController.h
//  IPGateway
//
//  Created by Meng Shengbin on 1/5/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPGWViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate> 

@property (nonatomic, retain) IBOutlet UITextField *useridTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UISwitch *globalSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *rememberSwitch;
@property (nonatomic, retain) IBOutlet UIButton *loginButton, *logoutButton;
@property (nonatomic, retain) IBOutlet UITextView *messageTextView;

- (IBAction) loginButtonPressed :(id)sender;
- (IBAction) logoutButtonPressed :(id)sender;
- (IBAction) switchValueChanged :(id)sender;
- (IBAction) logoutButtonDragOut:(id)sender;

- (IBAction) setttingsItemPressed :(id)sender;
- (IBAction) aboutItemPressed :(id)sender;


@end

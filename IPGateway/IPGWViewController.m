//
//  IPGWViewController.m
//  IPGateway
//
//  Created by Meng Shengbin on 1/5/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "IPGWViewController.h"
#import "SettingsViewController.h"

@implementation IPGWViewController {
    NSMutableData *receivedData1;
    NSURLConnection *connection1;
    BOOL firstAppear;
}

@synthesize  useridTextField, passwordTextField, globalSwitch, rememberSwitch;
@synthesize loginButton, logoutButton, messageTextView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    firstAppear = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(firstAppear) {
        [logoutButton setEnabled:NO];
        [useridTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"rememberedUser"]];
        [passwordTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"rememberedPwd"]];
    }
    else firstAppear = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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


- (NSString*) findItem:(NSString *) item ofInfomation:(NSString*) information {
    NSString *infoItem = @"unknown";
    if ([item isEqualToString:@"BALANCE"]) {
        NSRange range1 = [information rangeOfString:@"BALANCE="];
        NSRange range2 = [information rangeOfString:@"IP="];
        infoItem = [information substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - (range1.location + range1.length))];
    } else if ([item isEqualToString:@"IP"]) {
        NSRange range1 = [information rangeOfString:@"IP="];
        NSRange range2 = [information rangeOfString:@"MESSAGE="];
        infoItem = [information substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - (range1.location + range1.length))];
    }
        
    return infoItem;
}

#pragma mark - User interface

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (IBAction) switchValueChanged :(id)sender
{
    if (sender == globalSwitch && [sender isOn]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"reminder_alert_title",@"Reminder") 
                              message:NSLocalizedString(@"reminder_alert_message",@"Global access may need extra cost, please remember to logout when finish using.")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"reminder_alert_cancel", @"Of course I will")
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)logoutButtonDragOut:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"egg1_alert_title",@"Egg #1")
                          message:NSLocalizedString(@"egg1_alert_message",@"Dedicated to CuiCui, my love.")
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"egg1_alert_cancel", @"Well")
                          otherButtonTitles:NSLocalizedString(@"egg1_alert_others1", @"Bless"), nil];
    [alert show];
    [alert release];
}

/*
 https://its.pku.edu.cn:5428/ipgatewayofpku?uid=1101111141&password=pas&operation=connect&range=2&timeout=2
 
 operation: connect, disconnect, disconnectall
 range: 1(fee), 2(free)
 
 */

- (void) loginButtonPressed:(id)sender
{
    [useridTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [messageTextView setText:NSLocalizedString(@"logging_in", @"logging in ...")];

    NSString *errorMessage = nil;
    if ([[[self useridTextField] text] isEqualToString:@""]) {
        errorMessage = NSLocalizedString(@"no_username", @"user ID required! - Please input.");
    } else if ([[[self passwordTextField] text] isEqualToString:@""]) {
        errorMessage = NSLocalizedString(@"no_password", @"password required! - Please input.");
    }
    
    if (errorMessage) {
        [messageTextView setText:errorMessage];
        return;
    }
    
    if ([logoutButton isEnabled]) {
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://its.pku.edu.cn:5428/ipgatewayofpku?uid=%@&password=%@&operation=disconnect&range=%d&timeout=3", [[self useridTextField] text], [[self passwordTextField] text], 2]]];  
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:15];
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
    
    int range = 2; //2 for free
    if ([globalSwitch isOn]) {
        range = 1; //1 for fee; can't be others
    }
    NSString *requestString = [NSString stringWithFormat:@"https://its.pku.edu.cn:5428/ipgatewayofpku?uid=%@&password=%@&operation=connect&range=%d&timeout=3", [[self useridTextField] text], [[self passwordTextField] text], range];
#ifdef DEBUG
    NSLog(@"%@", requestString);
#endif
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:requestString]];  
    [request setHTTPMethod:@"GET"]; 
    [request setTimeoutInterval:45];
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection1) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData1 = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
        [messageTextView setText:NSLocalizedString(@"connection_init_failed", @"connection init failed! It's terrible.")];
    }
}

- (void) logoutButtonPressed:(id)sender
{
    [messageTextView setText:NSLocalizedString(@"logging_out", @"logging out ...")];

    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://its.pku.edu.cn:5428/ipgatewayofpku?uid=%@&password=%@&operation=disconnect&range=%d&timeout=3", [[self useridTextField] text], [[self passwordTextField] text], 2]]];  
    [request setHTTPMethod:@"GET"]; 
    [request setTimeoutInterval:15];
    
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *content = [[[NSString alloc] initWithData:returnedData encoding:enc] autorelease];
#ifdef DEBUG
        NSLog(@"***************\n%@",content);
#endif
        NSRange range = [content rangeOfString:@"<!--IPGWCLIENT_START SUCCESS=YES"];
        if(range.length != 0) {
            [messageTextView setText:NSLocalizedString(@"logout_success", @"logout success! - You are offline now.")];
            [logoutButton setEnabled:NO];
            if ([rememberSwitch isOn] == NO) {
                [useridTextField setText:@""];
                [passwordTextField setText:@""];
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"rememberedUser"];
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"rememberedPwd"];
            }
        } else {
            [messageTextView setText:NSLocalizedString(@"something_wrong", @"something wrong! - Sorry."])];
        }
    } else {
        [messageTextView setText:NSLocalizedString(@"something_wrong", @"something wrong! - Sorry."])];
    }
}




#pragma mark - connection delegate
- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
    if (aConn == connection1) {
        [receivedData1 appendData:data];
    }
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [messageTextView  setText:[NSString stringWithFormat:@"%@ - %@",NSLocalizedString(@"connection_failed", @"connection failed!"), [error localizedDescription]]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    if (aConn == connection1) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *content = [[[NSString alloc] initWithData:receivedData1 encoding:enc] autorelease];
        if (content == nil) {
            content = [[NSString alloc] initWithData:receivedData1 encoding:NSUTF8StringEncoding];
        }
#ifdef DEBUG
        NSLog(@"content: ***************\n%@",content);
#endif
        NSRange range1 = [content rangeOfString:@"<!--IPGWCLIENT_START "];
        NSRange range2 = [content rangeOfString:@"IPGWCLIENT_END-->"];
        if(range1.length == 0 || range2.length == 0) {
            [messageTextView setText:NSLocalizedString(@"no_info_returned", @"no information returned! - It is terrible.")];
            return ;
        }

        NSString *information = [content substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - (range1.location + range1.length))];
#ifdef DEBUG
        NSLog(@"information: **************\n%@",information);
#endif
        if([[information substringToIndex:11] isEqualToString:@"SUCCESS=YES"]){
            NSRange range = [content rangeOfString:@"用&nbsp;户&nbsp;名："];
            NSString *name = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 12)];
            name = [name substringToIndex:[name rangeOfString:@"</td>"].location];
            NSString *IP = [self findItem:@"IP" ofInfomation:information];
            NSString *balance = [self findItem:@"BALANCE" ofInfomation:information];
            balance = [balance stringByAppendingString:@" RMB"];
            [messageTextView setText:[NSString stringWithFormat:@"%@ \n\n%@: %@ \n%@: %@ \n%@: %@", NSLocalizedString(@"login_success", @"login success! - You are online now."), NSLocalizedString(@"user_name", @"User Name"),name, NSLocalizedString(@"ip_location", @"IP Location"), IP, NSLocalizedString(@"account_balance", @"Account Balance"), balance]];
            
            if ([rememberSwitch isOn]) {
                [[NSUserDefaults standardUserDefaults] setValue:[[self useridTextField] text] forKey:@"rememberedUser"];
                [[NSUserDefaults standardUserDefaults] setValue:[[self passwordTextField] text] forKey:@"rememberedPwd"];
            }
            [logoutButton setEnabled:YES];
        } else if([[information substringToIndex:10] isEqualToString:@"SUCCESS=NO"]){ 
            NSRange range = [information rangeOfString:@"REASON="];
            NSString *reason = [information substringFromIndex:(range.location + range.length)];
            if ([reason rangeOfString:@"户名错"].length != 0 || [reason rangeOfString:@"口令错误"].length != 0) {
                [messageTextView setText:NSLocalizedString(@"login_failed_user_error", @"login failed! - Username or password error, please check.")];
            } else if ([reason rangeOfString:@"不能登录网关"].length != 0) {
                NSRange range = [reason rangeOfString:@"是服务器"];
                NSString *IP = @"";
                if(range.length != 0) IP = [NSString stringWithFormat:@"<%@>",[reason substringToIndex:range.location]];
                [messageTextView setText:[NSString stringWithFormat:NSLocalizedString(@"login_failed_ip_error", @"login failed! - Your IP address%@ is not in the proper area, can't login to the gateway.") ,IP]];
            } else if ([reason rangeOfString:@"没有访问收费地址的权限"].length != 0) {
                [messageTextView setText: NSLocalizedString(@"login_failed_scope_error", @"login failed! - Your account is only limited to CERNET free IP. Please turn off Global Access or change your settings from http://its.pku.edu.cn.")];
            } else if ([reason rangeOfString:@"连接数超过"].length != 0) {
                UIAlertView *alert = [[UIAlertView alloc] 
                                      initWithTitle:NSLocalizedString(@"max_alert_title",@"Message") 
                                      message:NSLocalizedString(@"max_alert_message",@"You have reached the max connection number. Disconnect all others and connect again?")
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"max_alert_cancel",@"No")
                                      otherButtonTitles:NSLocalizedString(@"max_alert_others1",@"Yes"), nil];
                [alert show];
                [alert release];
            } else {
                [messageTextView setText:NSLocalizedString(@"something_wrong", @"something wrong! - Sorry."])];
            }
        } else {
            [messageTextView setText:NSLocalizedString(@"something_wrong", @"something wrong! - Sorry."])];
        }

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [messageTextView setText:NSLocalizedString(@"login_failed_max_connections", @"login failed! - Max connection number reached.")];
        return;
    } else if(buttonIndex == 1) {
        NSString *requestString = [NSString stringWithFormat:@"https://its.pku.edu.cn:5428/ipgatewayofpku?uid=%@&password=%@&operation=disconnectall&range=%d&timeout=3", [[self useridTextField] text], [[self passwordTextField] text], 2];
#ifdef DEBUG
        NSLog(@"%@", requestString);
#endif
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
        [request setURL:[NSURL URLWithString:requestString]];  
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:15];
        
        NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (returnedData) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *content = [[[NSString alloc] initWithData:returnedData encoding:enc] autorelease];
#ifdef DEBUG
            NSLog(@"***************\n%@",content);
#endif
            NSRange range = [content rangeOfString:@"<!--IPGWCLIENT_START SUCCESS=YES"];
            if(range.length != 0) {
                 [messageTextView setText:NSLocalizedString(@"close_others_success", @"close other connections success! - re connectting...")];
                sleep(1);
                [self loginButtonPressed:nil];
            } else {
                [messageTextView setText:NSLocalizedString(@"close_others_failed", @"close other connections failed! - Sorry.")];
            }
        } else {
            [messageTextView setText:NSLocalizedString(@"close_others_failed", @"close other connections failed! - Sorry.")];
        }
    }

}




- (IBAction) aboutItemPressed :(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:NSLocalizedString(@"about_alert_title", @"About IPGateway") 
                          message:NSLocalizedString(@"about_alert_message", @"This is a free app for logging into the IP gateway of PKU. Suggestions and bug reports can be sent to: shengbinmeng@gmail.com.")
                          delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"about_alert_others1",@"OK"), nil];
    [alert show];
    [alert release];
}

- (IBAction) setttingsItemPressed :(id)sender
{
    SettingsViewController *svc = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] autorelease];
    svc.backViewController = self.view.window.rootViewController;
    self.view.window.rootViewController = svc;
    firstAppear = NO;
}

@end

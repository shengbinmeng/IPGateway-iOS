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
    NSString *username;
    NSString *password;
    NSMutableData* receivedData1;
    NSURLConnection * connection1;
    NSMutableData* receivedData2;
    NSURLConnection * connection2;
    NSMutableData* receivedData3;
    NSURLConnection * connection3;
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
    [logoutButton setEnabled:NO];
    [useridTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"rememberedUser"]];
    [passwordTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"rememberedPwd"]];
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


#pragma mark - User interface

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (IBAction) switchValueChanged :(id)sender
{
    if (sender == globalSwitch && [sender isOn]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"Message" 
                              message:@"Global access will need extra cost."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Yes", nil];
        //[alert show];
        [alert release];
    }
    
    if (sender == rememberSwitch && [sender isOn] == NO) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"rememberedUser"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"rememberedPwd"];
    }
}

- (void) loginButtonPressed:(id)sender
{
    [useridTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [messageTextView setText:@"logging in ..."];
    
    username = [[self useridTextField] text];
    password = [[self passwordTextField] text];
    if (username == nil) username = @"";
    if (password == nil) password = @"";

    NSString *errorMessage = nil;
    if ([username isEqualToString:@""]) {
        errorMessage = @"user ID required! - Please input.";
    } else if ([password isEqualToString:@""]) {
        errorMessage = @"password required! - Please input.";
    }
    
    if (errorMessage) {
        [messageTextView setText:errorMessage];
        return;
    }
    
    if ([logoutButton isEnabled]) {
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
        [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/shutdown"]];  
        [request setHTTPMethod:@"GET"]; 
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/"]];  
    [request setHTTPMethod:@"GET"]; 
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection1) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData1 = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
        [messageTextView setText:@"connection init failed !"];
    }
}

- (void) logoutButtonPressed:(id)sender
{
    [messageTextView setText:@"logging out ..."];

    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
    [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/shutdown"]];  
    [request setHTTPMethod:@"GET"]; 

    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSString *content = [[[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG
        NSLog(@"***************\n%@",content);
#endif
        NSRange range = [content rangeOfString:@"top.location.replace"];
        if(range.length != 0) {
            [messageTextView setText:@"logout success! - You are offline now."];
            [logoutButton setEnabled:NO];
            if ([rememberSwitch isOn] == NO) {
                [useridTextField setText:@""];
                [passwordTextField setText:@""];
            }
        }
    } else {
        [messageTextView setText:@"somethin wrong! - Sorry."];
    }
}



#pragma mark - connection delegate

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)aResponse
{
    if(aConn == connection2) {
        NSDictionary *headers = [(NSHTTPURLResponse*)aResponse allHeaderFields];
        NSString *location = [headers valueForKey:@"Location"];
        //NSLog(@"%@", [headers description]);
        if (location) {
            [messageTextView setText:location];
        } else {
            //[messageTextView setText:@"error"];
        }
    }
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
    if (aConn == connection1) {
        [receivedData1 appendData:data];
    } else if (aConn == connection2) {
        [receivedData2 appendData:data];
    } else if (aConn == connection3) {
        [receivedData3 appendData:data];
    }
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [messageTextView  setText:[NSString stringWithFormat:@"connection failed! - %@", [error localizedDescription]]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    if (aConn == connection1) {
        NSString *lt = nil;
        
        NSString *content = [[[NSString alloc] initWithData:receivedData1 encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"content of connection1: \n%@", content);
        NSRange range = [content rangeOfString:@"<input type=\"hidden\" name=\"lt\" value=\""];
        if(range.length != 0)
            lt = [content substringWithRange:NSMakeRange(range.location + range.length, 36)];
        //NSLog(@"lt:%@",lt);
        
        NSString *fwrd = @"free";
        NSString *tail = @"12";
        if ([globalSwitch isOn]) {
            fwrd = @"fee";
            tail = @"11";
        }
        
        NSString *postContent = [[NSString alloc] initWithFormat:@"username1=%@&password=%@&pwd_t=%%E5%%AF%%86%%E7%%A0%%81&fwrd=%@&lt=%@&_currentStateId=viewLoginForm&_eventId=submit&username=%@%%7C%%3BkiDrqvfi7d%%24v0p5Fg72Vwbv2%%3B%%7C%@%%7C%%3BkiDrqvfi7d%%24v0p5Fg72Vwbv2%%3B%%7C%@",username,password,fwrd,lt,username,password,tail];
        //NSLog(@"postContent: %@", postContent);
        NSData *postData = [postContent dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]]; 
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
        [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/cas/login?service=https%3A%2F%2Fits.pku.edu.cn%2Fnetportal%2F"]];  
        [request setHTTPMethod:@"POST"]; 
        [request setValue:@"its.pku.edu.cn" forHTTPHeaderField:@"Host"];
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:@"https://its.pku.edu.cn/cas/login?service=https%3A%2F%2Fits.pku.edu.cn%2Fnetportal%2F" forHTTPHeaderField:@"Referer"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
        
        [request setHTTPBody:postData]; 
        
        // create the connection with the request
        // and start loading the data
        connection2 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection2) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            receivedData2 = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            [messageTextView setText:@"connection init failed!"];
        }
        [postContent release]; 

    } 
    else if (aConn == connection2) {
        NSString *content = [[[NSString alloc] initWithData:receivedData2 encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG
        NSLog(@"***************\n%@",content);
#endif
        NSRange range = [content rangeOfString:@"【用户名】或【密码】错误！"];
        if(range.length != 0) {
            [messageTextView setText:@"login failed! - Username or password error, please check."];
            return ;
        }
        
        [logoutButton setEnabled:YES];

        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
        if ([globalSwitch isOn]) {
            [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/ipgwopenall"]];  
        } else {
            [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/ipgwopen"]];  
        }
        
        [request setHTTPMethod:@"GET"]; 
        
        connection3 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection3) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            receivedData3 = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
            [messageTextView setText:@"connection init failed!"];
        }
    }
    else if (aConn == connection3) {
        NSString *content = [[[NSString alloc] initWithData:receivedData3 encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG
        NSLog(@"**************\n%@",content);
#endif
        if([content rangeOfString:@"网络连接成功"].length != 0){
            
            NSRange range = [content rangeOfString:@"用&nbsp;户&nbsp;名："];
            NSString *name = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 12)];
            name = [name substringToIndex:[name rangeOfString:@"</td>"].location];
            range = [content rangeOfString:@"当前地址："];
            NSString *IP = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 20)];
            IP = [IP substringToIndex:[IP rangeOfString:@"</td>"].location];
            range = [content rangeOfString:@"账户余额："];
            NSString *balance = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 5)];
            if ([balance isEqualToString:@"<font"]) {
                NSUInteger a = range.location;
                range = [content rangeOfString:@"请及时加款"];
                NSUInteger b = range.location;
                NSString *s = [content substringWithRange:NSMakeRange(a, b-a)];
                range = [s rangeOfString:@"元"];
                balance = [s substringWithRange:NSMakeRange(range.location - 5, 5)];
            }
            balance = [balance stringByAppendingString:@" RMB"];
            
            [messageTextView setText:[NSString stringWithFormat:@"login success! - You are online now. \n\nUser Name: %@ \nIP Location: %@ \nAccount Balance: %@", name,IP,balance]];
            
            if ([rememberSwitch isOn]) {
                [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"rememberedUser"];
                [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"rememberedPwd"];
            }
            [logoutButton setEnabled:YES];
        } else if ([content rangeOfString:@"不能登录网关"].length != 0) {
            [messageTextView setText:@"login failed! - Your IP address is not in the  proper area, can't login to the gateway."];
        } else if ([content rangeOfString:@"达到设定的连接数"].length != 0) {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"Message" 
                                  message:@"You have reached the max connection number. Disconnect all others and connect again?"
                                  delegate:self
                                  cancelButtonTitle:@"No"
                                  otherButtonTitles:@"Yes", nil];
            [alert show];
            [alert release];
        } else if ([content rangeOfString:@"您仅被授权访问免费地址"].length != 0) {
            [messageTextView setText:@"login failed! - Your account is only limited to CERNET free IP. Please turn off Global Access or change your permission from http://its.pku.edu.cn."];
        } else {
            [messageTextView setText:@"something wrong! - Sorry."];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [messageTextView setText:@"login failed! - Max connection number reached."];
        return;
    } else if(buttonIndex == 1) {
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
        [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/ipgwcloseall"]];  
        [request setHTTPMethod:@"GET"]; 
        
        NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (returnedData) {
            NSString *content = [[[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG
            NSLog(@"***************\n%@",content);
#endif
            NSRange range = [content rangeOfString:@"断开全部连接成功"];
            if(range.length != 0) {
                 [messageTextView setText:@"close other connections success! - re connectting..."];
                if ([globalSwitch isOn]) {
                    [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/ipgwopenall"]];
                } else {
                    [request setURL:[NSURL URLWithString:@"https://its.pku.edu.cn/netportal/ipgwopen"]];
                }
                
                returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                content = [[[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG
                NSLog(@"***************\n%@",content);
#endif    
                range = [content rangeOfString:@"网络连接成功"];
                if(range.length != 0) {
                    NSRange range = [content rangeOfString:@"用&nbsp;户&nbsp;名："];
                    NSString *name = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 12)];
                    name = [name substringToIndex:[name rangeOfString:@"</td>"].location];
                    range = [content rangeOfString:@"当前地址："];
                    NSString *IP = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 20)];
                    IP = [IP substringToIndex:[IP rangeOfString:@"</td>"].location];
                    range = [content rangeOfString:@"账户余额："];
                    NSString *balance = [content substringWithRange:NSMakeRange(range.location + range.length + 9, 5)];
                    if ([balance isEqualToString:@"<font"]) {
                        NSUInteger a = range.location;
                        range = [content rangeOfString:@"请及时加款"];
                        NSUInteger b = range.location;
                        NSString *s = [content substringWithRange:NSMakeRange(a, b-a)];
                        range = [s rangeOfString:@"元"];
                        balance = [s substringWithRange:NSMakeRange(range.location - 5, 5)];
                    }
                    balance = [balance stringByAppendingString:@" RMB"];
                    
                    [messageTextView setText:[NSString stringWithFormat:@"login success! - You are online now. \n\nUser Name: %@ \nIP Location: %@ \nAccount Balance: %@", name,IP,balance]];                    
                    
                    if ([rememberSwitch isOn]) {
                        [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"rememberedUser"];
                        [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"rememberedPwd"];
                    [logoutButton setEnabled:YES];
                    }
                } else if ([content rangeOfString:@"您仅被授权访问免费地址"].length != 0) {
                    [messageTextView setText:@"login failed! - You account is limited to CERNET free IP. Please turn off Global Access or change your permission from http://its.pku.edu.cn."];
                } else {
                    [messageTextView setText:@"something wrong! - Sorry."];
                }

            } else {
                [messageTextView setText:@"close other connections failed! - Sorry."];
            }
        } else {
            [messageTextView setText:@"close other connections failed! - Sorry."];
        }
    }

}




- (IBAction) aboutItemPressed :(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: @"About IPGateway" 
                          message:@"This is a free app for logging into the IP gateway of PKU. Suggestions and bug reports can be sent to: shengbinmeng@gmail.com."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction) setttingsItemPressed :(id)sender
{
    SettingsViewController *svc = [[[SettingsViewController alloc] init] autorelease];
    svc.backViewController = self.view.window.rootViewController;
    self.view.window.rootViewController = svc;
}

@end

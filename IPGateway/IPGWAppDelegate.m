//
//  IPGWAppDelegate.m
//  IPGateway
//
//  Created by Meng Shengbin on 1/5/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "IPGWAppDelegate.h"

#import "IPGWViewController.h"

@implementation IPGWAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[IPGWViewController alloc] initWithNibName:@"IPGWViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[IPGWViewController alloc] initWithNibName:@"IPGWViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithDouble:1.0], @"notifyPeriod",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    UILocalNotification * localNotif=[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif != nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"handle_alert_title", @"Information")
                              message:NSLocalizedString(@"handle_alert_body", @"You were notified to turn off Global Access. If Auto Login is anebled, you may be automatically logged in again. Check the status and handle it yourself.")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"dismiss", @"Dismiss")
                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        // Application was in the background when notification
        // was delivered.
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"handle_alert_title", @"Information")
                              message:NSLocalizedString(@"handle_alert_body", @"You were notified to turn off Global Access. If Auto Login is anebled, you may be automatically logged in again. Check the status and handle it yourself.")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"dismiss", @"Dismiss")
                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"handle_alert_title", @"Information")
                              message:NSLocalizedString(@"fg_handle_alert_body", @"You were notified to turn off Global Access. Check the status and handle it yourself.")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"dismiss", @"Dismiss")
                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"autoLogin"] isEqualToString:@"YES"]) {
        [[self viewController] loginButtonPressed:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end

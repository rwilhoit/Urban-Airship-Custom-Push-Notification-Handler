//
//  MyCustomPushHandlerAppDelegate.m
//  MyCustomPushHandler
//
//  Created by Raj Wilhoit on 9/9/13.
//  Copyright (c) 2013 UF.rajwilhoit. All rights reserved.
//

#import "MyCustomPushHandlerAppDelegate.h"
#import "MyCustomPushHandlerViewController.h"
#import "CustomUAPushHandler.h"

@implementation MyCustomPushHandlerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Setup for Urban Airship should go here
    // Set flag in cold start or background
    [CustomUAPushHandler sharedInstance].delegateLock = NO;
    
    // This prevents the UA Library from registering with UIApplcation by default when
    // registerForRemoteNotifications is called. This will allow you to prompt your
    // users at a later time. This gives your app the opportunity to explain the benefits
    // of push or allows users to turn it on explicitly in a settings screen.
    // If you just want everyone to immediately be prompted for push, you can
    // leave this line out.
    [UAPush setDefaultPushEnabledValue:NO];
    
    UAConfig *config = [UAConfig defaultConfig];
    
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    [UAirship takeOff:config];
    
    // Register for remote notfications with the UA Library.
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
    // Set your custom delegate
    [UAPush shared].delegate = [CustomUAPushHandler sharedInstance];
    [[UAPush shared] handleNotification:[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey] applicationState:application.applicationState];
    
    self.viewController = [[MyCustomPushHandlerViewController alloc] initWithNibName:@"MyCustomPushHandlerViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [CustomUAPushHandler sharedInstance].launchedFromColdStart = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Let the custom delegate handler handle the push notification (this is a workaround for a UA bug I encountered)
    [CustomUAPushHandler sharedInstance].delegateLock = YES;
    
    // Set the delegate for push notifications
    [UAPush shared].delegate = [SSDPCustomUAPushNotificationHandler sharedInstance];
    
    // Send the alert to UA so that it can be handled and tracked as a direct response. This call
    // is required.
    [[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
}

@end

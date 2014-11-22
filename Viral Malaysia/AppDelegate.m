//
//  AppDelegate.m
//  Viral Malaysia
//
//  Created by zer0 on 11/12/14.
//  Copyright (c) 2014 afiq. All rights reserved.
//

#import "AppDelegate.h"
#import "HotTableViewController.h"
#import <Parse/Parse.h>
#import "Appirater.h"
#import "HotTableViewController.h"
#import "Reachability.h"

#define APPID @"941954552"

@interface AppDelegate ()
{
    Reachability *internetReachableFoo;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }

    // Set minimum time interval for background data fetch

    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Parse Stuff
    [Parse setApplicationId:@"hfARw9uUNx5idmTmGg7fxAi8OWpAR7Z5mGbsQtw2"
                  clientKey:@"OWuC9wKQs4LRsWZ2bUwfFMfFNGDC0Fw4dBTCCFh3"];
    
    [self appirater];
    
    // Set the view to HotTableViewController when user tapped on remote notification
//    UIStoryboard *ab = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    HotTableViewController *hotTVC = [ab instantiateViewControllerWithIdentifier:@"hotTVC"];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:hotTVC];
//    UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
//    
//    [tabController presentViewController:navController animated:YES completion:nil];
    
    // Reachability : Detect for internet connection.
    
    internetReachableFoo = [Reachability reachabilityWithHostName:@"www.google.com"];
    internetReachableFoo.reachableBlock = ^(Reachability *internetReachableFoo){
        NSLog(@"Network is reachable.");
    };
    
    internetReachableFoo.unreachableBlock = ^(Reachability *internetReachableFoo){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please connect to the internet to make this app working properly. :)" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    };
    
    // Start Monitoring
    [internetReachableFoo startNotifier];
    
    return YES;
}

#pragma mark - Notification Stuff

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
     //NSLog(@"userinfo : %@", userInfo);
    
    // Set the view to HotTableViewController when user tapped on remote notification
    UIStoryboard *ab = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HotTableViewController *hotTVC = [ab instantiateViewControllerWithIdentifier:@"hotTVC"];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
//    tabController.selectedIndex = 0;
    UINavigationController *navigationController = (UINavigationController *)tabController.selectedViewController;
    [navigationController pushViewController:hotTVC animated:YES];
}


#pragma mark - Background Fetch

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIViewController *rootVC = self.window.rootViewController;
    UITabBarController *tabBar = (UITabBarController*)rootVC;
    
    id selectedVC = tabBar.selectedViewController;
    
    if ([selectedVC
         isMemberOfClass:UINavigationController.class]) {
        id topVC = [(UINavigationController*) selectedVC topViewController];
        [(HotTableViewController *)topVC populateHotDataWithCompletionHandler:completionHandler];
    }
    
}

#pragma mark - helper method

-(void) appirater {
    [Appirater setAppId:@"941954552"];
    [Appirater setDaysUntilPrompt:2];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  AppDelegate.m
//  SimplyTea
//
//  Created by Ken Hung on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TeaViewController.h"
#import "Settings.h"
#import "TeaNavigationViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationViewController = _navigationViewController;

- (void)dealloc
{
    [_window release];
    [_navigationViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    [Settings forceDefaultSettings];
    
    NSLog(@"\nTesting Settings");
    NSLog(@"   Portions: %d", [Settings getPortionSetting]);
    NSLog(@"   Temperature: %d", [Settings getTemperatureSetting]);
    NSLog(@"   Start with Favorites: %@", [Settings shouldStartWithFavorites] ? @"YES" : @"NO");
    
    // Override point for customization after application launch.
    TeaNavigationViewController * navigationController = [[[TeaNavigationViewController alloc] initWithRootViewController: [[[TeaViewController alloc] initWithNibName:@"TeaViewController" bundle:nil] autorelease]] autorelease];
    navigationController.toolbarHidden = YES;
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:107.0f/255.0f green: 142.0f/255.0f blue: 35.0/255.0f alpha:0.15f];
    //navigationController.navigationBarHidden = YES;
    
    self.navigationViewController = navigationController;
    [self.window setRootViewController: self.navigationViewController];
    [self.window makeKeyAndVisible];

    [navigationController release];
    
    return YES;
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

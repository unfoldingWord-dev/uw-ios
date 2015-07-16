//
//  AppDelegate.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "AppDelegate.h"
#import "UFWMasterUpdater.h"
#import "UFWMasterUpdater.h"
#import "UFWDataSeeder.h"
#import "UnfoldingWord-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [UFWDataSeeder seedDataIfNecessary];
    return YES;
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    if ([UIApplication sharedApplication].protectedDataAvailable) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        UFWFileImporter *importer = [[UFWFileImporter alloc] initWithData:data];
        BOOL success = [importer importFile];
        if (success == true) {
            NSString *message = [NSString stringWithFormat:@"The app successfully imported \"%@\"", url.path.lastPathComponent];
            [[[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        }
        if (success == false) {
            NSString *message = [NSString stringWithFormat:@"The app failed to import \"%@\"", url.path.lastPathComponent];
            [[[UIAlertView alloc] initWithTitle:@"Failure" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
        }
    }
    
    return YES;
}



@end

//
//  ZMAppDelegate.m
//  ZenmaiExample
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012年 slightair. All rights reserved.
//

#import "ZMAppDelegate.h"
#import "ZMTaskManager.h"

@implementation ZMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ZMTaskManagerTaskFireNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification){
                                                      ZMTask *task = notification.userInfo[ZMTaskManagerNotificationTaskUserInfoKey];
                                                      ZMTask *newTask = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:task.date]
                                                                                            userInfo:@{@"name" : task.userInfo[@"name"]}];
                                                      [taskManager addTask:newTask];
                                                  }];
    
    if (![taskManager restoreTasks] || taskManager.numberOfTasks == 0) {
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:10] userInfo:@{@"name" : @"hoge"}]];
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:20] userInfo:@{@"name" : @"fuga"}]];
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:30] userInfo:@{@"name" : @"piyo"}]];
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:40] userInfo:@{@"name" : @"moge"}]];
    }
    
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

@end

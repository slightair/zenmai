//
//  ZMTaskManagerTest.m
//  ZenmaiExample
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "GHAsyncTestCase.h"
#import "ZMTaskManager.h"

@interface ZMTaskManagerTest : GHAsyncTestCase
@end

@implementation ZMTaskManagerTest

- (void)testSharedManager
{
    id managerA = [ZMTaskManager sharedManager];
    id managerB = [ZMTaskManager sharedManager];
    
    GHAssertEqualObjects(managerA, managerB, @"ZMTaskManager instance is not Singleton object.");
}

- (void)testManageTasks
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    [taskManager removeAllTasks];
    
    GHAssertEquals(0U, [taskManager numberOfTasks], @"tasks should be empty");
    
    NSDate *now = [NSDate date];
    ZMTask *taskA = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:20 sinceDate:now] userInfo:@{@"taskName" : @"hoge"}];
    ZMTask *taskB = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:now] userInfo:@{@"taskName" : @"fuga"}];
    ZMTask *taskC = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:30 sinceDate:now] userInfo:@{@"taskName" : @"piyo"}];
    
    [taskManager addTask:taskA];
    [taskManager addTask:taskB];
    [taskManager addTask:taskC];
    
    GHAssertEquals(3U, [taskManager numberOfTasks], @"manager should have 3 tasks");
    
    [taskManager addTask:taskA];
    GHAssertEquals(3U, [taskManager numberOfTasks], @"manager should not have same task object");
    
    NSMutableArray *taskNames = [@[@"hoge", @"fuga", @"piyo"] mutableCopy];
    for (ZMTask *task in [taskManager allTasks]) {
        NSInteger idx = -1;
        if ((idx = [taskNames indexOfObject:task.userInfo[@"taskName"]]) != NSNotFound) {
            [taskNames removeObjectAtIndex:idx];
        }
        else {
            GHFail(@"duplicate/unknown tasks found");
        }
    }
    GHAssertEquals(0U, [taskNames count], @"missing tasks found");
    
    NSSet *tasks = [taskManager tasksBeforeDate:[NSDate dateWithTimeInterval:20 sinceDate:now]];
    GHAssertEquals(2U, [tasks count], @"manager should be return 2 tasks");
}

- (void)testNotifyTask
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    [taskManager removeAllTasks];
    
    NSDate *now = [NSDate date];
    __block ZMTask *firedTask = nil;
    
    [self prepare];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval: 1 sinceDate:now] userInfo:@{@"taskName" : @"hoge"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:now] userInfo:@{@"taskName" : @"fuga"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:30 sinceDate:now] userInfo:@{@"taskName" : @"piyo"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:25 sinceDate:now] userInfo:@{@"taskName" : @"moge"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-5 sinceDate:now] userInfo:@{@"taskName" : @"moga"}]];
    GHAssertEquals(5U, [taskManager numberOfTasks], @"taskManager should have 5 tasks");
    
    [taskManager startCheckTimer];
    
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-10 sinceDate:now] userInfo:@{@"taskName" : @"poyo"}]];
    GHAssertEquals(5U, [taskManager numberOfTasks], @"taskManager could not add past task when check timer is running");
    
    id observer = [taskManager.notificationCenter addObserverForName:ZMTaskManagerTaskFireNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification){
                                                      firedTask = notification.userInfo[ZMTaskManagerNotificationTaskUserInfoKey];
                                                      if ([firedTask.userInfo[@"taskName"] isEqualToString:@"hoge"]) {
                                                          [self notify:kGHUnitWaitStatusSuccess];
                                                      }
                                                  }];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:2.0];
    
    [taskManager stopCheckTimer];
    [taskManager.notificationCenter removeObserver:observer];
}

@end

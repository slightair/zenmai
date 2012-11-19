//
//  ZMTaskManagerTest.m
//  ZenmaiExample
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "GHTestCase.h"
#import "ZMTaskManager.h"

@interface ZMTaskManagerTest : GHTestCase
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
    
    ZMTask *taskA = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:20] userInfo:@{@"taskName" : @"hoge"}];
    ZMTask *taskB = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:10] userInfo:@{@"taskName" : @"fuga"}];
    ZMTask *taskC = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:30] userInfo:@{@"taskName" : @"piyo"}];
    
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
}

@end

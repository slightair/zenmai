//
//  ZMTaskManagerTest.m
//  ZenmaiExample
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "GHAsyncTestCase.h"
#import "OCMock.h"
#import "ZMTaskManager.h"

#define kTestTaskListSaveFilePath @"/tmp/zenmai/testZMTasks.dat"

@interface ZMTaskManager ()

- (void)tick;
- (NSUInteger)fireTasks:(NSDate *)date;
- (BOOL)saveTasks;

@property(nonatomic, strong) NSString *taskListSaveFilePath;
@property(nonatomic, assign) BOOL isTickProcessRunning;

@end

@interface ZMTaskManagerTest : GHAsyncTestCase
@property(nonatomic, strong) NSString *originalTaskListSaveFilePath;
@end

@implementation ZMTaskManagerTest

- (void)testSharedManager
{
    id managerA = [ZMTaskManager sharedManager];
    id managerB = [ZMTaskManager sharedManager];
    
    GHAssertEqualObjects(managerA, managerB, @"ZMTaskManager instance is not Singleton object.");
}

- (void)setUpClass
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    self.originalTaskListSaveFilePath = taskManager.taskListSaveFilePath;
    taskManager.taskListSaveFilePath = kTestTaskListSaveFilePath;
}

- (void)tearDownClass
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    taskManager.taskListSaveFilePath = self.originalTaskListSaveFilePath;
    self.originalTaskListSaveFilePath = nil;
}

- (void)setUp
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    [taskManager removeAllTasks];
}

- (void)tearDown
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    [taskManager stopCheckTimer];
    taskManager.isTickProcessRunning = NO;
}

- (void)testManageTasks
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    GHAssertEquals(0U, [taskManager numberOfTasks], @"tasks should be empty.");
    
    NSDate *now = [NSDate date];
    ZMTask *taskA = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:20 sinceDate:now] userInfo:@{@"taskName" : @"hoge"}];
    ZMTask *taskB = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:now] userInfo:@{@"taskName" : @"fuga"}];
    ZMTask *taskC = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:30 sinceDate:now] userInfo:@{@"taskName" : @"piyo"}];
    
    [taskManager addTask:taskA];
    [taskManager addTask:taskB];
    [taskManager addTask:taskC];
    
    GHAssertEquals(3U, [taskManager numberOfTasks], @"manager should have 3 tasks.");
    
    [taskManager addTask:taskA];
    GHAssertEquals(3U, [taskManager numberOfTasks], @"manager should not have same task object.");
    
    NSMutableArray *taskNames = [@[@"hoge", @"fuga", @"piyo"] mutableCopy];
    for (ZMTask *task in [taskManager allTasks]) {
        NSInteger idx = -1;
        if ((idx = [taskNames indexOfObject:task.userInfo[@"taskName"]]) != NSNotFound) {
            [taskNames removeObjectAtIndex:idx];
        }
        else {
            GHFail(@"duplicate/unknown tasks found.");
        }
    }
    GHAssertEquals(0U, [taskNames count], @"missing tasks found.");
    
    NSSet *tasks = [taskManager tasksBeforeDate:[NSDate dateWithTimeInterval:20 sinceDate:now]];
    GHAssertEquals(2U, [tasks count], @"manager should be return 2 tasks.");
}

- (void)testNotifyTask
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    NSDate *now = [NSDate date];
    
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval: 1 sinceDate:now] userInfo:@{@"taskName" : @"hoge"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:now] userInfo:@{@"taskName" : @"fuga"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:30 sinceDate:now] userInfo:@{@"taskName" : @"piyo"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:25 sinceDate:now] userInfo:@{@"taskName" : @"moge"}]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-5 sinceDate:now] userInfo:@{@"taskName" : @"moga"}]];
    GHAssertEquals(5U, [taskManager numberOfTasks], @"taskManager should have 5 tasks.");

    id delegate = [OCMockObject mockForProtocol:@protocol(ZMTaskManagerDelegate)];
    [[delegate expect] taskManager:taskManager didFireTask:OCMOCK_ANY];
    [[delegate expect] taskManagerDidResume:taskManager];
    [[delegate expect] taskManager:taskManager didTick:1];
    taskManager.delegate = delegate;

    [taskManager startCheckTimer];
    GHAssertEquals(4U, [taskManager numberOfTasks], @"taskManager should run first tick when start check timer.");
    
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-10 sinceDate:now] userInfo:@{@"taskName" : @"poyo"}]];
    GHAssertEquals(4U, [taskManager numberOfTasks], @"taskManager could not add past task when check timer is running.");

    [taskManager stopCheckTimer];

    [delegate verify];
}

- (void)testSaveTasks
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");
    
    taskManager.isTickProcessRunning = NO;
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate date] userInfo:nil]];
    GHAssertTrue([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is not exists.");
    
    [taskManager removeAllTasks];
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");
    
    // not save task list when tick process runnning.
    taskManager.isTickProcessRunning = YES;
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate date] userInfo:nil]];
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");
}

- (void)testTick
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    NSDate *now = [NSDate date];
    
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-1 sinceDate:now] userInfo:nil]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:5 sinceDate:now] userInfo:nil]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:now] userInfo:nil]];
    
    GHAssertEquals(3U, [taskManager numberOfTasks], @"taskManager should have 3 tasks.");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // save task list when exist fired task
    [fileManager removeItemAtPath:kTestTaskListSaveFilePath error:NULL];
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");

    id delegate = [OCMockObject mockForProtocol:@protocol(ZMTaskManagerDelegate)];
    [[delegate expect] taskManager:taskManager didTick:1];
    [[delegate expect] taskManager:taskManager didFireTask:OCMOCK_ANY];

    taskManager.delegate = delegate;

    [taskManager tick];

    [delegate verify];

    taskManager.delegate = nil;

    GHAssertEquals(2U, [taskManager numberOfTasks], @"taskManager should have 2 tasks.");
    GHAssertTrue([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is not exists.");
    
    // not save task list when not exist fired task
    [fileManager removeItemAtPath:kTestTaskListSaveFilePath error:NULL];
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");
    
    [taskManager tick];
    GHAssertEquals(2U, [taskManager numberOfTasks], @"taskManager should have 2 tasks.");
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");
}

- (void)testFireTasks
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    NSDate *now = [NSDate date];
    
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-1 sinceDate:now] userInfo:nil]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:5 sinceDate:now] userInfo:nil]];
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 sinceDate:now] userInfo:nil]];
    
    GHAssertEquals(1U, [taskManager fireTasks:now], @"taskManager should fire 1 task.");
    
    GHAssertEquals(0U, [taskManager fireTasks:now], @"taskManager should not fire task.");
    
    [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:-10 sinceDate:now] userInfo:@{@"taskName" : @"test"}]];

    [self prepare];

    id delegate = [OCMockObject mockForProtocol:@protocol(ZMTaskManagerDelegate)];
    [[[delegate stub] andDo:^(NSInvocation *invocation){
        [self notify:kGHUnitWaitStatusSuccess];
    }] taskManager:taskManager didFireTask:OCMOCK_ANY];
    taskManager.delegate = delegate;

    NSUInteger numberOfFiredTasks = [taskManager fireTasks:now];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];

    GHAssertEquals(1U, numberOfFiredTasks, @"taskManager should fire 1 task.");
}

- (void)testRestoreTasks
{
    BOOL result = NO;
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    GHAssertEquals(0U, [taskManager numberOfTasks], @"taskManager is empty.");
    
    result = [taskManager restoreTasks];
    GHAssertFalse(result, @"taskManager should return NO if not restore tasks.");
    
    NSSet *dummyTasks = [NSSet setWithObjects:
                         [[ZMTask alloc] initWithDate:[NSDate date] userInfo:nil],
                         [[ZMTask alloc] initWithDate:[NSDate date] userInfo:nil],
                         [[ZMTask alloc] initWithDate:[NSDate date] userInfo:nil],
                         nil];
    [NSKeyedArchiver archiveRootObject:dummyTasks toFile:kTestTaskListSaveFilePath];

    id delegate = [OCMockObject mockForProtocol:@protocol(ZMTaskManagerDelegate)];
    [[delegate expect] taskManagerDidRestoreTasks:taskManager];
    taskManager.delegate = delegate;

    result = [taskManager restoreTasks];
    
    [delegate verify];

    GHAssertTrue(result, @"taskManager should return YES if succeeded restore tasks.");
    GHAssertEquals(3U, [taskManager numberOfTasks], @"taskManager should have 3 tasks.");
}

- (void)testRemoveTaskListSaveFileWhenRemovedAllTasks
{
    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:kTestTaskListSaveFilePath contents:[NSData data] attributes:nil];
    GHAssertTrue([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is not exists.");
    
    [taskManager removeAllTasks];
    GHAssertFalse([fileManager fileExistsAtPath:kTestTaskListSaveFilePath], @"task list save file is exists.");
}

@end

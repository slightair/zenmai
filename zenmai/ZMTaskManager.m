//
//  ZMTaskManager.m
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "ZMTaskManager.h"

// notifications
NSString *const ZMTaskManagerTaskFireNotification = @"ZMTaskManagerTaskFireNotification";
NSString *const ZMTaskManagerRestoreTasksNotification = @"ZMTaskManagerRestoreTasksNotification";
NSString *const ZMTaskManagerResumedNotification = @"ZMTaskManagerResumedNotification";
NSString *const ZMTaskManagerTickNotification = @"ZMTaskManagerTickNotification";

// UserInfoKey
NSString *const ZMTaskManagerNotificationTaskUserInfoKey = @"ZMTaskManagerNotificationTaskUserInfoKey";

// Constants
NSString *const ZMTaskManagerTaskListSaveFileDirectory = @"zenmai";
NSString *const ZMTaskManagerTaskListSaveFileName = @"zmtasks.dat";

@interface ZMTaskManager ()

- (NSArray *)sortedTasks:(NSSet *)tasks;
- (void)tick;
- (NSUInteger)fireTasks:(NSDate *)date;
- (BOOL)saveTasks;

@property(nonatomic, strong) NSMutableSet *tasks;
@property(nonatomic, strong) NSTimer *checkTimer;
@property(nonatomic, assign) NSTimeInterval checkTimerInterval;
@property(nonatomic, assign) BOOL isTickProcessRunning;
@property(nonatomic, strong) NSString *taskListSaveFilePath;

@end

@implementation ZMTaskManager

+ (id)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tasks = [NSMutableSet set];
        self.isTickProcessRunning = NO;
        self.notificationCenter = [NSNotificationCenter defaultCenter];
        self.taskListSaveFilePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                                      stringByAppendingPathComponent:ZMTaskManagerTaskListSaveFileDirectory]
                                      stringByAppendingPathComponent:ZMTaskManagerTaskListSaveFileName];
    }
    return self;
}

- (void)removeAllTasks
{
    [self.tasks removeAllObjects];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.taskListSaveFilePath]) {
        BOOL result = [fileManager removeItemAtPath:self.taskListSaveFilePath error:NULL];
        NSAssert(result, @"could not remove task list save file (%@).", self.taskListSaveFilePath);
    }
}

- (void)addTask:(ZMTask *)task
{
    if ([self.checkTimer isValid] && [task.date compare:[NSDate date]] == NSOrderedAscending) {
        return;
    }
    [self.tasks addObject:task];
    
    if (!self.isTickProcessRunning) {
        BOOL result = [self saveTasks];
        NSAssert(result, @"could not save task list (%@).", self.taskListSaveFilePath);
    }
}

- (NSUInteger)numberOfTasks
{
    return [self.tasks count];
}

- (NSArray *)allTasks
{
    return [self.tasks allObjects];
}

- (NSSet *)tasksBeforeDate:(NSDate *)date
{
    return [self.tasks objectsPassingTest:^BOOL(id obj, BOOL *stop){
        ZMTask *task = (ZMTask *)obj;
        return [task.date compare:date] != NSOrderedDescending;
    }];
}

- (NSArray *)sortedTasks:(NSSet *)tasks
{
    return [tasks sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
}

- (NSArray *)sortedTasks
{
    return [self sortedTasks:self.tasks];
}

- (void)startCheckTimer
{
    [self.checkTimer invalidate];
    
    self.isTickProcessRunning = NO;
    [self tick];
    [self.notificationCenter postNotificationName:ZMTaskManagerResumedNotification object:self];
    
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:ZMTaskManagerCheckTimerInterval
                                                       target:self
                                                     selector:@selector(tick)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopCheckTimer
{
    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

- (void)tick
{
    if (self.isTickProcessRunning) {
        return;
    }
    self.isTickProcessRunning = YES;
    
    if ([self fireTasks:[NSDate date]] > 0) {
        BOOL result = [self saveTasks];
        NSAssert(result, @"could not save task list (%@).", self.taskListSaveFilePath);
    }

    [self.notificationCenter postNotificationName:ZMTaskManagerTickNotification object:self];

    self.isTickProcessRunning = NO;
}

- (NSUInteger)fireTasks:(NSDate *)date
{
    NSSet *tasks = nil;
    NSUInteger firedTasks = 0;
    
    while ([(tasks = [self tasksBeforeDate:date]) count] > 0) {
        ZMTask *task = [[self sortedTasks:tasks] objectAtIndex:0];
        
        [self.tasks removeObject:task];
        [self.notificationCenter postNotificationName:ZMTaskManagerTaskFireNotification
                                               object:self
                                             userInfo:@{ZMTaskManagerNotificationTaskUserInfoKey : task}];
        firedTasks++;
    }
    
    return firedTasks;
}

- (BOOL)restoreTasks
{
    NSSet *savedTasks = [NSKeyedUnarchiver unarchiveObjectWithFile:self.taskListSaveFilePath];
    if (savedTasks) {
        self.tasks = [NSMutableSet setWithSet:savedTasks];
        [self.notificationCenter postNotificationName:ZMTaskManagerRestoreTasksNotification
                                               object:self];
        return YES;
    }
    
    return NO;
}

- (BOOL)saveTasks
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryPath = [self.taskListSaveFilePath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:directoryPath]) {
        BOOL result = [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
        NSAssert(result, @"could not make task list save directory.");
    }
    return [NSKeyedArchiver archiveRootObject:self.tasks toFile:self.taskListSaveFilePath];
}

@end

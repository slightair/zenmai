//
//  ZMTaskManager.m
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "ZMTaskManager.h"

// Constants
NSString *const ZMTaskManagerTaskListSaveFileDirectory = @"zenmai";
NSString *const ZMTaskManagerTaskListSaveFileName = @"zmtasks.dat";

@interface ZMTaskManager ()

- (NSArray *)sortedTasks:(NSSet *)tasks;
- (void)tick;
- (NSUInteger)fireTasks:(NSDate *)date;
- (BOOL)saveTasks;

@property(nonatomic, strong) NSMutableSet *tasks;
@property(nonatomic, assign) NSTimeInterval checkTimerInterval;
@property(nonatomic, assign) BOOL isTickProcessRunning;
@property(nonatomic, strong) NSString *taskListSaveFilePath;

#if OS_OBJECT_USE_OBJC
@property(nonatomic, strong) dispatch_source_t checkTimer;
#else
@property(nonatomic, assign) dispatch_source_t checkTimer;
#endif

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
        self.taskListSaveFilePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                                      stringByAppendingPathComponent:ZMTaskManagerTaskListSaveFileDirectory]
                                      stringByAppendingPathComponent:ZMTaskManagerTaskListSaveFileName];
        self.checkTimerInterval = ZMTaskManagerCheckTimerInterval;
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
    if (self.checkTimer && [task.date compare:[NSDate date]] == NSOrderedAscending) {
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
    if (self.checkTimer) {
        return;
    }

    self.isTickProcessRunning = NO;
    [self tick];

    if ([self.delegate respondsToSelector:@selector(taskManagerDidResume:)]) {
        [self.delegate taskManagerDidResume:self];
    }

    dispatch_queue_t queue = dispatch_queue_create("timerQueue", 0);
    self.checkTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    dispatch_source_set_event_handler(self.checkTimer, ^{
        [self tick];
    });

    dispatch_source_set_timer(self.checkTimer, DISPATCH_TIME_NOW, NSEC_PER_SEC * self.checkTimerInterval, 0);

    dispatch_resume(self.checkTimer);
}

- (void)stopCheckTimer
{
    if (self.checkTimer) {
        dispatch_source_cancel(self.checkTimer);

#if !OS_OBJECT_USE_OBJC
        dispatch_release(self.checkTimer);
#endif

        self.checkTimer = nil;
    }
}

- (void)tick
{
    if (self.isTickProcessRunning) {
        return;
    }
    self.isTickProcessRunning = YES;

    NSUInteger numberOfFiredTasks = [self fireTasks:[NSDate date]];
    if (numberOfFiredTasks > 0) {
        BOOL result = [self saveTasks];
        NSAssert(result, @"could not save task list (%@).", self.taskListSaveFilePath);
    }

    if ([self.delegate respondsToSelector:@selector(taskManager:didTick:)]) {
        [self.delegate taskManager:self didTick:numberOfFiredTasks];
    }

    self.isTickProcessRunning = NO;
}

- (NSUInteger)fireTasks:(NSDate *)date
{
    NSSet *tasks = nil;
    NSUInteger firedTasks = 0;
    
    while ([(tasks = [self tasksBeforeDate:date]) count] > 0) {
        ZMTask *task = [[self sortedTasks:tasks] objectAtIndex:0];
        
        [self.tasks removeObject:task];
        if ([self.delegate respondsToSelector:@selector(taskManager:didFireTask:)]) {
            [self.delegate taskManager:self didFireTask:task];
        }

        firedTasks++;
    }
    
    return firedTasks;
}

- (BOOL)restoreTasks
{
    NSSet *savedTasks = [NSKeyedUnarchiver unarchiveObjectWithFile:self.taskListSaveFilePath];
    if (savedTasks) {
        self.tasks = [NSMutableSet setWithSet:savedTasks];

        if ([self.delegate respondsToSelector:@selector(taskManagerDidRestoreTasks:)]) {
            [self.delegate taskManagerDidRestoreTasks:self];
        }

        return YES;
    }
    
    return NO;
}

- (BOOL)isRunning
{
    return self.checkTimer ? YES : NO;
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

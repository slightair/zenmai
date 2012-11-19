//
//  ZMTaskManager.m
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "ZMTaskManager.h"

// notifications
NSString *const ZMTaskManagerTaskFireNotification = @"ZMTaskManagerTaskFireNotification";

// UserInfoKey
NSString *const ZMTaskManagerNotificationTaskUserInfoKey = @"ZMTaskManagerNotificationTaskUserInfoKey";

@interface ZMTaskManager ()

- (NSArray *)sortedTasks:(NSSet *)tasks;
- (void)tick;
- (void)fireTasks:(NSDate *)date;

@property(nonatomic, strong) NSMutableSet *tasks;
@property(nonatomic, strong) NSTimer *checkTimer;
@property(nonatomic, assign) NSTimeInterval checkTimerInterval;
@property(nonatomic, assign) BOOL isTickProcessRunning;

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
    }
    return self;
}

- (void)removeAllTasks
{
    [self.tasks removeAllObjects];
}

- (void)addTask:(ZMTask *)task
{
    if ([self.checkTimer isValid] && [task.date compare:[NSDate date]] == NSOrderedAscending) {
        return;
    }
    [self.tasks addObject:task];
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
    
    [self fireTasks:[NSDate date]];
    
    self.isTickProcessRunning = NO;
}

- (void)fireTasks:(NSDate *)date
{
    NSSet *tasks = nil;
    while ([(tasks = [self tasksBeforeDate:date]) count] > 0) {
        ZMTask *task = [[self sortedTasks:tasks] objectAtIndex:0];
        
        [self.notificationCenter postNotificationName:ZMTaskManagerTaskFireNotification
                                               object:self
                                             userInfo:@{ZMTaskManagerNotificationTaskUserInfoKey : task}];
        [self.tasks removeObject:task];
    }
}

@end

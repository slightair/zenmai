//
//  ZMTaskManager.h
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMTask.h"

#define ZMTaskManagerCheckTimerInterval 1.0

// notifications
extern NSString *const ZMTaskManagerTaskFireNotification;
extern NSString *const ZMTaskManagerRestoreTasksNotification;
extern NSString *const ZMTaskManagerResumedNotification;
extern NSString *const ZMTaskManagerTickNotification;

// UserInfoKey
extern NSString *const ZMTaskManagerNotificationTaskUserInfoKey;

@interface ZMTaskManager : NSObject

+ (id)sharedManager;
- (void)removeAllTasks;
- (void)addTask:(ZMTask *)task;
- (NSUInteger)numberOfTasks;
- (NSArray *)allTasks;
- (NSSet *)tasksBeforeDate:(NSDate *)date;
- (NSArray *)sortedTasks;
- (void)startCheckTimer;
- (void)stopCheckTimer;
- (BOOL)restoreTasks;
- (BOOL)isRunning;

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

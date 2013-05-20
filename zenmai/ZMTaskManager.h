//
//  ZMTaskManager.h
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMTask.h"

#define ZMTaskManagerCheckTimerInterval 1.0

@class ZMTaskManager;

@protocol ZMTaskManagerDelegate <NSObject>

@optional
- (void)taskManagerDidRestoreTasks:(ZMTaskManager *)taskManager;
- (void)taskManagerDidResume:(ZMTaskManager *)taskManager;
- (void)taskManager:(ZMTaskManager *)taskManager didFireTask:(ZMTask *)task;
- (void)taskManager:(ZMTaskManager *)taskManager didTick:(NSUInteger)numberOfFiredTasks;

@end

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

@property(nonatomic, weak) id <ZMTaskManagerDelegate> delegate;

@end

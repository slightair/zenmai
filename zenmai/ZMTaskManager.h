//
//  ZMTaskManager.h
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMTask.h"

@interface ZMTaskManager : NSObject

+ (id)sharedManager;
- (void)removeAllTasks;
- (void)addTask:(ZMTask *)task;
- (NSUInteger)numberOfTasks;
- (NSArray *)allTasks;
- (NSSet *)tasksBeforeDate:(NSDate *)date;

@end

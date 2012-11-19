//
//  ZMTaskManager.m
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "ZMTaskManager.h"

@interface ZMTaskManager ()

@property(nonatomic, strong) NSMutableSet *tasks;

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
    }
    return self;
}

- (void)removeAllTasks
{
    [self.tasks removeAllObjects];
}

- (void)addTask:(ZMTask *)task
{
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

@end

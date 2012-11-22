//
//  ZMTaskTest.m
//  ZenmaiExample
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "GHTestCase.h"
#import "ZMTask.h"

@interface ZMTaskTest : GHTestCase
@end

@implementation ZMTaskTest

- (void)testInitWithDate_userInfo
{
    NSDate *dateOfAfter3Seconds = [NSDate dateWithTimeIntervalSinceNow:3];
    NSDictionary *userInfo = @{@"taskName" : @"hoge"};
    
    ZMTask *task = [[ZMTask alloc] initWithDate:dateOfAfter3Seconds userInfo:userInfo];
    
    GHAssertEqualObjects(dateOfAfter3Seconds, task.date, @"task.date should be equal dateOfAfter3Seconds");
    GHAssertNotNil(task.userInfo[@"taskName"], @"task.userInfo should have object for key 'taskName'");
    GHAssertEqualObjects(@"hoge", task.userInfo[@"taskName"], @"task.userInfo[@\"taskName\"] should be equal 'hoge'");
}

- (void)testNSCodingProtocol
{
    NSDate *date = [NSDate date];
    NSDictionary *userInfo = @{@"name" : @"hoge", @"option" : @"fuga"};
    
    ZMTask *task = [[ZMTask alloc] initWithDate:date userInfo:userInfo];
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:task];
    ZMTask *unarchivedTask = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    GHAssertEqualObjects(task.date, unarchivedTask.date, @"failed to unarchive task.date");
    GHAssertEqualObjects(task.userInfo, unarchivedTask.userInfo, @"failed to unarchive task.userInfo");
}

@end

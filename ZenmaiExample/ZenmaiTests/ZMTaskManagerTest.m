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

@end

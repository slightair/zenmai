//
//  ZMTask.m
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "ZMTask.h"

@interface ZMTask()

@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSDictionary *userInfo;

@end

@implementation ZMTask

- (id)initWithDate:(NSDate *)date userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        self.date = date;
        self.userInfo = userInfo;
    }
    return self;
}

@end

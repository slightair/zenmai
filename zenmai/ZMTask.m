//
//  ZMTask.m
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "ZMTask.h"

@interface ZMTask()

@property(nonatomic, strong) NSDate *date;
@property(nonatomic, strong) NSDictionary *userInfo;

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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

@end

//
//  ZMTask.h
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMTask : NSObject <NSCoding>

- (id)initWithDate:(NSDate *)date userInfo:(NSDictionary *)userInfo;

@property(nonatomic, strong, readonly) NSDate *date;
@property(nonatomic, strong, readonly) NSDictionary *userInfo;

@end

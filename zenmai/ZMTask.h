//
//  ZMTask.h
//
//  Created by slightair on 2012/11/18.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMTask : NSObject

- (id)initWithDate:(NSDate *)date userInfo:(NSDictionary *)userInfo;

@property(nonatomic, retain, readonly) NSDate *date;
@property(nonatomic, retain, readonly) NSDictionary *userInfo;

@end

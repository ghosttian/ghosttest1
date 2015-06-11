//
//  GinLoggerLevelFilter.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerLevelFilter.h"
#import "LogEvent.h"
#import "LogLevel.h"

@interface  GinLoggerLevelFilter()

@property (nonatomic, strong, readwrite) LogLevel* level;

@end

@implementation GinLoggerLevelFilter

- (id)initWithLevelValue:(int)aLevel
{
    if (self = [super init])
    {
        self.level = [[LogLevel alloc] initLevelWith:aLevel];
    }
    
    return self;
}

// 凡是级别大于logLevel的log都会显示
- (BOOL)decide:(LogEvent**)logEvent
{
    if (logEvent != nil && *logEvent != nil)
    {
        // logEvent的log级别低于levelFilter的级别，就过滤掉，不显示在最终输出
        if ([self.level severityIsGreaterThanOrEqualTo:(*logEvent).level])
        {
            return YES;
        }
    }
    
    return NO;
}

@end

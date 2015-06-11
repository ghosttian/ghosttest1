//
//  GinLoggerConsoleAppender.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerConsoleAppender.h"
#import "LogLevel.h"
#import "GinLoggerLevelFilter.h"
#import "GinLoggerModuleFilter.h"
#import "GinLoggerLayout.h"
#import "GinLoggerDef.h"

const int kDebugConsoleAppenderSeverity     = kAllValue;

@implementation GinLoggerConsoleAppender

+ (GinLoggerConsoleAppender*)debugAppender
{
    static GinLoggerConsoleAppender* _sharedInstance;
    
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[GinLoggerConsoleAppender alloc] init];
            [_sharedInstance setupDebugConsoleSettings];
        });
    }
    
    return _sharedInstance;
}

- (void)append:(LogEvent*)logEvent
{
    if (logEvent)
    {
        NSLog(@"%@", [self.layout format:logEvent]);
    }
}

#pragma mark private methods

- (void)setupDebugConsoleSettings
{
    self.level = [[LogLevel alloc]initLevelWith:kDebugConsoleAppenderSeverity];
    self.layout = [GinLoggerLayout trimTimeStampLayout];
    [self appendFilter:[[GinLoggerLevelFilter alloc] initWithLevelValue:kDebugConsoleAppenderSeverity]];
    [self appendFilter:[[GinLoggerModuleFilter alloc] init]];
}

@end

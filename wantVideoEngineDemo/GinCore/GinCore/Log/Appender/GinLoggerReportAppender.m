//
//  GinLoggerReportAppender.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerReportAppender.h"
#import "LogLevel.h"
#import "GinLoggerLevelFilter.h"
#import "GinLoggerDef.h"
#import "GinLoggerLayout.h"
#import "LogEvent.h"
#import "GinLoggerDef.h"
//#import "WDKLog.h"

const int kReportAppenderSeverity         = kInfoValue;

@implementation GinLoggerReportAppender

+ (GinLoggerReportAppender*)WDKAppender
{
    static GinLoggerReportAppender* _sharedInstance = nil;
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[GinLoggerReportAppender alloc] initWithWDKSettings];
        });
    }
    return _sharedInstance;
}

// 将log添加到appender中
- (void)append:(LogEvent*)logEvent
{
    @synchronized(self)
    {
        if (logEvent)
        {
            NSString *logString = [self.layout format:logEvent];
            
            switch (logEvent.level.intValue)
            {
                case kFatalValue:
                {
//                    [WDKLoger logFatal:logString];
                }
                    break;
                case kErrorValue:
                {
//                    [WDKLoger logError:logString];
                }
                    break;
                case kWarnValue:
                {
//                    [WDKLoger logWarn:logString];
                }
                    break;
                case kInfoValue:
                {
//                    [WDKLoger logInfo:logString];
                }
                    break;
                case kDebugValue:
                {
//                    [WDKLoger logDebug:logString];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark private methods

- (id)initWithWDKSettings
{
    if (self = [super init])
    {
        self.level = [[LogLevel alloc]initLevelWith:kReportAppenderSeverity];
        [self appendFilter:[[GinLoggerLevelFilter alloc] initWithLevelValue:kReportAppenderSeverity]];
    }
    
    return self;
}

@end

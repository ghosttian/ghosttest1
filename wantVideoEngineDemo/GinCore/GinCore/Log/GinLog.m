//
//  GinLog.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLog.h"
#import "LogLevel.h"
#import "LogEvent.h"
#import "GinRootLogger.h"

void glog(const char* fileName, const char* funcName, int line, int logLevel, LogModuleType moduleType, NSString *fmt, ...)
{
#ifdef kBuildAppForAppStore
    BOOL isEableLog = ([GlobalConfiguration sharedConfiguration].isGLogEnable || [GlobalConfiguration sharedConfiguration].isMandatoryUploadGLog);
#else
    BOOL isEableLog = YES;
#endif

    if (isEableLog && fmt)
    {
        NSString* file = @(fileName);
        file = [file lastPathComponent];
        NSString* methodName = @(funcName);
        LogLevel *level = [[LogLevel alloc] initLevelWith:logLevel];
        NSString *combinedMessage;
        va_list args;
        
        va_start(args, fmt);
        combinedMessage = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);
        LogEvent* logEvent = [[LogEvent alloc] initLogEventWithLevel:level
                                                          threadName:nil
                                                            fileName:file
                                                          methodName:methodName
                                                          lineNumber:line
                                                      eventTimeStamp:[NSDate date]
                                                          moduleType:moduleType
                                                             message:combinedMessage];
        GinRootLogger *defaultLogger = [GinRootLogger defaultLogger];
        [defaultLogger emitLogs:logEvent];
    }
}

//
//  GinLoggerTrimTimeStampLayout.m
//  microChannel
//
//  Created by wangqi on 14-4-22.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerTrimTimeStampLayout.h"
#import "LogEvent.h"
#import "LogLevel.h"

@implementation GinLoggerTrimTimeStampLayout

- (NSString*)format:(LogEvent*)logEvent
{
    if (nil == logEvent)
    {
        return nil;
    }
    
    NSString* formatStr = nil;
    
    formatStr = [NSString stringWithFormat:@"<%@> | %@: %@", logEvent.level.name, logEvent.moduleName, logEvent.message];
    
    return formatStr;
}

@end

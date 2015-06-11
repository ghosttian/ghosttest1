//
//  GinLoggerDefaultLayout.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerDefaultLayout.h"
#import "LogEvent.h"
#import "LogLevel.h"

@implementation GinLoggerDefaultLayout

- (NSString*)format:(LogEvent*)logEvent
{
    if (nil == logEvent)
    {
        return nil;
    }
    
    NSString* formatStr = nil;
    
    // to create several NSDateFormatter instances is too expensive for performance cost.
    static NSDateFormatter *formatter = nil;
    
    if (nil == formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }

    @synchronized(formatter)
    {
        NSString* dateStr = nil;
        dateStr = [formatter stringFromDate:logEvent.timestamp];
        formatStr = [NSString stringWithFormat:@"<%@> | %@ | %@: %@", logEvent.level.name, dateStr, logEvent.moduleName, logEvent.message];
    }
    
    return formatStr;
}

@end

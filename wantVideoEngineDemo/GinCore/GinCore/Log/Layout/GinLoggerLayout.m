//
//  GinLoggerLayout.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerLayout.h"
#import "LogEvent.h"
#import "GinLoggerDefaultLayout.h"
#import "GinLoggerTrimTimeStampLayout.h"


@implementation GinLoggerLayout

+ (instancetype)defaultLayout
{
    return [[GinLoggerDefaultLayout alloc] init];
}

+ (instancetype)trimTimeStampLayout
{
    return [[GinLoggerTrimTimeStampLayout alloc] init];
}

- (NSString*)format:(LogEvent*)logEvent
{
    return [LogEvent description];
}

@end

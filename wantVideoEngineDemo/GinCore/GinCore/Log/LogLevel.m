//
//  LogLevel.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "LogLevel.h"
#import "GinLoggerDef.h"

#pragma mark Constants

NSString* const kOffName            = @"OFF";
NSString* const kFatalName          = @"FATAL";
NSString* const kCriticalName       = @"CRITICAL";
NSString* const kErrorName          = @"ERROR";
NSString* const kWarnName           = @"WARN";
NSString* const kInfoName           = @"INFO";
NSString* const kDebugName          = @"DEBUG";
NSString* const kAllName            = @"ALL";
NSString* const kUnknow             = @"UNKNOW";

@interface LogLevel()

@property (nonatomic, assign, readwrite) int intValue;
@property (nonatomic, copy, readwrite) NSString* name;

@end

@implementation LogLevel

+ (instancetype)fatalLevel
{
    LogLevel* fatal = [[LogLevel alloc] initLevelWith:kFatalValue];
    
    return fatal;
}

+ (instancetype)criticalLevel
{
    LogLevel* critical = [[LogLevel alloc] initLevelWith:kCriticalValue];
    return critical;
}

+ (instancetype)errorLevel
{
    LogLevel* error = [[LogLevel alloc] initLevelWith:kErrorValue];
    
    return error;
}

+ (instancetype)warnLevel
{
    LogLevel* warn = [[LogLevel alloc] initLevelWith:kWarnValue];
    
    return warn;
}

+ (instancetype)infoLevel
{
    LogLevel* info = [[LogLevel alloc] initLevelWith:kInfoValue];
    
    return info;
}

+ (instancetype)debugLevel
{
    LogLevel* debug = [[LogLevel alloc] initLevelWith:kDebugValue];
    
    return debug;
}

- (id)initLevelWith:(int)aLevel
{
    if (self = [super init])
    {
        self.intValue = aLevel;
        self.name = [self decideNameWithLevelValue:aLevel];
    }
    
    return self;
}

- (BOOL)severityIsGreaterThanOrEqualTo:(LogLevel*)aLevel
{
    if (self.intValue <= aLevel.intValue)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark private methods

- (NSString*)decideNameWithLevelValue:(int)aLevel
{
    NSString *retVal = nil;
    switch (aLevel)
    {
        case kOffValue:
        {
            retVal = kOffName;
        }
            break;
        case kFatalValue:
        {
            retVal = kFatalName;
        }
            break;
        case kCriticalValue:
        {
            retVal = kCriticalName;
        }
            break;
        case kErrorValue:
        {
            retVal = kErrorName;
        }
            break;
        case kWarnValue:
        {
            retVal = kWarnName;
        }
            break;
        case kInfoValue:
        {
            retVal = kInfoName;
        }
            break;
        case kDebugValue:
        {
            retVal = kDebugName;
        }
            break;
        case kAllValue:
        {
            retVal = kAllName;
        }
            break;
        default:
        {
            retVal = kUnknow;
        }
            break;
    }
    
    return retVal;
}

@end

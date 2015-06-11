//
//  LogEvent.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "LogEvent.h"

@interface LogEvent()

@property (nonatomic, strong, readwrite) LogLevel* level;
@property (nonatomic, copy, readwrite) NSString* threadName;
@property (nonatomic, copy, readwrite) NSString* fileName;
@property (nonatomic, copy, readwrite) NSString* methodName;
@property (nonatomic, strong, readwrite) NSNumber* lineNumber;
@property (nonatomic, strong, readwrite) NSDate *timestamp;
@property (nonatomic, assign, readwrite) LogModuleType moduleType;
@property (nonatomic, strong, readwrite) id message;

@end

@implementation LogEvent

- (id)initLogEventWithLevel:(LogLevel*)aLevel
                 threadName:(NSString*)aThreadName
                   fileName:(NSString*)aFileName
                 methodName:(NSString*)aMethodName
                 lineNumber:(int)aLineNumber
             eventTimeStamp:(NSDate*)aDate
                 moduleType:(LogModuleType)moduleType
                    message:(id)aMessage
{
    if (self = [super init])
    {
        self.level = aLevel;
        self.threadName = aThreadName;
        self.fileName = aFileName;
        self.methodName = aMethodName;
        self.lineNumber = @(aLineNumber);
        self.timestamp = aDate;
        self.moduleType = moduleType;
        self.message = aMessage;
    }
    
    return self;
}

- (NSString*)description
{
    return nil;
}

@end

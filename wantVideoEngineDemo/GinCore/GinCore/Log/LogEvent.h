//
//  LogEvent.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GinLoggerDef.h"

@class LogLevel;

@interface LogEvent : NSObject

@property (nonatomic, strong, readonly) LogLevel* level;
@property (nonatomic, copy, readonly) NSString* threadName;
@property (nonatomic, copy, readwrite) NSString* moduleName;
@property (nonatomic, copy, readonly) NSString* fileName;
@property (nonatomic, copy, readonly) NSString* methodName;
@property (nonatomic, strong, readonly) NSNumber* lineNumber;
@property (nonatomic, strong, readonly) NSDate *timestamp;
@property (nonatomic, assign, readonly) LogModuleType moduleType;
@property (nonatomic, strong, readonly) id message;


- (id)initLogEventWithLevel:(LogLevel*)aLevel
                 threadName:(NSString*)aThreadName
                   fileName:(NSString*)aFileName
                 methodName:(NSString*)aMethodName
                 lineNumber:(int)aLineNumber
             eventTimeStamp:(NSDate*)aDate
                 moduleType:(LogModuleType)moduleType
                    message:(id)aMessage;

- (NSString*)description;

@end

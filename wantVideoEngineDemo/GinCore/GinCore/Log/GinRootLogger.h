//
//  GinRootLogger.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol GinLoggerAppenderProtocol;
@class LogEvent;

@interface GinRootLogger : NSObject

@property (nonatomic, strong) dispatch_semaphore_t freezeSemAphore;

+ (GinRootLogger*)defaultLogger;

+ (GinRootLogger*)rootLogger;

#pragma mark - appenders related methods
// 添加log appender
- (void)addAppender:(id <GinLoggerAppenderProtocol>)newAppender;

// 删除appender
- (void)removeAppender:(id <GinLoggerAppenderProtocol>)appender;

// 根据名字删除appender，常用的几个appender会定义常量
- (void)removeAppenderWithName:(NSString*)name;

// 删除所有的appender
- (void)removeAllAppenders;

#pragma mark - print log methods
// 把log信息输出到各个appender中去
- (void)emitLogs:(LogEvent*)logEvent;

@end

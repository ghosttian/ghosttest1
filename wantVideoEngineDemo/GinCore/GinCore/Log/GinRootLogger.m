//
//  GinRootLogger.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinRootLogger.h"
#import "GinLoggerAppenderMgr.h"
#import "NSString+CommonUse.h"
#import "GinLoggerFileAppender.h"
#import "GinLoggerConsoleAppender.h"
#import "GinLoggerReportAppender.h"
#import "LogEvent.h"
#import "LogLevel.h"
#import "GinLog.h"
#import "GinLoggerModuleFilter.h"


@interface GinRootLogger ()

@property (nonatomic, strong) GinLoggerAppenderMgr *appenderMgr;

@end

@implementation GinRootLogger

- (void)dealloc
{
    self.freezeSemAphore = nil;
}

+ (GinRootLogger*)defaultLogger
{
    static GinRootLogger* _sharedInstance;
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[GinRootLogger alloc] initWithPrivate];
            // add the common use appenders
            [_sharedInstance setupDefaultLogger];
        });
    }
    
    return _sharedInstance;
}

+ (GinRootLogger*)rootLogger
{
    static GinRootLogger* _sharedInstance;
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[GinRootLogger alloc] initWithPrivate];
        });
    }
    
    return _sharedInstance;
}

#pragma mark appenders related methods

// 添加log appender
- (void)addAppender:(id <GinLoggerAppenderProtocol>)newAppender
{
    if (newAppender)
    {
        @synchronized(self)
        {
            [self.appenderMgr addAppender:newAppender];
        }
    }
}

// 删除appender
- (void)removeAppender:(id <GinLoggerAppenderProtocol>)appender
{
    if (appender)
    {
        @synchronized(self)
        {
            [self.appenderMgr removeAppender:appender];
        }
    }
}

// 根据名字删除appender，常用的几个appender会定义常量
- (void)removeAppenderWithName:(NSString*)name
{
    if ([NSString isEmptyString:name])
    {
        @synchronized(self)
        {
            [self.appenderMgr removeAppenderWithName:name];
        }
    }
}

// 删除所有的appender
- (void)removeAllAppenders
{
    @synchronized(self)
    {
        [self.appenderMgr removeAllAppenders];
    }
}

#pragma mark print log methods

- (void)emitLogs:(LogEvent*)logEvent
{
    if (logEvent)
    {
        if (self.appenderMgr)
        {
            // pop-up alert to notify tester, go and find a developer
#ifdef kBuildAppForDebug
            if ([logEvent.level severityIsGreaterThanOrEqualTo:[LogLevel criticalLevel]])
            {
                GinLoggerModuleFilter *moduleFilter = [[GinLoggerModuleFilter alloc] init];
                NSString *msg = [NSString stringWithFormat:@"hi dude, critical error encountered at %@, find a developer!", [moduleFilter getModuleNameWithModuleType:logEvent.moduleType]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIAlertView alertViewWithTitle:msg
                                             message:@""
                                   cancelButtonTitle:@"YES"
                                   otherButtonTitles:@[@"NO"]
                                           onDismiss:^(NSInteger buttonIndex){
                                           }
                                            onCancel:^{
                                            }] show];
                });
            }
#endif
            [self.appenderMgr appendLogOnAppenders:logEvent];
        }
    }
}

#pragma private methods

- (id)initWithPrivate
{
    if (self = [super init])
    {
        self.appenderMgr = [[GinLoggerAppenderMgr alloc] init];
        self.freezeSemAphore = dispatch_semaphore_create(1);
    }
    
    return self;
}

- (void)setupDefaultLogger
{
    [self addAppender:[GinLoggerConsoleAppender debugAppender]];
    [self addAppender:[GinLoggerFileAppender defaultFileAppender]];
    [self addAppender:[GinLoggerReportAppender WDKAppender]];
}

@end


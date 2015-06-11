//
//  GinLoggerAppenderMgr.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerAppenderMgr.h"
#import "NSString+CommonUse.h"
#import "GinLoggerAppenderSkeleton.h"

@interface GinLoggerAppenderMgr()

@property (atomic, strong, readwrite) NSMutableArray* appenderList;

@end

@implementation GinLoggerAppenderMgr

- (void)dealloc
{
    
}

- (id)init
{
    if (self = [super init])
    {
        self.appenderList = [NSMutableArray array];
    }
    
    return self;
}

// 添加log appender
- (void)addAppender:(id <GinLoggerAppenderProtocol>)newAppender
{
    if (newAppender)
    {
        @synchronized(self)
        {
            if (![self.appenderList containsObject:newAppender])
            {
                [self.appenderList addObject:newAppender];
            }
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
            [self.appenderList removeObject:appender];
        }
    }
}

// 根据名字删除appender，常用的几个appender会定义常量
- (void)removeAppenderWithName:(NSString*)name
{
    if ([NSString isEmptyString:name])
    {
        return;
    }
    
    @synchronized(self)
    {
        id<GinLoggerAppenderProtocol> tmpAppender = [self.appenderList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]].lastObject;
        [self.appenderList removeObject:tmpAppender];
    }
}

// 删除所有的appender
- (void)removeAllAppenders
{
    @synchronized(self)
    {
        [self.appenderList removeAllObjects];
        self.appenderList = nil;
    }
}

// 添加log到每个appender
- (void)appendLogOnAppenders:(LogEvent*)logEvent
{
    for (id<GinLoggerAppenderProtocol> item in self.appenderList)
    {
        [item doAppend:logEvent];
    }
}

@end

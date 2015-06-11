//
//  GinLoggerAppenderSkeleton.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GinLoggerAppenderSkeleton.h"
#import "GinLoggerFilterSkeleton.h"
#import "GinLoggerLayout.h"

@interface GinLoggerAppenderSkeleton()

@property (nonatomic, strong, readwrite) NSMutableArray* filterList;

@end

@implementation GinLoggerAppenderSkeleton

- (void)dealloc
{
    
}

- (id)init
{
    if (self = [super init])
    {
        self.filterList = [NSMutableArray array];
        // 创建默认的layout，可以在子类中自己重定义
        self.layout = [GinLoggerLayout defaultLayout];
    }
    
    return self;
}

- (id)initWithProperties:(NSDictionary*)properties
{
    if (self = [super init])
    {
        self.filterList = [NSMutableArray array];
        self.layout = [GinLoggerLayout defaultLayout];
    }
    
    return self;
}

#pragma GinLoggerAppenderProtocol methods

// 在添加log之前多一些对应的判断，看log是否应该添加到appender中
- (void)doAppend:(LogEvent*)logEvent
{
    BOOL isFilteredAsNotShown = NO;

    for (id<GinLoggerFilterProtocol>item in self.filterList)
    {
        isFilteredAsNotShown = [item decide:&logEvent];
        if (YES == isFilteredAsNotShown)
        {
            break;
        }
    }
    
    if (NO == isFilteredAsNotShown)
    {
        [self append:logEvent];
    }
}

// 将log添加到appender中
- (void)append:(LogEvent*)logEvent
{
    
}

// 添加filter
- (void)appendFilter:(id<GinLoggerFilterProtocol>)newFilter
{
    if (newFilter)
    {
        @synchronized(self)
        {
            [self.filterList addObject:newFilter];
        }
    }
}

// 清空所有的filter
- (void)clearFilters
{
    @synchronized(self)
    {
        [self.filterList removeAllObjects];
        self.filterList = nil;
    }
}

@end

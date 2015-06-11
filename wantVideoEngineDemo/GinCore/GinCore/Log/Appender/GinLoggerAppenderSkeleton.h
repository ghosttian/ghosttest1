//
//  GinLoggerAppenderSkeleton.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol GinLoggerFilterProtocol;
@class GinLoggerLayout;
@class LogEvent;
@class LogLevel;

@protocol GinLoggerAppenderProtocol <NSObject>

@required
// 在添加log之前多一些对应的判断，看log是否应该添加到appender中
- (void)doAppend:(LogEvent*)logEvent;

// 将log添加到appender中
- (void)append:(LogEvent*)logEvent;

// 添加filter
- (void)appendFilter:(id<GinLoggerFilterProtocol>)newFilter;

// 清空所有的filter
- (void)clearFilters;

@end

@interface GinLoggerAppenderSkeleton : NSObject <GinLoggerAppenderProtocol>

@property (nonatomic, copy, readonly) NSString *name;
@property (atomic, strong) GinLoggerLayout *layout;
@property (nonatomic, strong) LogLevel *level;
@property (nonatomic, strong, readonly) NSMutableArray* filterList;

- (id)initWithProperties:(NSDictionary*)properties;

@end

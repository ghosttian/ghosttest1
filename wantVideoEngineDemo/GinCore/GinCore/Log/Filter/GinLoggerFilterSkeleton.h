//
//  GinLoggerFilterSkeleton.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>

@class LogEvent;

#pragma mark Filter Protocol所有的Filter都必须继承至这个protocol

@protocol GinLoggerFilterProtocol <NSObject>

@required
// 判断该条logEvent是否会被过滤，YES表示会被过滤不会显示
- (BOOL)decide:(LogEvent**)logEvent;

@end

#pragma mark GinLoggerFilterSkeleton所有Filter的基类

@interface GinLoggerFilterSkeleton : NSObject <GinLoggerFilterProtocol>

@end

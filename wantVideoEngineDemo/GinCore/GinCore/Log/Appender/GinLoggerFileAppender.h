//
//  GinLoggerFileAppender.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GinLoggerAppenderSkeleton.h"

@interface GinLoggerFileAppender : GinLoggerAppenderSkeleton

@property (atomic, assign) BOOL isImmediatelyFlush;                 // YES表示没有buffering机制，一旦有log立马输出到文件中
@property (nonatomic, assign) NSStringEncoding encoding;

// note: this appender is just allowed to add once!!!
+ (GinLoggerFileAppender*)defaultFileAppender;

- (id)initWithFileName:(NSString*)fileName;

// 写一条log数据到文件中
- (void)write:(NSString*)logString;

- (void)closeFile;

@end

//
//  GinLoggerConsoleAppender.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerAppenderSkeleton.h"

@interface GinLoggerConsoleAppender : GinLoggerAppenderSkeleton

+ (GinLoggerConsoleAppender*)debugAppender;

@end

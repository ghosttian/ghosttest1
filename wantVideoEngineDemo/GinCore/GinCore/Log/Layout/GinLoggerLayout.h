//
//  GinLoggerLayout.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>

@class LogEvent;

@interface GinLoggerLayout : NSObject

+ (instancetype)defaultLayout;

+ (instancetype)trimTimeStampLayout;

- (NSString*)format:(LogEvent*)logEvent;

@end

//
//  LogFileUploadHooker.h
//  microChannel
//
//  Created by joeqiwang on 14-5-7.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>
@class LogEvent;

@interface LogFileUploadHooker : NSObject

@property (nonatomic, strong) LogEvent* logEvent;

- (id)initWithOriginalFileName:(NSString*)oriFileName;

- (void)doLogFileUpload;

@end

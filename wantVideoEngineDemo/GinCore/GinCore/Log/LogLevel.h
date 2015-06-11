//
//  LogLevel.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface LogLevel : NSObject

@property (nonatomic, assign, readonly) int intValue;
@property (nonatomic, copy, readonly) NSString* name;

+ (instancetype)fatalLevel;
+ (instancetype)criticalLevel;      // critical是为我们需要的特殊操作的level，我们可以定制弹出alert和上传log等操作，凡是intValue小于critical的都会执行这写操作
+ (instancetype)errorLevel;
+ (instancetype)warnLevel;
+ (instancetype)infoLevel;
+ (instancetype)debugLevel;

- (id)initLevelWith:(int)aLevel;

- (BOOL)severityIsGreaterThanOrEqualTo:(LogLevel*)aLevel;

@end

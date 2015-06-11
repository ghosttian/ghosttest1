//
//  GinDateFormatter.h
//  microChannel
//
//  Created by leizhu on 13-8-8.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinDateFormatter : NSDateFormatter

@property (nonatomic, assign) BOOL timeIs24HourFormat;

+ (GinDateFormatter *)sharedFormatter;

+ (NSString *)naturalStringFromDate:(NSDate *)date;
+ (NSString *)naturalStringFromTimeStamp:(time_t)timeStamp;
+ (NSString *)naturalStringFromTimeStamp:(time_t)timeStamp truncateTime:(BOOL)truncate;
+ (NSString *)dateStringFromDate:(NSDate *)date;
+ (NSString *)dayStringFromDate:(NSDate *)date;
+ (NSString *)currentDateStringWithFormat:(NSString *)format;

@end

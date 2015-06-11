//
//  GinDateFormatter.m
//  microChannel
//
//  Created by leizhu on 13-8-8.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinDateFormatter.h"
#import "NSDate+Plus.h"

@implementation GinDateFormatter

+ (GinDateFormatter *)sharedFormatter {
    static GinDateFormatter *dateFormatter = nil;
    
    @synchronized(self) {
        if (dateFormatter == nil) {
            dateFormatter = [[GinDateFormatter alloc] init];
        }
    }
    return dateFormatter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.timeIs24HourFormat = [self is24HourFormat:self];
    }
    return self;
}

- (BOOL)is24HourFormat:(NSDateFormatter *)formatter {
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    return (amRange.location == NSNotFound && pmRange.location == NSNotFound);
}

- (NSString *)naturalStringFromDate:(NSDate *)date {
    return [self naturalStringFromDate:date truncateTime:NO];
}

- (NSString *)naturalStringFromDate:(NSDate *)date truncateTime:(BOOL)truncate {
    NSString *dateString = nil;
    NSInteger offset = [date compareWithTodayWithDateFormatter:self];
    //今天
    if(offset == 0) {
        self.dateFormat = @"HH:mm";
        dateString = [NSString stringWithFormat:@"今天 %@", [self stringFromDate:date]];
    }
    //昨天
    else if(offset == -1) {
        self.dateFormat = @"HH:mm";
        dateString = [NSString stringWithFormat:@"昨天 %@", [self stringFromDate:date]];
    }
    //其它
    else {
        self.dateFormat = @"yyyy";
        NSString *old = [self stringFromDate:date];
        NSString *now = [self stringFromDate:[NSDate date]];
        if ([old isEqualToString:now]) {
            self.dateFormat = @"M月d日 HH:mm";
        } else {
            if (truncate) {
                self.dateFormat = @"yyyy年M月d日";
            } else {
                self.dateFormat = @"yyyy年M月d日 HH:mm";
            }
        }
        dateString = [NSString stringWithFormat:@"%@", [self stringFromDate:date]];
    }
    return dateString;
}

- (NSString *)naturalStringFromTimeStamp:(time_t)timeStamp {
    return [self naturalStringFromTimeStamp:timeStamp truncateTime:NO];
}

- (NSString *)naturalStringFromTimeStamp:(time_t)timeStamp truncateTime:(BOOL)truncate {
    NSString *naturalString = nil;
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, timeStamp);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        //naturalString = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
        naturalString = @"刚刚";
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        naturalString = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }
    else {
        return [self naturalStringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp] truncateTime:truncate];
    }
    return naturalString;
}

+ (NSString *)naturalStringFromDate:(NSDate *)date {
    return [[GinDateFormatter sharedFormatter] naturalStringFromDate:date];
}

+ (NSString *)naturalStringFromTimeStamp:(time_t)timeStamp {
    return [[GinDateFormatter sharedFormatter] naturalStringFromTimeStamp:timeStamp];
}

+ (NSString *)naturalStringFromTimeStamp:(time_t)timeStamp truncateTime:(BOOL)truncate {
    return [[GinDateFormatter sharedFormatter] naturalStringFromTimeStamp:timeStamp truncateTime:truncate];
}

+ (NSString *)dateStringFromDate:(NSDate *)date;
{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    NSDate *todate = [NSDate date];
    [[NSDate date] timeIntervalSince1970];
    formatter.dateFormat = @"yyyy年M月d日 HH:mm:ss";
    return [formatter stringFromDate:todate];
}

+ (NSString *)dayStringFromDate:(NSDate *)date{
    if(date == nil){
        return nil;
    }
    [[GinDateFormatter sharedFormatter] setDateFormat:@"yyyy.MM.dd"];
    return [[GinDateFormatter sharedFormatter] stringFromDate:date];
}

+ (NSString *)currentDateStringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    NSDate *todate = [NSDate date];
    [[NSDate date] timeIntervalSince1970];
    if (format) {
        formatter.dateFormat = format;
    } else {
        formatter.dateFormat = @"yyyy/MM/dd";
    }
    return [formatter stringFromDate:todate];
}

+ (NSString *)dateStringFromTimeStamp:(time_t)timeStamp {
    return @"";
}

@end

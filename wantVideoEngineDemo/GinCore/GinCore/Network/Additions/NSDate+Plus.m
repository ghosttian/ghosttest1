//
//  NSDate+Plus.m
//  microChannel
//
//  Created by leizhu on 13-8-8.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSDate+Plus.h"

@implementation NSDate (Plus)

/*
 * 与今天的时间做比较
 */
- (NSInteger)compareWithToday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	return [self compareWithTodayWithDateFormatter:formatter];
}

- (NSInteger)compareWithTodayWithDateFormatter:(NSDateFormatter *)dateFormatter {
    NSDate *today = [NSDate date];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	NSString *todayStr = [dateFormatter stringFromDate:today];
	today = [dateFormatter dateFromString:todayStr];
	
	NSInteger interval = (NSInteger) [self timeIntervalSinceDate:today];
	
	NSInteger intervalDate = 0;
	if (interval <= 0) {
		intervalDate = interval / (24 * 60 * 60) - 1;
	} else {
		intervalDate = interval / (24 * 60 * 60);
	}
	return intervalDate;
}

@end

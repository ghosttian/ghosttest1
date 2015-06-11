//
//  NSDate+Plus.h
//  microChannel
//
//  Created by leizhu on 13-8-8.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Plus)

- (NSInteger)compareWithToday;
- (NSInteger)compareWithTodayWithDateFormatter:(NSDateFormatter *)dateFormatter;
    
@end

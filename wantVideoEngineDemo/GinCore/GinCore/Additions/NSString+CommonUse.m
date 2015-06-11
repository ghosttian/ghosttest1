//
//  NSString+CommonUse.m
//  microChannel
//
//  Created by wangqi on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "NSString+CommonUse.h"

@implementation NSString (CommonUse)

+ (BOOL)isEmptyString:(NSString*)localString
{
    if (0 == localString.length)
    {
        return YES;
    }
    
    // 将localString去除所有的空白字符串
    NSString *tmpString = [localString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (0 == [tmpString length])
    {
        return YES;
    }
    
    return NO;
    
}

@end

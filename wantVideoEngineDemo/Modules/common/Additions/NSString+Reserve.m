//
//  NSString+Reserve.m
//  microChannel
//
//  Created by minghuiji on 13-11-26.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSString+Reserve.h"

@implementation NSString (Reserve)
//字符串反转
- (NSString *)reserve
{
    if (self.length > 0) {
        NSMutableString *reserve = [NSMutableString stringWithCapacity:self.length];
        for (int i = self.length - 1; i > -1; --i) {
            unichar c = [self characterAtIndex:i];
            [reserve appendFormat:@"%C", c];
        }
        return reserve;
    }
    return nil;
}
@end

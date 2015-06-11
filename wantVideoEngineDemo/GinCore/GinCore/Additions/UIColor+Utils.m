//
//  UIColor+Utils.m
//  microChannel
//
//  Created by aidenluo on 2/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "UIColor+Utils.h"

@implementation UIColor (Utils)

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    return [self colorWithRGBHex:hex alpha:1.0];
}

+ (UIColor*)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = hex & 0xFF;
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:alpha];
}

+ (UIColor*)randomColor
{
    return [UIColor colorWithRed:arc4random() % 255 /255.0f green:arc4random() % 255 /255.0f blue:arc4random() % 255 /255.0f alpha:1];
}

@end

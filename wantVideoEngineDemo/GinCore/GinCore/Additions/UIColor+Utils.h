//
//  UIColor+Utils.h
//  microChannel
//
//  Created by aidenluo on 2/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor*)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIColor*)randomColor;

@end

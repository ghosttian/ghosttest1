//
//  CALayer+GinMarkBorder.m
//  microChannel
//
//  Created by eson on 14-6-10.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "CALayer+GinMarkBorder.h"

@implementation CALayer (GinMarkBorder)

- (void)markBorderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth
{
    self.borderWidth = borderWidth;
    self.borderColor = color.CGColor;
}

- (void)markBorderWithColor:(UIColor *)color
{
    [self markBorderWithColor:color borderWidth:1.0f];
}

- (void)markBorderWithRandomColor
{
    self.borderColor = [UIColor colorWithRed:(arc4random() % 255 )/ 255.f
									   green:(arc4random() % 255 )/ 255.f
										blue:(arc4random() % 255 )/ 255.f
									   alpha:1].CGColor;
    self.borderWidth = 1.0f;
}

- (void)markBorderWithRandomColorRecursive
{
    [self markBorderWithRandomColor];
    
    for (UIView *layer in self.sublayers) {
        [layer markBorderWithRandomColorRecursive];
    }
}

@end

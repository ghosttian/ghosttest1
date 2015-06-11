//
//  UIView+MarkBorder.m
//  microChannel
//
//  Created by eson on 13-11-20.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "UIView+MarkBorder.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (MarkBorder)

- (void)markBorderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = color.CGColor;
}

- (void)markBorderWithColor:(UIColor *)color
{
    [self markBorderWithColor:color borderWidth:1.0f];
}

- (void)markBorderWithRandomColor
{
    self.layer.borderColor = [UIColor colorWithRed:(arc4random() % 255 )/ 255.f green:(arc4random() % 255 )/ 255.f blue:(arc4random() % 255 )/ 255.f alpha:1].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)markBorderWithRandomColorRecursive
{
    [self markBorderWithRandomColor];
    
    for (UIView *v in self.subviews) {
        [v markBorderWithRandomColorRecursive];
    }
}
@end
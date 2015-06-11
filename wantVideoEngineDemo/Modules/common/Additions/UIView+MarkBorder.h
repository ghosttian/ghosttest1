//
//  UIView+MarkBorder.h
//  microChannel
//
//  Created by eson on 13-11-20.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MarkBorder)

/* 你懂得~ 造福人类
 */
- (void)markBorderWithColor:(UIColor *)color;

/*  mark view's layer border with random color
 */
- (void)markBorderWithRandomColor;

/*   mark view's layer border with random color Recursive meam mark the all view tree
 */
- (void)markBorderWithRandomColorRecursive;

- (void)markBorderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth;

@end
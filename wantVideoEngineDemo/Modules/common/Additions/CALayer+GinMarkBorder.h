//
//  CALayer+GinMarkBorder.h
//  microChannel
//
//  Created by eson on 14-6-10.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (GinMarkBorder)

- (void)markBorderWithColor:(UIColor *)color;

/*  mark view's layer border with random color
 */
- (void)markBorderWithRandomColor;

/*   mark view's layer border with random color Recursive meam mark the all view tree
 */
- (void)markBorderWithRandomColorRecursive;

- (void)markBorderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth;

@end

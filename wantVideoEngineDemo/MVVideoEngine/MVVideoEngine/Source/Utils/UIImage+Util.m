//
//  UIImage+CreateFromView.m
//  microChannel
//
//  Created by wangxiaotang on 14-7-2.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Util.h"

@implementation UIImage (Util)


+ (UIImage *)imageFromView:(UIView *)aView size:(CGSize) aSize
{
    UIGraphicsBeginImageContextWithOptions(aSize, aView.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [aView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage *)imageFromLayer:(CALayer *)layer size:(CGSize) aSize
{
	UIGraphicsBeginImageContextWithOptions(aSize, layer.opaque, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[layer renderInContext:context];
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return theImage;
}

+ (UIImage *)imageFromView:(UIView *)aView
{
    CGSize size = aView.frame.size;
    return [UIImage imageFromView:aView size:size];
}



@end

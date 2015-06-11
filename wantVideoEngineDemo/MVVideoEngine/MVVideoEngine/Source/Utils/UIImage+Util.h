//
//  UIImage+CreateFromView.h
//  microChannel
//
//  Created by wangxiaotang on 14-7-2.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

+ (UIImage *)imageFromView:(UIView *)aView size:(CGSize) aSize;

+ (UIImage *)imageFromView:(UIView *)aView;

+ (UIImage *)imageFromLayer:(CALayer *)layer size:(CGSize) aSize;

@end

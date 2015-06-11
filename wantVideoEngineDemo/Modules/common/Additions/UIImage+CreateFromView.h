//
//  UIImage+CreateFromView.h
//  microChannel
//
//  Created by wangxiaotang on 14-7-2.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CreateFromView)

+ (UIImage *)imageFromView:(UIView *)aView size:(CGSize) aSize;

+ (UIImage *)imageFromView:(UIView *)aView;

@end

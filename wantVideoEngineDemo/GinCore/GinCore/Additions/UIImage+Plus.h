//
//  UIImage+Plus.h
//  GinCore
//
//  Created by leizhu on 14/12/5.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Plus)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)extensionImageNamed:(NSString *)name; //extension从container中读取图片

@end

//
//  UIImage+Plus.m
//  GinCore
//
//  Created by leizhu on 14/12/5.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "UIImage+Plus.h"

@implementation UIImage (Plus)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f,0.0f,40.0f,30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f,0.0f,size.width,size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)extensionImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    if (!image) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"../../%@", name]];
    }
    return image;
}

@end

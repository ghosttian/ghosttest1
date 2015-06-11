//
//  UIImage+Round.h
//  microChannel
//
//  Created by leizhu on 13-12-31.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Round)

+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)radius;

@end

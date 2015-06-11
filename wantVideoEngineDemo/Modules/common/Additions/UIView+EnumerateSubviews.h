//
//  UIView+enumerateSubviews.h
//  microChannel
//
//  Created by zhulei on 13-6-8.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EnumerateSubviews)

- (void)recursiveEnumerateSubviewsUsingBlock:(void (^)(UIView *view, BOOL *stop))block;

@end

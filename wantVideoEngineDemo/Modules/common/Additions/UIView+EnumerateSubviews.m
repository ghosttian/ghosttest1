//
//  UIView+enumerateSubviews.m
//  microChannel
//
//  Created by zhulei on 13-6-8.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "UIView+enumerateSubviews.h"

@implementation UIView (EnumerateSubviews)

- (void)recursiveEnumerateSubviewsUsingBlock:(void (^)(UIView *view, BOOL *stop))block {
	if (self.subviews.count == 0) {
		return;
	}
	for (UIView *subview in [self subviews]) {
		BOOL stop = NO;
		block(subview, &stop);
		if (stop) {
			return;
		}
		[subview recursiveEnumerateSubviewsUsingBlock:block];
	}
}

@end

//
//  UIButton+VerticalLayout.m
//  microChannel
//
//  Created by leizhu on 13-6-24.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "UIButton+VerticalLayout.h"

@implementation UIButton (VerticalLayout)


- (void)verticalLayoutWithPadding:(CGFloat)padding {
    
    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + padding), 0.0);
    
    CGSize titleSize = self.titleLabel.frame.size;
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + padding), 0.0, 0.0, - titleSize.width);
}

@end

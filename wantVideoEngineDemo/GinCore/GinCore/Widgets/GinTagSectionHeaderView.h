//
//  GinTagSectionHeaderView.h
//  microChannel
//
//  Created by leizhu on 13-7-2.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GinTagSectionHeaderView : UIView

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIImage *tipsImage;

+ (GinTagSectionHeaderView *)headerViewWithTitle:(NSString *)title;
+ (GinTagSectionHeaderView *)headerViewWithTitle:(NSString *)title tipsImage:(UIImage *)image;

@end

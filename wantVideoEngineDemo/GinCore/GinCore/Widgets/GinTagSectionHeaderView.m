//
//  GinTagSectionHeaderView.m
//  microChannel
//
//  Created by leizhu on 13-7-2.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinTagSectionHeaderView.h"
#import "UIColor+Utils.h"

#define kHeight 30

@implementation GinTagSectionHeaderView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor colorWithRGBHex:0xffeeeeee alpha:1.0];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width, frame.size.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

+ (GinTagSectionHeaderView *)headerViewWithTitle:(NSString *)title {
    return [self headerViewWithTitle:title tipsImage:nil];
}

+ (GinTagSectionHeaderView *)headerViewWithTitle:(NSString *)title tipsImage:(UIImage *)image {
    GinTagSectionHeaderView *header = [[GinTagSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeight)];
    header.titleLabel.text = title;
    if (image) {
        CGSize textSize = [title sizeWithFont:header.titleLabel.font];
        UIImageView *tipsView = [[UIImageView alloc] initWithFrame:CGRectMake(10+textSize.width+4, (kHeight-image.size.height)/2.0, image.size.width, image.size.height)];
        tipsView.image = image;
        [header addSubview:tipsView];
    }
    return header;
}

@end

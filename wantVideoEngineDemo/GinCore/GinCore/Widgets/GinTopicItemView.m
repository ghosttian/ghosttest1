//
//  GinTopicItemView.m
//  GinCore
//
//  Created by leizhu on 14/12/11.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinTopicItemView.h"
#import "UIColor+Utils.h"
#import "UIImage+Plus.h"

#define kDeviceWidth MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#define kItemWidth kDeviceWidth/2.0

@interface GinTopicItemView ()

@property(nonatomic,strong) UIImageView *markView;

@end

@implementation GinTopicItemView

- (UIImageView *)markView {
    if (!_markView) {
        UIImage *markIcon = [UIImage extensionImageNamed:@"ic_post_theme_selected"];
        _markView = [[UIImageView alloc] initWithImage:markIcon];
        _markView.frame = CGRectMake(kItemWidth-markIcon.size.width, 0, markIcon.size.width, markIcon.size.height);
    }
    return _markView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRGBHex:0xff22cccc] forState:UIControlStateSelected];
        
        CALayer *bottom = [CALayer layer];
        bottom.backgroundColor = [UIColor colorWithRGBHex:0xffdddddd alpha:1.0].CGColor;
        bottom.frame = CGRectMake(0, frame.size.height-1, frame.size.width, 1);
        [self.layer addSublayer:bottom];
        
        
    }
    return self;
}

- (void)showRightSeperator {
    CALayer *right = [CALayer layer];
    right.backgroundColor = [UIColor colorWithRGBHex:0xffdddddd alpha:1.0].CGColor;
    right.frame = CGRectMake(self.frame.size.width-1, 0, 1, self.frame.size.height);
    [self.layer addSublayer:right];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (!self.markView.superview) {
        [self addSubview:self.markView];
    }
    self.markView.hidden = !selected;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xfff1f3f3 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end

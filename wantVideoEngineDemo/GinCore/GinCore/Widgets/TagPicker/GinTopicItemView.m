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
        UIImage *markIcon = [[UIImage extensionImageNamed:@"ic_post_theme_select"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 5, 5, 40)];
        _markView = [[UIImageView alloc] initWithImage:markIcon];
        _markView.frame = self.bounds;
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
        [self setTitleColor:[UIColor colorWithRGBHex:0xff55aaee] forState:UIControlStateSelected];
        
        CALayer *bottom = [CALayer layer];
        bottom.backgroundColor = [UIColor colorWithRGBHex:0xffdddddd].CGColor;
        bottom.frame = CGRectMake(0, frame.size.height-1, frame.size.width, 1);
        [self.layer addSublayer:bottom];
        
        //self.layer.borderWidth = 1.0;
        //self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)showRightSeperator {
    CALayer *right = [CALayer layer];
    right.backgroundColor = [UIColor colorWithRGBHex:0xffdddddd].CGColor;
    right.frame = CGRectMake(self.frame.size.width-1, 0, 1, self.frame.size.height);
    [self.layer addSublayer:right];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (!self.markView.superview) {
        [self addSubview:self.markView];
    }
    self.markView.hidden = !selected;
    
//    if (selected) {
//        self.layer.borderColor = [UIColor colorWithRGBHex:0xff55aaee].CGColor;
//        self.layer.borderWidth = 1.0;
//    } else {
//        self.layer.borderColor = [UIColor colorWithRGBHex:0xffdddddd].CGColor;
//        self.layer.borderWidth = 0.5;
//    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xfff1f3f3];
        //self.layer.borderColor = [UIColor colorWithRGBHex:0xff55aaee].CGColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        //self.layer.borderColor = [UIColor colorWithRGBHex:0xffdddddd].CGColor;
    }
}

@end

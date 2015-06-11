//
//  GinBorderedButton.m
//  microChannel
//
//  Created by leizhu on 13-12-27.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinBorderedButton.h"
#import "UIColor+Utils.h"

@implementation GinBorderedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 3.0f;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor colorWithRGBHex:0xff44bbcc alpha:1.0].CGColor;
        
        [self setTitleColor:[UIColor colorWithRGBHex:0xff44bbcc alpha:1.0] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xff44bbcc alpha:1.0];
    } else {
        self.backgroundColor =[UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xff44bbcc alpha:1.0];
    } else {
        self.backgroundColor =[UIColor whiteColor];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        self.layer.borderColor = [UIColor colorWithRGBHex:0xff44bbcc alpha:1.0].CGColor;
    } else {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

@end

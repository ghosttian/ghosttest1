//
//  GinToken.m
//  GinTokenFieldDemo
//
//  Created by leizhu on 13-12-17.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import "GinToken.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Utils.h"

@implementation GinToken


- (id)initWithTitle:(NSString *)title {
    return [self initWithTitle:title object:nil];
}

- (id)initWithTitle:(NSString *)title object:(id)object {
    self = [super init];
    if (self) {
        [self setFont:[UIFont systemFontOfSize:kGinTokenFontSize]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setContentEdgeInsets:kGinTokenEdgeInsets];
        [self setTitle:title forState:UIControlStateNormal];
        [self setObject:object];
        [self.layer setCornerRadius:5.0];
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    [self.titleLabel setFont:font];
    [self sizeToFit];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xff44bbcc alpha:1.0];
    } else {
        self.backgroundColor = [UIColor colorWithRGBHex:0xff888888 alpha:1.0];
    }
}

- (void)setMaxWidth:(CGFloat)maxWidth {
    if (_maxWidth != maxWidth) {
        _maxWidth = maxWidth;
        
        [self sizeToFit];
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[GinToken class]]) {
        return [self.titleLabel.text isEqualToString:((GinToken *)object).titleLabel.text];
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end

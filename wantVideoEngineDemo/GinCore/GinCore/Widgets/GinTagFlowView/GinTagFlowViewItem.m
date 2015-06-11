//
//  GinTagFlowViewItem.m
//  GinTagFlow
//
//  Created by leizhu on 13-6-29.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import "GinTagFlowViewItem.h"
#import "UIColor+Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Plus.h"

#define kDefaultTextPadding 8.0f
#define kDefaultFontSize 14.0f

@interface GinTagFlowViewItem () <UIGestureRecognizerDelegate>

@property(nonatomic,strong) UIButton *maskButton; //disable状态是需要
@property(nonatomic,strong) UIImageView *cornerIconView;

@end

@implementation GinTagFlowViewItem


- (id)initWithFrame:(CGRect)frame {
    return [self initWithReuseIdentifier:nil];
}

- (id)init {
    return [self initWithReuseIdentifier:nil];
}

- (id)initWithReuseIdentifier:(NSString *)identifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.layer.cornerRadius = 5.0f;
        self.layer.borderWidth = 1.0;

        _enabled = YES;
        _bgColor = [UIColor whiteColor];
        //_selectedBgColor = [UIColor colorWithRGBHex:0xff22cccc alpha:1.0];
        
        _maskButton = [[UIButton alloc] init];
        _maskButton.enabled = NO;
        _maskButton.alpha = .0;
        _maskButton.backgroundColor = [UIColor whiteColor];
        
        _textPadding = kDefaultTextPadding;
        
        _reuseIdentifier = identifier;
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.highlightedTextColor = [UIColor colorWithRGBHex:0xff22cccc];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.font = [UIFont systemFontOfSize:kDefaultFontSize];
        [self addSubview:_textLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
        longPress.delegate = self;
        longPress.cancelsTouchesInView = NO;
        [self addGestureRecognizer:longPress];
        
        [self setStateSelected:NO];
        
        self.clipsToBounds = NO;
    }
    return self;
}

- (UIImageView *)cornerIconView {
    if (!_cornerIconView) {
        if (!self.cornerIcon) {
            self.cornerIcon = [UIImage extensionImageNamed:@"ic_post_theme_hot_selected"];
        }
        _cornerIconView = [[UIImageView alloc] initWithImage:self.cornerIcon];
        _cornerIconView.frame = CGRectMake(0, 0, self.cornerIcon.size.width, self.cornerIcon.size.height);
    }
    return _cornerIconView;
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        if (enabled) {
            [self.maskButton removeFromSuperview];
        } else {
            [self addSubview:self.maskButton];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(_textPadding, 0, self.frame.size.width-2*_textPadding, self.frame.size.height);
    self.maskButton.frame = CGRectInset(self.bounds, -5, -5);
}

- (void)prepareForReuse {
    self.textLabel.text = nil;
    [self setSelected:NO animated:NO];
    self.delegate = nil;
    self.index = 0;
}

//- (void)setHighlighted:(BOOL)highlighted {
//    if (!self.enabled) {
//        return;
//    }
//    _highlighted = highlighted;
//    
//    [self setStateSelected:highlighted];
//}

- (void)setStateSelected:(BOOL)selected {
    if (selected) {
        //self.backgroundColor = self.selectedBgColor;
        self.textLabel.textColor = [UIColor colorWithRGBHex:0xff22cccc];
        self.layer.borderColor = [UIColor colorWithRGBHex:0xff22cccc].CGColor;
        if (!self.cornerIconView.superview) {
            [self addSubview:self.cornerIconView];
            self.cornerIconView.frame = CGRectMake(self.frame.size.width-self.cornerIconView.frame.size.width, 0, self.cornerIconView.frame.size.width, self.cornerIconView.frame.size.height);
        }
        self.cornerIconView.hidden = NO;
    } else {
        //self.backgroundColor = self.bgColor;
        self.textLabel.textColor = [UIColor blackColor];
        self.layer.borderColor = [UIColor colorWithRGBHex:0xffdddddd].CGColor;
        self.cornerIconView.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    _selected = selected;
    if (animated) {
        [UIView animateWithDuration:.1 animations:^{
            [self setStateSelected:selected];
        }];
    } else {
        [self setStateSelected:selected];
    }
}

#pragma mark -
#pragma mark Touch 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selected = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selected = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selected = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Action methods

- (void)actionTap:(UIGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(didTapOnItem:)]) {
        [self.delegate didTapOnItem:self];
    }
}

- (void)actionLongPress:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(didLongPressOnItem:)]) {
            [self.delegate didLongPressOnItem:self];
        }
    } 
}

@end

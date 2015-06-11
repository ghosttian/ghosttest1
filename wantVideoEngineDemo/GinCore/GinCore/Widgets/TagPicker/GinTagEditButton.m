//
//  GinTagEditButton.m
//  GinCore
//
//  Created by leizhu on 15/1/16.
//  Copyright (c) 2015年 leizhu. All rights reserved.
//

#import "GinTagEditButton.h"
#import "UIColor+Utils.h"
#import "UIImage+Plus.h"

@interface GinTagEditButton ()

@property(nonatomic,strong) UIImageView *editIconView;

@end

@implementation GinTagEditButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel.textColor = [UIColor colorWithRGBHex:0xff949494];
        self.cornerIcon = [UIImage extensionImageNamed:@"ic_post_theme_diy_selected"];
        UIImage *editIcon = [UIImage extensionImageNamed:@"g_post_icon_diy_nor"];
        self.editIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, editIcon.size.width, editIcon.size.height)];
        self.editIconView.image = editIcon;
        self.editIconView.highlightedImage = [UIImage extensionImageNamed:@"g_post_icon_diy_press"];
        self.editIconView.hidden = YES;
        [self addSubview:self.editIconView];
        
        self.placeHolder = @"添加个性标签";
        self.text = nil;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    if (highlighted) {
        self.editIconView.highlighted = YES;
    } else {
        self.editIconView.highlighted = NO;
        self.textLabel.textColor = [UIColor colorWithRGBHex:0xff949494];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.editIconView.highlighted = YES;
    } else {
        self.editIconView.highlighted = NO;
        self.textLabel.textColor = [UIColor colorWithRGBHex:0xff949494];
    }
}

- (void)setText:(NSString *)text {
    if (!text) {
        self.textLabel.text = self.placeHolder;
        self.editIconView.hidden = YES;
    } else {
        self.textLabel.text = text;
        self.editIconView.hidden = NO;
    }
    [self setNeedsLayout];
}

- (NSString *)text {
    return self.textLabel.text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    
    CGRect rect = self.editIconView.frame;
    rect.origin = CGPointMake(self.textPadding + size.width + 6, (self.frame.size.height-rect.size.height)/2.0);
    self.editIconView.frame = rect;
}

@end

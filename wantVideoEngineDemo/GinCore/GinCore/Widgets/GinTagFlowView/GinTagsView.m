//
//  GinTagsView.m
//  microChannel
//
//  Created by leizhu on 13-7-18.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinTagsView.h"
#import "GinTagFlowViewItem.h"
#import "UIColor+Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Addtion.h"
#import "UIImage+Plus.h"

#define kTextPaddingLeft 5.0
#define kDefaultItemHeight 20.0
#define kDefaultItemMarginX 5.0
#define kDefaultItemMarginY 10.0
#define kDefaultEdgeInsets UIEdgeInsetsMake(0, 0, 0, 0)
#define kTagFont 12.0

@interface GinTagsView () {
    CGFloat _itemHeight;
    CGFloat _itemMarginX;
    CGFloat _itemMarginY;
}

@property (nonatomic,strong) NSMutableArray *itemViews;

@end

@implementation GinTagsView

- (void)dealloc {
    self.clickBlock = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _itemHeight = kDefaultItemHeight;
        _itemMarginX = kDefaultItemMarginX;
        _itemMarginY = kDefaultItemMarginY;
        _edgeInsets = kDefaultEdgeInsets;
        
        _itemViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setTags:(NSArray *)tags {
    if (_tags != tags) {
        _tags = tags;
        
        [self.itemViews removeAllObjects];
        [self removeSubviews];
        for (NSString *tag in tags) {
            UIButton *button = [self buttonWithTag:tag];
            [self.itemViews addObject:button];
        }
    }
}

- (UIButton *)buttonWithTag:(NSString *)tag {
    UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [itemButton setTitleColor:[UIColor colorWithRGBHex:0xff97999c alpha:1.0] forState:UIControlStateNormal];
    [itemButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0xffe5e5e5 alpha:1.0]] forState:UIControlStateHighlighted];
    itemButton.titleLabel.font = [UIFont systemFontOfSize:kTagFont];
    itemButton.layer.cornerRadius = 2;
    itemButton.layer.masksToBounds = YES;
    [itemButton setTitle:tag forState:UIControlStateNormal];
    [itemButton addTarget:self action:@selector(actionClickTag:) forControlEvents:UIControlEventTouchUpInside];
    return itemButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self renderItems];
}

- (void)renderItems {
    NSInteger line = 1;
    CGFloat nextItemX = _edgeInsets.left;
    CGFloat nextItemY = _edgeInsets.top;
    
    for (int index=0; index<self.itemViews.count; index++) {
        UIButton *itemButton = [self.itemViews objectAtIndex:index];
        CGFloat itemWidth = [itemButton.titleLabel.text sizeWithFont:itemButton.titleLabel.font constrainedToSize:CGSizeMake(1000, _itemHeight)].width + 2*kTextPaddingLeft;
        
        CGFloat contentWidth = self.frame.size.width - _edgeInsets.left - _edgeInsets.right;
 
        if (nextItemX+itemWidth > contentWidth) {
            line ++;
            nextItemX = _edgeInsets.left;
            if (line > 1) {
                nextItemY += (_itemHeight + _itemMarginY);
            }
        }
        CGRect itemRect = CGRectMake(nextItemX, nextItemY, itemWidth, _itemHeight);
        itemButton.frame = itemRect;
        nextItemX += itemWidth + _itemMarginX;
        if (itemButton.superview == nil) {
            [self addSubview:itemButton];
        }
    }

    CGSize contentSize = CGSizeMake(self.frame.size.width, line*(_itemHeight+_itemMarginY)-_itemMarginY+_edgeInsets.top+_edgeInsets.bottom);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentSize.width, contentSize.height);
}

+ (CGFloat)heightForTags:(NSArray *)tags {
    if (tags.count == 0) {
        return 0;
    }
    
    NSInteger line = 1;
    CGFloat edgeLeft = 0;
    CGFloat nextItemX = 0;
    CGFloat nextItemY = 0;
    
    UIFont *font = [UIFont systemFontOfSize:kTagFont];
    for (int index=0; index<tags.count; index++) {
        NSString *tag = [tags objectAtIndex:index];
        CGFloat itemWidth = [tag sizeWithFont:font constrainedToSize:CGSizeMake(1000, kDefaultItemHeight)].width + 2*kTextPaddingLeft;
        
        CGFloat contentWidth = 300 - edgeLeft*2;
        if (nextItemX+itemWidth > contentWidth) {
            line ++;
            nextItemX = edgeLeft;
            if (line > 1) {
                nextItemY += (kDefaultItemHeight + kDefaultItemMarginY);
            }
        }
        nextItemX += itemWidth + kDefaultItemMarginX;
    }
    
    CGFloat height = line*(kDefaultItemHeight+kDefaultItemMarginY)-kDefaultItemMarginY;
    return height;
}

- (void)actionClickTag:(UIButton *)button {
    if (self.clickBlock) {
        self.clickBlock(button.titleLabel.text);
    }
}


@end

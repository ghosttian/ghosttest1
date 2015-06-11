//
//  GinTagFlowViewItem.h
//  GinTagFlow
//
//  Created by leizhu on 13-6-29.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GinTagFlowViewItemTypeDefault,  //动态根据text计算frame
    GinTagFlowViewItemTypeCustom,   //取预设的frame
} GinTagFlowViewItemType;

@protocol GinTagFlowItemDelegate;
@interface GinTagFlowViewItem : UIView 

@property (nonatomic, weak) id<GinTagFlowItemDelegate> delegate;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *selectedBgColor;
@property (nonatomic, strong) UIImage *cornerIcon;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, assign) BOOL editing;

@property (nonatomic, assign) CGFloat textPadding;          //文字距两边的空间
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) GinTagFlowViewItemType type;
@property (nonatomic, assign) BOOL enabled;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (id)initWithReuseIdentifier:(NSString *)identifier;
- (void)prepareForReuse;


@end


@protocol GinTagFlowItemDelegate <NSObject>

- (void)didTapOnItem:(GinTagFlowViewItem *)item;
- (void)didLongPressOnItem:(GinTagFlowViewItem *)item;

@end
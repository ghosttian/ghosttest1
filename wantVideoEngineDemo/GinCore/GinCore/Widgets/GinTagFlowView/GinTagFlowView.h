//
//  GinTagFlowView.h
//  GinTagFlow
//
//  Created by leizhu on 13-6-29.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GinTagFlowViewItem.h"

@protocol GinTagFlowViewDelegate, GinTagFlowViewDataSource;
@interface GinTagFlowView : UIScrollView

@property (nonatomic, weak) id<GinTagFlowViewDelegate> tagDelegate;
@property (nonatomic, weak) id<GinTagFlowViewDataSource> tagDataSource;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) CGFloat itemMarginY;
@property (nonatomic, assign) CGFloat itemMarginX;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat emptyItemWidth;   //如果插入自定义的
@property (nonatomic, assign) BOOL enableEditing;
@property (nonatomic, assign) BOOL enableEditWhenTap;   //单击进入编辑模式
@property (nonatomic, strong, readonly) NSMutableArray *items;

- (GinTagFlowViewItem *)dequeueItemWithReuseIdentifier:(NSString *)identifier;

- (void)reloadData;
- (void)removeItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addItemAnimated:(BOOL)animated;

- (void)cancelEditing;

@end

@protocol GinTagFlowViewDelegate <NSObject>

- (void)tagFlowView:(GinTagFlowView *)view didSelectItemAtIndex:(NSInteger)index;
- (void)tagFlowView:(GinTagFlowView *)view didRemoveItemAtIndex:(NSInteger)index;

@end

@protocol GinTagFlowViewDataSource <NSObject>

- (NSInteger)numberOfItemsInTagFlowView:(GinTagFlowView *)view;
- (GinTagFlowViewItem *)tagFlowView:(GinTagFlowView *)view itemForIndex:(NSInteger)index;

@optional
//- (CGFloat)tagFlowView:(GinTagFlowView *)view widthForItemAtIndex:(NSInteger)index;
- (BOOL)tagFlowView:(GinTagFlowView *)view canEditItemAtIndex:(NSInteger)index;

@end
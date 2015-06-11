//
//  GinTagFlowView.m
//  GinTagFlow
//
//  Created by leizhu on 13-6-29.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import "GinTagFlowView.h"

#define kRenderAnimationDuration 0.4
#define kItemFadeDuration 0.2

#define kDefaultItemHeight 28.0f
#define kDefaultItemMarginX 10.0
#define kDefaultItemMarginY 10.0
#define kDefaultEdgeInsets UIEdgeInsetsMake(10, 10, 10, 10)

@interface GinTagFlowView () <GinTagFlowItemDelegate>

@property (nonatomic, strong) NSMutableArray *reuseQueue;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign) CGPoint nextPosition;

@end

@implementation GinTagFlowView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _itemHeight = kDefaultItemHeight;
        _itemMarginX = kDefaultItemMarginX;
        _itemMarginY = kDefaultItemMarginY;
        _edgeInsets = kDefaultEdgeInsets;
        
        _reuseQueue = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        
        self.scrollEnabled = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Public methods

- (GinTagFlowViewItem *)dequeueItemWithReuseIdentifier:(NSString *)identifier {
    GinTagFlowViewItem *reuseItem = nil;
    for (GinTagFlowViewItem *item in self.reuseQueue) {
        if ([item.reuseIdentifier isEqualToString:identifier]) {
            reuseItem = item;
            [self.reuseQueue removeObject:item];
            break;
        }
    }
    [reuseItem prepareForReuse];
    return reuseItem;
}

- (void)reloadData {
    NSInteger itemCount = 0;
    if ([self.tagDataSource respondsToSelector:@selector(numberOfItemsInTagFlowView:)]) {
        itemCount = [self.tagDataSource numberOfItemsInTagFlowView:self];
    }
    for (GinTagFlowViewItem *item in self.items) {
        [self.reuseQueue addObject:item];
        [item removeFromSuperview];
    }
    [self.items removeAllObjects];
    for (int i=0; i<itemCount; i++) {
        if ([self.tagDataSource respondsToSelector:@selector(tagFlowView:itemForIndex:)]) {
            GinTagFlowViewItem *item = [self.tagDataSource tagFlowView:self itemForIndex:i];
            if ([self.tagDataSource respondsToSelector:@selector(tagFlowView:canEditItemAtIndex:)]) {
                BOOL canEdit = [self.tagDataSource tagFlowView:self canEditItemAtIndex:i];
                item.enabled = canEdit;
            }
            item.index = i;
            item.delegate = self;
            if (item.type == GinTagFlowViewItemTypeDefault) {
                 item.frame = CGRectZero;
            }
            [self.items addObject:item];
            [self addSubview:item];
        }
    }
    [self renderItemsAnimated:NO];
}

- (void)removeItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    GinTagFlowViewItem *item = [self.items objectAtIndex:index];
    [self.reuseQueue addObject:item];
    [self.items removeObject:item];
    [item removeFromSuperview];
    
    for (NSInteger i = index; i<self.items.count; i++) {
        GinTagFlowViewItem *item = [self.items objectAtIndex:i];
        item.index = i;
    }
    
    [self renderItemsFromIndex:0 toIndex:self.items.count animated:animated];
}

- (void)addItemAnimated:(BOOL)animated {
    [self insertItemAtIndex:self.items.count animated:animated];
}

- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0) index = 0;
    if (index > self.items.count) index = self.items.count;
    
    if ([self.tagDataSource respondsToSelector:@selector(tagFlowView:itemForIndex:)]) {
        GinTagFlowViewItem *item = [self.tagDataSource tagFlowView:self itemForIndex:index];
        item.index = index;
        item.delegate = self;
        if (item.type == GinTagFlowViewItemTypeDefault) {
            item.frame = CGRectZero;
        }
        item.alpha = 0;
        [self.items insertObject:item atIndex:index];
        [self addSubview:item];
        
        for (NSInteger i=index; i<self.items.count; i++) {
            GinTagFlowViewItem *item = [self.items objectAtIndex:i];
            item.index = i;
        }
        
        if (animated) {
            if (self.items.lastObject == item) {
                [self renderItemsFromIndex:0 toIndex:self.items.count animated:NO];
                [self fadeInItem:item];
            } else {
                [self renderItemsFromIndex:0 toIndex:self.items.count animated:YES];
                [self performSelector:@selector(fadeInItem:) withObject:item afterDelay:kRenderAnimationDuration+kItemFadeDuration];
            }
        } else {
            [self renderItemsFromIndex:0 toIndex:self.items.count animated:YES];
            item.alpha = 1.0f;
        }
    }
}

#pragma mark -
#pragma mark Private methods

- (void)fadeInItem:(GinTagFlowViewItem *)item {
    [UIView animateWithDuration:kItemFadeDuration animations:^{
        item.alpha = 1.0;
    }];
}

- (void)fadeOutItem:(GinTagFlowViewItem *)item {
    [UIView animateWithDuration:kItemFadeDuration animations:^{
        item.alpha = 0;
    }];
}

- (void)renderItemsAnimated:(BOOL)animated {
    [self renderItemsFromIndex:0 toIndex:self.items.count animated:animated];
}
- (void)renderItemsFromIndex:(NSInteger)from toIndex:(NSInteger)to animated:(BOOL)animated {
    NSInteger line = 1;
    CGFloat currentX = _edgeInsets.left;
    CGFloat currentY = _edgeInsets.top;
    CGRect currentRect;
    
    for (NSInteger index=from; index<to; index++) {
        GinTagFlowViewItem *item = [self.items objectAtIndex:index];
        [item setSelected:NO animated:animated];
        
        CGFloat itemWidth = 0;
        if (item.type == GinTagFlowViewItemTypeCustom) {
            itemWidth = item.frame.size.width;
        } else {
            itemWidth = [item.textLabel.text sizeWithFont:item.textLabel.font constrainedToSize:CGSizeMake(1000, _itemHeight)].width + 2*item.textPadding;
        }
        CGFloat contentWidth = self.frame.size.width - _edgeInsets.left - _edgeInsets.right;
        if (currentX + itemWidth > contentWidth + _edgeInsets.left) {
            if (currentX == _edgeInsets.left) {
                //第一个，本行显示
                if (itemWidth > contentWidth) {
                    //需要截断
                    currentRect = CGRectMake(currentX, currentY, contentWidth, _itemHeight);
                    currentY += (_itemHeight + _itemMarginY);
                    if (index != to - 1) line++;
                } else {
                    currentRect = CGRectMake(currentX, currentY, itemWidth, _itemHeight);
                    currentX += (itemWidth + _itemMarginX);
                }
            } else {
                //挪到下一行显示
                currentX = _edgeInsets.left;
                currentY += (_itemHeight + _itemMarginY);
                line++;
                if (itemWidth > contentWidth) {
                    currentRect = CGRectMake(currentX, currentY, contentWidth, _itemHeight);
                    currentX = _edgeInsets.left;
                    currentY += (_itemHeight + _itemMarginY);
                    if (index != to - 1) line++;
                } else {
                    currentRect = CGRectMake(currentX, currentY, itemWidth, _itemHeight);
                    currentX += (itemWidth + _itemMarginX);
                }
            }
        } else {
            currentRect = CGRectMake(currentX, currentY, itemWidth, _itemHeight);
            currentX += (itemWidth + _itemMarginX);
        }
        
        if (animated) {
            [UIView animateWithDuration:kRenderAnimationDuration animations:^{
                item.frame = currentRect;
            }];
        } else {
            item.frame = currentRect;
        }
    }
    
    if (animated) {
        [UIView animateWithDuration:kRenderAnimationDuration animations:^{
            self.contentSize = CGSizeMake(self.frame.size.width, line*(_itemHeight+_itemMarginY)-_itemMarginY+_edgeInsets.top+_edgeInsets.bottom);
            //TODO
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.contentSize.width, self.contentSize.height);
        }];
    } else {
        self.contentSize = CGSizeMake(self.frame.size.width, line*(_itemHeight+_itemMarginY)-_itemMarginY+_edgeInsets.top+_edgeInsets.bottom);
        //TODO
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.contentSize.width, self.contentSize.height);
    }
}

#pragma mark -
#pragma mark GinTagFlowItemDelegate

- (void)didTapOnItem:(GinTagFlowViewItem *)item {
    if ([self.tagDelegate respondsToSelector:@selector(tagFlowView:canEditItemAtIndex:)]) {
        BOOL canEdit = [self.tagDataSource tagFlowView:self canEditItemAtIndex:item.index];
        if (!canEdit) {
            return;
        }
    }
    if ([self.tagDelegate respondsToSelector:@selector(tagFlowView:didSelectItemAtIndex:)]) {
        [self.tagDelegate tagFlowView:self didSelectItemAtIndex:item.index];
    }
    //单击进入编辑模式
    if (self.enableEditWhenTap) {
        [self setEditing:!item.editing forItem:item];
    }
}

- (void)didLongPressOnItem:(GinTagFlowViewItem *)item {
    //单击进入编辑模式暂时disable Long press
    if (self.enableEditWhenTap) {
        return;
    }
    if (!self.enableEditing) {
        return;
    }
    if ([self.tagDelegate respondsToSelector:@selector(tagFlowView:canEditItemAtIndex:)]) {
        BOOL canEdit = [self.tagDataSource tagFlowView:self canEditItemAtIndex:item.index];
        if (!canEdit) {
            return;
        }
    }
    [self setEditing:!item.editing forItem:item];
}

- (void)didTapDeleteButton:(UIButton *)button {
    [self.deleteButton removeFromSuperview];
    self.deleteButton = nil;
    
    [self removeItemAtIndex:button.tag animated:YES];
    if ([self.tagDelegate respondsToSelector:@selector(tagFlowView:didRemoveItemAtIndex:)]) {
        [self.tagDelegate tagFlowView:self didRemoveItemAtIndex:button.tag];
    }
}

#pragma mark -
#pragma makr Other methods

- (void)cancelEditing {
    [self.deleteButton removeFromSuperview];
    self.deleteButton = nil;
}

- (void)setEditing:(BOOL)editing forItem:(GinTagFlowViewItem *)item {

    if (self.deleteButton) {
        if (self.deleteButton.tag == item.index) {
            if (!editing) {
                [self.deleteButton removeFromSuperview];
                self.deleteButton = nil;
            }
        } else {
            [self.deleteButton removeFromSuperview];
            UIButton *newButton = [self newDeleteButtonOnItem:item];
            [self addSubview:newButton];
            self.deleteButton = newButton;
        }
    } else {
        self.deleteButton = [self newDeleteButtonOnItem:item];
        [self addSubview:self.deleteButton];
    }
    item.editing = editing;
}

- (UIButton *)newDeleteButtonOnItem:(GinTagFlowViewItem *)item {
    //TODO
    UIImage *image = [UIImage imageNamed:@"channel_icon_deletebutton_nor"];
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(item.frame.origin.x-image.size.width/2.0+3, item.frame.origin.y-image.size.height/2.0+3, image.size.width, image.size.height)];
    [deleteButton setImage:image forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(didTapDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = item.index;
    return deleteButton;
}

@end

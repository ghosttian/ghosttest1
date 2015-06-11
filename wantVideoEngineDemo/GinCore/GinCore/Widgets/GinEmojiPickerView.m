//
//  GinEmojiPickerView.m
//  microChannel
//
//  Created by leizhu on 13-7-18.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinEmojiPickerView.h"
#import "GinPageControl.h"
#import "GinBorderedButton.h"
#import "UIImage+Plus.h"

#define kIconTag 1000
#define kIconSize 30

#define kDeviceWidth ([[UIScreen mainScreen] bounds].size.width)
#define kNumberOfItemPerRow 7
#define kNumberOfItemPerColumn 4

#define kPageControlHeight 10.0
#define kPageControlMarginBottom 10.0

#define kDefaultEdgeInsets UIEdgeInsetsMake(12, 17, 0, 17)
#define kEmojiWidth ((kDeviceWidth-kDefaultEdgeInsets.left-kDefaultEdgeInsets.right)/kNumberOfItemPerRow)
#define kEmojiHeight 45

@interface GinEmojiPickerView () <UIScrollViewDelegate, GinPageControlDelegate> {
    NSInteger numberOfItemPerPage;
    NSInteger pages;
    NSInteger actionPlace;
}

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, strong) NSMutableArray *icons;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) GinPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSMutableSet *sendButtons;

@end

@implementation GinEmojiPickerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _edgeInsets = kDefaultEdgeInsets;
        
        self.hideSendButton = NO; //默认显示发送按钮
        
        self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
        
        [self loadEmojiData];
        
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-kPageControlHeight-kPageControlMarginBottom)];
        _contentView.pagingEnabled = YES;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.delegate = self;
		_contentView.scrollsToTop = NO;
        [self addSubview:_contentView];
        
        
        _pageControl = [[GinPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height-kPageControlHeight-kPageControlMarginBottom, frame.size.width, kPageControlHeight)];
        _pageControl.delegate = self;
        [self addSubview:_pageControl];
        
        _sendButtons = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)setHideSendButton:(BOOL)hideSendButton {
    _hideSendButton = hideSendButton;
    if (_hideSendButton) {
        actionPlace = 1;
    } else {
        actionPlace = 3; //显示发送按钮+删除按钮，共占用三个位置。
    }
}

- (void)setDisableSendButton:(BOOL)disableSendButton {
    _disableSendButton = disableSendButton;
    
    for (UIButton *button in self.sendButtons) {
        button.enabled = !disableSendButton;
    }
}

- (void)loadEmojiData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _icons = [[NSMutableArray alloc] initWithCapacity:103];
        _emojSymbols = [[NSMutableArray alloc] initWithCapacity:103];
        
        @autoreleasepool {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
            if (!path) {
                //extension启动时从container目录中寻找
                path = [[NSBundle mainBundle] pathForResource:@"../../emoji" ofType:@"plist"];
            }
            NSArray *emojiDict = [NSArray arrayWithContentsOfFile:path];
            for (NSDictionary *dict in emojiDict) {
                NSString *symbol = [dict.allKeys objectAtIndex:0];
                NSString *nameValue = [dict objectForKey:symbol];
                NSRange range = [nameValue rangeOfString:@".gif"];
                if (range.length > 0) {
                    nameValue = [nameValue substringToIndex:range.location];
                }
                UIImage *icon = [UIImage extensionImageNamed:nameValue];
                if (icon) {
                    [self.emojSymbols addObject:symbol];
                    [self.icons addObject:icon];
                }
            }
            
            numberOfItemPerPage = kNumberOfItemPerColumn * kNumberOfItemPerRow - actionPlace;   //减去删除按钮和发送按钮所占的3个位置
            pages = self.icons.count / numberOfItemPerPage + 1;
            self.pageViews = [NSMutableArray arrayWithCapacity:pages];
            for (NSInteger i=0; i<pages; i++) {
                [self.pageViews addObject:[NSNull null]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.contentView.contentSize = CGSizeMake(self.frame.size.width*pages, self.contentView.frame.size.height);
                self.pageControl.numberOfPages = pages;
                [self loadPage:0];
                [self loadPage:1];
            });
        }
        
    });

}

- (void)relayoutEmojiView {
    
    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-kPageControlHeight-kPageControlMarginBottom);
    self.contentView.contentSize = CGSizeMake(self.frame.size.width*pages, self.contentView.frame.size.height);
    self.pageControl.frame = CGRectMake(0, self.frame.size.height-kPageControlHeight-kPageControlMarginBottom, self.frame.size.width, kPageControlHeight);
    [self.pageControl setNeedsDisplay];
    self.contentView.contentOffset = CGPointMake(self.pageControl.currentPage*self.contentView.frame.size.width, 0);
    
    for (NSInteger index = 0; index < self.pageViews.count; index++) {
        UIView *pageView = [self.pageViews objectAtIndex:index];
        if ((NSNull *)pageView == [NSNull null]) {
            continue;
        }
        pageView.frame = CGRectMake(index*self.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        
        //layout emoji button
        NSInteger actionButtonCount = 2;
        if (self.hideSendButton) {
            actionButtonCount = 1;
        }
        for (NSInteger emojiIndex = 0; emojiIndex < pageView.subviews.count - actionButtonCount; emojiIndex ++) {
            
            UIButton *emojiButton = [pageView.subviews objectAtIndex:emojiIndex];
            NSInteger currentRow = emojiIndex / kNumberOfItemPerRow;
            NSInteger currentColumn = emojiIndex % kNumberOfItemPerRow;
            CGFloat positionX = _edgeInsets.left + currentColumn*kEmojiWidth;
            CGFloat positionY = _edgeInsets.top + currentRow*kEmojiHeight;
            emojiButton.frame = CGRectMake(positionX, positionY, kEmojiWidth, kEmojiHeight);
            UIView *iconView = [emojiButton viewWithTag:kIconTag];
            if (iconView) {
                iconView.frame = CGRectMake((kEmojiWidth-kIconSize)/2.0, (kEmojiHeight-kIconSize)/2.0, kIconSize, kIconSize);
            }
        }
        //layout delete & send button
        UIButton *deleteButton = nil;
        UIButton *sendButton = nil;
        if (self.hideSendButton) {
            deleteButton = [pageView.subviews lastObject];
        } else {
            deleteButton = [pageView.subviews objectAtIndex:pageView.subviews.count-2];
            sendButton = [pageView.subviews lastObject];
        }
        CGFloat centerY = _edgeInsets.top + (kNumberOfItemPerColumn-1)*kEmojiHeight + kEmojiHeight/2.0;
        CGFloat centerX = _edgeInsets.left + (kNumberOfItemPerRow-actionPlace)*kEmojiWidth + kEmojiWidth/2.0;
        deleteButton.frame = CGRectMake(0, 0, 38, 29);
        deleteButton.center = CGPointMake(centerX, centerY);
        sendButton.frame = CGRectMake(0, 0, 63, 29);
        sendButton.center = CGPointMake(centerX+kEmojiWidth+kEmojiWidth/2.0+2, centerY);
    }
}

- (void)loadPageView:(UIView *)view withPage:(NSInteger)page {
 
    NSInteger realNumberInPage = 0;
    if (page==pages-1) {
        realNumberInPage = self.icons.count%numberOfItemPerPage;
    } else {
        realNumberInPage = numberOfItemPerPage;
    }
    for (NSInteger j=page*numberOfItemPerPage; j<realNumberInPage+page*numberOfItemPerPage; j++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = j;
        [button addTarget:self action:@selector(actionPickEmoji:) forControlEvents:UIControlEventTouchUpInside];
        
        //[button setImage:[self.icons objectAtIndex:j] forState:UIControlStateNormal];
        //TODO 临时放大icon
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((kEmojiWidth-kIconSize)/2.0, (kEmojiHeight-kIconSize)/2.0, kIconSize, kIconSize)];
        icon.tag = kIconTag;
        icon.image = [self.icons objectAtIndex:j];
        [button addSubview:icon];
        
        NSInteger currentRow = j%numberOfItemPerPage/kNumberOfItemPerRow;
        NSInteger currentColumn = j%numberOfItemPerPage%kNumberOfItemPerRow;
        
        CGFloat positionX = _edgeInsets.left + currentColumn*kEmojiWidth;
        CGFloat positionY = _edgeInsets.top + currentRow*kEmojiHeight;
        
        button.frame = CGRectMake(positionX, positionY, kEmojiWidth, kEmojiHeight);
        [view addSubview:button];
    }
    //添加删除和发送按钮
    CGFloat centerY = _edgeInsets.top + (kNumberOfItemPerColumn-1)*kEmojiHeight + kEmojiHeight/2.0;
    CGFloat centerX = _edgeInsets.left + (kNumberOfItemPerRow-actionPlace)*kEmojiWidth + kEmojiWidth/2.0;
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(actionDelete) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage extensionImageNamed:@"input_delete_nor"] forState:UIControlStateNormal];
        [button setImage:[UIImage extensionImageNamed:@"input_delete_press"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(0, 0, 38, 29);
        button.center = CGPointMake(centerX, centerY);
        [view addSubview:button];
    }
    if (!self.hideSendButton) {
        GinBorderedButton *button = [GinBorderedButton buttonWithType:UIButtonTypeCustom];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [button setTitle:@"发送" forState:UIControlStateNormal];
        [button setTitle:@"发送" forState:UIControlStateHighlighted];
        [button setTitle:@"发送" forState:UIControlStateSelected];
        [button setTitle:@"发送" forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(actionSend) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 63, 29);
        button.center = CGPointMake(centerX+kEmojiWidth+kEmojiWidth/2.0+2, centerY);
        button.enabled = !self.disableSendButton;
        [view addSubview:button];
        [self.sendButtons addObject:button];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page > pages-1) {
        return;
    }
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull *)pageView == [NSNull null]) {
        pageView = [[UIView alloc] initWithFrame:CGRectMake(page*self.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        [self loadPageView:pageView withPage:page];
        [self.contentView addSubview:pageView];
        [self.pageViews replaceObjectAtIndex:page withObject:pageView];
    }
}

#pragma mark -
#pragma mark Action methods

- (void)actionPickEmoji:(UIButton *)button {
    NSString *symbol = [self.emojSymbols objectAtIndex:button.tag];
    if ([self.delegate respondsToSelector:@selector(emojiPickerView:didPickEmoji:)]) {
        [self.delegate emojiPickerView:self didPickEmoji:symbol];
    }
}

- (void)actionDelete {
    if ([self.delegate respondsToSelector:@selector(emojiPickerViewDidTapDeleteButton:)]) {
        [self.delegate emojiPickerViewDidTapDeleteButton:self];
    }
}

- (void)actionSend {
    if ([self.delegate respondsToSelector:@selector(emojiPickerViewDidTapSendButton:)]) {
        [self.delegate emojiPickerViewDidTapSendButton:self];
    }
}

#pragma mark -
#pragma GinPageControlDelegate

- (void)pageControlPageDidChange:(GinPageControl *)pageControl {
    CGRect rect = CGRectMake(pageControl.currentPage*self.frame.size.width, 0, self.frame.size.width, self.contentView.frame.size.height);
    [self.contentView scrollRectToVisible:rect animated:YES];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = floor((self.contentView.contentOffset.x - self.frame.size.width / 2) / self.frame.size.width) + 1;
    self.pageControl.currentPage = page;
    
    [self loadPage:page-1];
    [self loadPage:page];
    [self loadPage:page+1];
}

@end

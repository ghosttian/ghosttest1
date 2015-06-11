//
//  GinEmojiPickerView.h
//  microChannel
//
//  Created by leizhu on 13-7-18.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GinEmojiPickerViewDelegate;
@interface GinEmojiPickerView : UIView

@property (nonatomic, strong) NSMutableArray *emojSymbols;
@property (nonatomic, weak) id<GinEmojiPickerViewDelegate> delegate;
@property (nonatomic, assign) BOOL hideSendButton;
@property (nonatomic, assign) BOOL disableSendButton;

- (void)relayoutEmojiView; //横屏支持

@end


@protocol GinEmojiPickerViewDelegate <NSObject>

- (void)emojiPickerView:(GinEmojiPickerView *)view didPickEmoji:(NSString *)emojiSymbol;
- (void)emojiPickerViewDidTapDeleteButton:(GinEmojiPickerView *)view;

@optional
- (void)emojiPickerViewDidTapSendButton:(GinEmojiPickerView *)view;

@end
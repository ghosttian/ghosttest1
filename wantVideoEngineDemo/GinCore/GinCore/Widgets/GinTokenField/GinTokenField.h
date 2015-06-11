//
//  GinTokenField.h
//  GinTokenFieldDemo
//
//  Created by leizhu on 13-12-17.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GinTokenFieldControlEventFrameWillChange = 1 << 24,
    GinTokenFieldControlEventFrameDidChange = 1 << 25,
} GinTokenFieldControlEvents;

@class GinToken;
@protocol GinTokenFieldDelegate;
@interface GinTokenField : UITextField

@property (nonatomic, strong, readonly) NSMutableArray *ginTokens;
@property (nonatomic, weak, readonly) GinToken *selectedToken;
@property (weak, nonatomic, readonly) NSArray *tokenTitles;
@property (weak, nonatomic, readonly) NSArray *tokenObjects;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, readonly) NSInteger numberOfLines;
@property (nonatomic, weak) id <GinTokenFieldDelegate> tokenFieldDelegate;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) NSInteger maxCount; //最多可添加的token个数

- (id)initWithFrame:(CGRect)frame showAt:(BOOL)show; //是否显示@图标

- (void)addTokenWithTitle:(NSString *)title;
- (void)addTokenWithTitle:(NSString *)title object:(id)object;
- (void)removeTokenWithTitle:(NSString *)title;
- (void)removeToken:(GinToken *)token;
- (void)removeAllTokens;

- (void)selectToken:(GinToken *)token;
- (void)deselectSelectedToken;

- (void)layoutTokensAnimated:(BOOL)animated;
- (void)setPromptText:(NSString *)text;

- (BOOL)containsTitle:(NSString *)title;

@end


@protocol GinTokenFieldDelegate <NSObject>

- (void)tokenField:(GinTokenField *)field didAddToken:(GinToken *)token;
- (void)tokenField:(GinTokenField *)field didRemoveToken:(GinToken *)token;

@end

#define kTextEmpty      @"\u200B" // Zero-Width Space
#define kTextHidden     @"\u200D" // Zero-Width Joiner

//
//  GinToken.h
//  GinTokenFieldDemo
//
//  Created by leizhu on 13-12-17.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GinToken : UIButton

@property (nonatomic, assign) CGFloat maxWidth;

@property (nonatomic, strong) id object;

- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title object:(id)object;

- (void)setFont:(UIFont *)font;

@end

#define kGinTokenFontSize 14.0f
#define kGinTokenEdgeInsets UIEdgeInsetsMake(5, 8, 5, 8)
#define kGinTokenHeight 29.0 //TODO跟font和edgeInsets相关
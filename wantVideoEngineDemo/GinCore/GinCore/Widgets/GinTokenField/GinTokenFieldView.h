//
//  GinTokenFieldView.h
//  microChannel
//
//  Created by leizhu on 13-12-23.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GinTokenField;
@interface GinTokenFieldView : UIScrollView <UITextFieldDelegate>

@property (nonatomic, strong) GinTokenField *tokenField;
@property (nonatomic, copy) void (^frameChangeBlock)(CGRect newFrame);

- (id)initWithFrame:(CGRect)frame showAt:(BOOL)show;

@end

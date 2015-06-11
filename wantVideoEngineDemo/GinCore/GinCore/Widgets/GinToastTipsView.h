//
//  GinToastTipsView.h
//  microChannel
//
//  Created by leizhu on 14-8-8.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ArrowPositionTop,
    ArrowPositionBottom,
} ArrowPosition;

@interface GinToastTipsView : UIView

- (instancetype)initWithText:(NSString *)text arrowPosition:(ArrowPosition)position arrowPoint:(CGPoint)point;

- (void)showInView:(UIView *)view;
- (void)hide;
- (void)hideRightNow;
- (void)delayHide;
@end

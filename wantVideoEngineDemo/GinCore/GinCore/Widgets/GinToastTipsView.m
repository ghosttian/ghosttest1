//
//  GinToastTipsView.m
//  microChannel
//
//  Created by leizhu on 14-8-8.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinToastTipsView.h"

#define kTimeOutSeconds 2
#define kTextFont [UIFont systemFontOfSize:16.0]
#define kBubblePadding 5.0

@interface GinToastTipsView ()

@property(nonatomic,assign) BOOL timeOut;
@property(nonatomic,assign) CGPoint arrowPoint;
@property(nonatomic,assign) ArrowPosition arrowPosition;
@property(nonatomic,strong) UIImageView *arrowView;
@property (nonatomic, assign) NSTimeInterval beginInter;
@end

@implementation GinToastTipsView

- (instancetype)initWithText:(NSString *)text arrowPosition:(ArrowPosition)position arrowPoint:(CGPoint)point {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _arrowPoint = point;
        _arrowPosition = position;
        
        CGSize size = [text sizeWithFont:kTextFont];

        UIImage *bubble = [[UIImage imageNamed:@"tips_bg_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        UIImageView *bubbleView = [[UIImageView alloc] initWithImage:bubble];
        
        UIImage *arrow = nil;
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        CGFloat frameY = 0;
        switch (position) {
            case ArrowPositionTop: {
                arrow = [UIImage imageNamed:@"tips_bg_arrow_up"];
                arrowView.frame = CGRectMake(0, 0, arrow.size.width, arrow.size.height);
                bubbleView.frame = CGRectMake(0, arrow.size.height, size.width+20, bubble.size.height);
                frameY = point.y;
                break;
            }
            case ArrowPositionBottom: {
                arrow = [UIImage imageNamed:@"tips_bg_arrow_down"];
                arrowView.frame = CGRectMake(0, bubble.size.height, arrow.size.width, arrow.size.height);
                bubbleView.frame = CGRectMake(0, 0, size.width+20, bubble.size.height);
                frameY = point.y - bubble.size.height - arrow.size.height;
                break;
            }
            default:
                break;
        }
        arrowView.image = arrow;
        self.arrowView = arrowView;
        [self addSubview:arrowView];
        [self addSubview:bubbleView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:bubbleView.frame];
        textLabel.font = kTextFont;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = text;
        textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:textLabel];
        
        self.frame = CGRectMake(0, frameY, size.width+20, bubble.size.height+arrow.size.height);
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.superview && !CGRectContainsPoint(self.bounds, point)) {
        if (self.timeOut) {
            [self hide];
        }
    }
    return [super hitTest:point withEvent:event];
}

- (void)showInView:(UIView *)view {
    
    [view addSubview:self];
    
    CGRect frame = self.frame;
    if (self.arrowPoint.x < view.frame.size.width/2.0 - 20) {
        //bubble alignment left
        frame.origin.x = kBubblePadding;
    } else if (self.arrowPoint.x > view.frame.size.width/2.0 + 20) {
        //bubble alignment right
        frame.origin.x = view.frame.size.width - kBubblePadding - frame.size.width;
    } else {
        //bubble alignment center
        frame.origin.x = (view.frame.size.width - frame.size.width)/2.0;
    }

    CGRect arrowFrame = self.arrowView.frame;
    arrowFrame.origin.x = self.arrowPoint.x - frame.origin.x - self.arrowView.frame.size.width/2.0;
    self.arrowView.frame = arrowFrame;
    self.frame = frame;
    self.beginInter = [[NSDate date]timeIntervalSince1970];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimeOutSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timeOut = YES;
    });
}

- (void)hideDelay:(CGFloat)delay {
    if (self.superview) {
        [UIView animateWithDuration:.2 delay:delay options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)hide {
    [self hideDelay:0];
}

- (void)hideRightNow
{
    [self hideDelay:0.0];
}
- (void)delayHide
{
    CGFloat delay = 0.0;
    if (self.timeOut) {
        delay = 0.0;
    }else{
        delay = fabsf( kTimeOutSeconds - ([[NSDate date]timeIntervalSince1970] - self.beginInter));
        NSLog(@"----delay:%f---------- isTimeOut:%d", delay, self.timeOut);
    }
    
    [self hideDelay:delay];
}

@end

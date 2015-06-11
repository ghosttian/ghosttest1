//
//  UIView+GestureAction.h
//  microChannel
//
//  Created by aidenluo on 12/27/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GestureActionBlock)(UIGestureRecognizer *gestureRecoginzer);

@interface UIView (GestureAction)

- (void)setTapActionWithBlock:(GestureActionBlock)block;
- (void)setLongPressActionWithBlock:(GestureActionBlock)block;

@end

//
//  GinLoadingWarningView.h
//  Gin
//
//  Created by minghuiji on 13-5-1.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GinMBProgressHUD.h"
/*
 单例类，通过[GinLoadingWarningView shareInstance]或是类实例
 */
@interface GinExtensionLoadingWarningView : NSObject<GinMBProgressHUDDelegate>
@property (strong, nonatomic) GinMBProgressHUD* HUDLoad;
@property (strong, nonatomic) GinMBProgressHUD *HUDWarning;

/*
 消息提醒框，strLog为显示的提醒内容
 */
- (void)showWarning:(NSString*)strLog showInView:(UIView *)showInView;
- (void)showWarning:(NSString *)strLog rotateDegree:(CGFloat)degree showInView:(UIView *)showInView;
- (void)showWarning:(NSString *)strLog rotateDegree:(CGFloat)degree withOffsetX:(CGFloat)offsetX showInView:(UIView *)showInView;
- (void)showWarning:(NSString *)strLog rotateDegree:(CGFloat)degree withOffsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY showInView:(UIView *)showInView;

/*
 等待框和endLoading配合使用，显示等待框调用[[GinLoadingWarningView shareInstance]showLoading],
 关闭时[[GinLoadingWarningView shareInstance]endLoading]
 */
- (void)showLoadingWithInView:(UIView *)showInView;
- (void)showLoading:(NSString *)text showInView:(UIView *)showInView;
- (void)reopenLoading:(NSString*)text showInView:(UIView *)showInView;
- (void)showVideoEditLoadingWithOffsetY:(CGFloat)offsetY showInView:(UIView *)showInView;
- (void)showVideoEditLoadingWithOffsetY:(CGFloat)offsetY showInView:(UIView *)showInView needHideLoadingView:(BOOL)need;
- (void)showLockingViewWithInView:(UIView *)showInView;
/*
 关闭等待框
 */
- (void)endLoading;

+ (id)shareInstance;
@end

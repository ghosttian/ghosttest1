//
//  GinLoadingWarningView.m
//  Gin
//
//  Created by minghuiji on 13-5-1.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import "GinExtensionLoadingWarningView.h"

static GinExtensionLoadingWarningView *g_instace = nil;

@implementation GinExtensionLoadingWarningView

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showWarning:(NSString*)strLog showInView:(UIView *)showInView
{
     [self showWarning:strLog rotateDegree:0 withOffsetX:0 showInView:showInView];
}


- (void)showWarning:(NSString *)strLog rotateDegree:(CGFloat)degree showInView:(UIView *)showInView
{
    [self showWarning:strLog rotateDegree:degree withOffsetX:0 showInView:showInView];
}

- (void)showWarning:(NSString *)strLog rotateDegree:(CGFloat)degree withOffsetX:(CGFloat)offsetX showInView:(UIView *)showInView
{
    [self showWarning:strLog rotateDegree:degree withOffsetX:offsetX offsetY:0 showInView:showInView];
}

- (void)showWarning:(NSString *)strLog rotateDegree:(CGFloat)degree withOffsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY showInView:(UIView *)showInView
{
    if(_HUDWarning == nil) {
        _HUDWarning = [[GinMBProgressHUD alloc] initWithView:showInView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = strLog;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [label sizeToFit];
        _HUDWarning.customView = label;
        _HUDWarning.xOffset = offsetX;
        _HUDWarning.yOffset = offsetY;
        label = nil;
        _HUDWarning.mode = GinMBProgressHUDModeCustomView;
        [[UIApplication sharedApplication].delegate.window addSubview:_HUDWarning];
        _HUDWarning.transform = CGAffineTransformMakeRotation((M_PI * (degree) / 180.0));
        _HUDWarning.delegate = self;
        [_HUDWarning showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    }
}

- (void)myTask
{
    sleep(1);
}

- (void)showLoadingWithInView:(UIView *)showInView
{
    if(_HUDLoad == nil){
        _HUDLoad = [[GinMBProgressHUD alloc] initWithView:showInView];
        [showInView addSubview:_HUDLoad];
        _HUDLoad.delegate = self;
        [_HUDLoad show:YES];
    }
}



- (void)showLoading:(NSString *)text showInView:(UIView *)showInView{
    if(_HUDLoad == nil){
		_HUDLoad = [[GinMBProgressHUD alloc] initWithView:showInView];
		[showInView addSubview:_HUDLoad];
		_HUDLoad.delegate = self;
        _HUDLoad.labelText = text;
		[_HUDLoad show:YES];
	}
}

- (void)showLockingViewWithInView:(UIView *)showInView;
{
    if(_HUDLoad == nil){
		_HUDLoad = [[GinMBProgressHUD alloc] initWithView:showInView];
		[showInView addSubview:_HUDLoad];
		_HUDLoad.delegate = self;
        _HUDLoad.hidden = YES;
		[_HUDLoad show:YES];
	}
}

- (void)showVideoEditLoadingWithOffsetY:(CGFloat)offsetY showInView:(UIView *)showInView
{
    [self showVideoEditLoadingWithOffsetY:offsetY showInView:showInView needHideLoadingView:NO];
}

- (void)showVideoEditLoadingWithOffsetY:(CGFloat)offsetY showInView:(UIView *)showInView needHideLoadingView:(BOOL)need
{
    if(_HUDLoad == nil){
		if (!showInView) {
            //iOS8 Extension don't support [UIApplication sharedApplication];
            return;//showInView = [UIApplication sharedApplication].delegate.window;
		}
		_HUDLoad = [[GinMBProgressHUD alloc] initWithView:showInView];
		[showInView addSubview:_HUDLoad];

        _HUDLoad.labelText = @"处理中...";
		_HUDLoad.delegate = self;
        _HUDLoad.yOffset = -offsetY;
		[_HUDLoad show:YES];
        _HUDLoad.hidden = need;
	}
}

- (void)reopenLoading:(NSString*)text showInView:(UIView *)showInView;
{
    if (_HUDLoad) {
        _HUDLoad = nil;
    }
    [self showLoading:text showInView:showInView];
};

-(void)endLoading
{
    if(_HUDLoad != nil){
		[_HUDLoad hide:YES];
	}
    
}

#pragma mark -
#pragma mark GinMBProgressHUDDelegate methods
- (void)hudWasHidden:(GinMBProgressHUD *)hud {
	if(hud == _HUDLoad && _HUDLoad != nil) {
		[_HUDLoad removeFromSuperview];
		_HUDLoad = nil;
	}
    if(hud == _HUDWarning && _HUDWarning  != nil){
        [_HUDWarning removeFromSuperview];
        _HUDWarning = nil;
    }
}

//
+ (id)shareInstance
{
    if (nil == g_instace) {
        @synchronized(self){
            if (nil == g_instace) {
                g_instace = [[GinExtensionLoadingWarningView alloc]init];
            }
        }
    }
    return g_instace;
}
@end

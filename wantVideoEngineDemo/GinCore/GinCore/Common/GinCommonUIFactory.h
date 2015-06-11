//
//  GinCommonUIFactory.h
//  GinCore
//
//  Created by leizhu on 14/12/5.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GinCommonUIFactory : NSObject

+ (void)setNavigationBarApperanceBlackForExtension:(UINavigationBar *)bar;
+ (void)setNavigationBarApperanceForExtension:(UINavigationBar *)bar;

+ (UIView *)customTitleViewWithTitle:(NSString *)title image:(UIImage *)image;
+ (UIButton*)navBarNormalButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIButton*)navBarRightNormalButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (void)setNavigationBarWithNoShadow:(UINavigationBar*)navbar;
+ (void)setNavigationBarTranslucentApperance;
+ (UIButton*)navBarBackImageButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (UIButton*)videoNavBarBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;

+ (UIImage *)navigationBarBackButtonBackgroundImage;
+ (UIImage *)navigationBarBackButtonBackgroundHighlightImage;
+ (void)setNavigationBarApperance;
+ (UIButton*)navBarBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (UIButton*)navBarLeftImageButtonWithTarget:(id)target action:(SEL)action;
+ (void)setNavigationBarBlackApperance;
+ (UIButton*)navBarLeftTextButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
;

+ (UIButton*)navBarBackButtonWithTitle:(NSString*)title;








@end

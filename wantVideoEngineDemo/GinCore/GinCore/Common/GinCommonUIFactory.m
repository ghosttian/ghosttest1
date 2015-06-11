//
//  GinCommonUIFactory.m
//  GinCore
//
//  Created by leizhu on 14/12/5.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinCommonUIFactory.h"
#import "UIColor+Utils.h"
#import "UIImage+Plus.h"
#import "GinCoreDefines.h"

#define kNavBarTitleFontSize 20.0
#define kNavBarItemFontSize  16.0

@implementation GinCommonUIFactory

+ (void)setNavigationBarApperanceBlackForExtension:(UINavigationBar *)bar {
    [bar setTranslucent:NO];
    [bar setBarTintColor:[UIColor blackColor]];
    [bar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],
                                      UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarTitleFontSize],
                                      UITextAttributeTextShadowColor:[UIColor clearColor]}];
}

+ (void)setNavigationBarApperanceForExtension:(UINavigationBar *)bar {

    [bar setTranslucent:NO];
    [bar setBarTintColor:[UIColor colorWithRGBHex:0xff44bbcc]];
    [bar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],
                                  UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarTitleFontSize],
                                  UITextAttributeTextShadowColor:[UIColor clearColor]}];
}

+ (UIView *)customTitleViewWithTitle:(NSString *)title image:(UIImage *)image {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:kNavBarTitleFontSize];
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    CGSize titleSize = [title sizeWithFont:label.font];
    label.frame = CGRectMake(image.size.width+3, 0, titleSize.width, 44);
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (44-image.size.height)/2.0, image.size.width, image.size.height)];
    iconView.image = image;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleSize.width+3+image.size.width, 44)];
    [view addSubview:iconView];
    [view addSubview:label];
    
    return view;
}

+ (UIButton*)navBarNormalButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:kNavBarItemFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRGBHex:0xff11aaaa alpha:1.0] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor colorWithRGBHex:0xff99eeee alpha:1.0] forState:UIControlStateDisabled];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, title.length * kNavBarItemFontSize, kNavBarItemFontSize);
    return btn;
}

+ (UIButton*)navBarRightNormalButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton* btn = [GinCommonUIFactory navBarNormalButtonWithTitle:title target:target action:action];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:kNavBarItemFontSize];
    if (IOSVERSIONISABOVE7)
    {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -15)];
    }
    else
    {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    }
    return btn;
}

+ (void)setNavigationBarWithNoShadow:(UINavigationBar*)navbar
{
    if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)])
    {
        [navbar setShadowImage:[[UIImage alloc] init]];
    }
}


+ (void)setNavigationBarTranslucentApperance
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRGBHex:0xffaaaaaa alpha:1.0],
                                                           UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarTitleFontSize]}];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage extensionImageNamed:@"g_cameraroll_nav_bg_repeat_h"] forBarMetrics:UIBarMetricsDefault];
    if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)])
    {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]]; //隐藏ShadowImage需要设置空UIImage，而不是nil
    }
}

//图片和文字
+ (UIButton*)navBarBackImageButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    
    if ((title.length > 3) && ![title isEqualToString:@"返回微信"] && ![title isEqualToString:@"返回微博"])
    {
        title = @"返回";
    }
    CGFloat fontsize = kNavBarItemFontSize;
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* norImg = [UIImage extensionImageNamed:@"g_nav_btn_back_nor"];
    UIImage* hightImg = [UIImage extensionImageNamed:@"g_nav_btn_back_press"];
    [btn setImage:norImg forState:UIControlStateNormal];
    [btn setImage:hightImg forState:UIControlStateHighlighted];
    
    [btn setTitleColor:[UIColor colorWithRGBHex:0xffffffff alpha:1.0] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRGBHex:0xff11aaaa alpha:1.0] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor colorWithRGBHex:0xff99eeee alpha:1.0] forState:UIControlStateDisabled];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:fontsize]];
    [btn setTitle:title forState:UIControlStateNormal];
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGFloat width;
    if ([title isEqualToString:@"返回微信"] || [title isEqualToString:@"返回微博"]) {
        width = 80;
    }
    else
    {
        width = norImg.size.width + fontsize * title.length;
    }
    if (IOSVERSIONISABOVE7)
    {
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        btn.frame = CGRectMake(0, 0, width, norImg.size.height);
    }
    else
    {
        btn.frame = CGRectMake(0, 0, width + 10, norImg.size.height);
    }
    
    return btn;
}


+ (UIButton*)videoNavBarBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton *btn = [GinCommonUIFactory navBarBackImageButtonWithTitle:title target:target action:action];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, - 20, 0, 0)];
    return btn;
}

+ (UIImage *)navigationBarBackButtonBackgroundImage
{
    static UIImage *navigationBarBackButtonBackgroundImage = nil;
    if (!navigationBarBackButtonBackgroundImage) {
        UIImage* image = [UIImage extensionImageNamed:@"g_nav_btn_back_nor"];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width + 1, image.size.height), NO, image.scale);
        {	//最右边一个像素拉伸
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image =  UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        navigationBarBackButtonBackgroundImage = [image stretchableImageWithLeftCapWidth:image.size.width topCapHeight:0];
    }
    return navigationBarBackButtonBackgroundImage;
}

+ (UIImage *)navigationBarBackButtonBackgroundHighlightImage
{
    static UIImage *navigationBarBackButtonBackgroundHighlightImage = nil;
    if (!navigationBarBackButtonBackgroundHighlightImage) {
        UIImage* highlightImage = [UIImage extensionImageNamed:@"g_nav_btn_back_press"];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(highlightImage.size.width + 1, highlightImage.size.height), NO, highlightImage.scale);
        {
            [highlightImage drawInRect:CGRectMake(0, 0, highlightImage.size.width, highlightImage.size.height)];
            highlightImage =  UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        navigationBarBackButtonBackgroundHighlightImage = [highlightImage stretchableImageWithLeftCapWidth:highlightImage.size.width topCapHeight:0];
    }
    return navigationBarBackButtonBackgroundHighlightImage;
}

+ (void)setNavigationBarApperance
{
    if (IOSVERSIONISABOVE7)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage extensionImageNamed:@"g_nav_bg_repeat_withstatus-bar"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage extensionImageNamed:@"g_nav_bg_repeat_h"]
                                           forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]]
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
    }
    if ([UINavigationBar instancesRespondToSelector:@selector(setShadowImage:)])
    {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],
                                                           UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarTitleFontSize],
                                                           UITextAttributeTextShadowColor:[UIColor clearColor]}];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRGBHex:0xffffffff alpha:1.0],
                                                           UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarItemFontSize],
                                                           UITextAttributeTextShadowColor:[UIColor clearColor]}
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRGBHex:0xff11aaaa alpha:1.0],
                                                           UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarItemFontSize],
                                                           UITextAttributeTextShadowColor:[UIColor clearColor]}
                                                forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRGBHex:0xff99eeee alpha:1.0],
                                                           UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarItemFontSize],
                                                           UITextAttributeTextShadowColor:[UIColor clearColor]}
                                                forState:UIControlStateDisabled];
    
    //返回按钮设置
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[GinCommonUIFactory navigationBarBackButtonBackgroundImage]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[GinCommonUIFactory navigationBarBackButtonBackgroundHighlightImage]
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
}

//title.length > 0只显示文字，否则只现实返回图片
+ (UIButton*)navBarBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* norImg;
    
    if (title.length <= 0) {
        norImg = [UIImage extensionImageNamed:@"g_nav_btn_back_nor"];
        UIImage* hightImg = [UIImage extensionImageNamed:@"g_nav_btn_back_press"];
        [btn setImage:norImg forState:UIControlStateNormal];
        [btn setImage:hightImg forState:UIControlStateHighlighted];
    } else {
        [btn setTitleColor:[UIColor colorWithRGBHex:0xffffffff] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRGBHex:0xff11aaaa] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor colorWithRGBHex:0xff99eeee] forState:UIControlStateDisabled];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:kNavBarItemFontSize];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setTitle:title forState:UIControlStateNormal];
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGFloat width = norImg.size.width + kNavBarItemFontSize * title.length;
    
    if (IOSVERSIONISABOVE7)
    {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        btn.frame = CGRectMake(0, 0, width, norImg.size.height);
    }
    else
    {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
        btn.frame = CGRectMake(0, 0, width + 10, norImg.size.height);
    }
    //    [btn setBackgroundColor:[UIColor redColor]];
    return btn;
}

//只显示图片
+ (UIButton*)navBarLeftImageButtonWithTarget:(id)target action:(SEL)action{
    
    UIButton* btn = [GinCommonUIFactory navBarBackButtonWithTitle:nil target:target action:action];
    return btn;
}

+ (void)setNavigationBarBlackApperance
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRGBHex:0xffaaaaaa],
                                                           UITextAttributeFont:[UIFont boldSystemFontOfSize:kNavBarTitleFontSize]}];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage extensionImageNamed:@"g_nav_bg_black"] forBarMetrics:UIBarMetricsDefault];
}

//只显示文字
+ (UIButton*)navBarLeftTextButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    if (title.length > 3 || title.length <= 0) {
        title = @"返回";
    }
    
    UIButton* btn = [GinCommonUIFactory navBarBackButtonWithTitle:title target:target action:action];
    return btn;
}

+ (UIButton*)navBarBackButtonWithTitle:(NSString*)title
{
    return [GinCommonUIFactory navBarBackButtonWithTitle:title target:nil action:nil];
}



@end

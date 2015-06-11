//
//  GinPageControl.h
//  microChannel
//
//  Created by leizhu on 13-7-18.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GinPageControlDelegate;
@interface GinPageControl : UIView

// Set these to control the PageControl.
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

// Customize these as well as the backgroundColor property.
@property (nonatomic, strong) UIColor *dotColorCurrentPage;
@property (nonatomic, strong) UIColor *dotColorOtherPage;

// Optional delegate for callbacks when user taps a page dot.
@property (nonatomic, weak) NSObject<GinPageControlDelegate> *delegate;

- (CGFloat)dotDiameter;
- (CGFloat)dotSpacer;

@end

@protocol GinPageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(GinPageControl *)pageControl;
@end
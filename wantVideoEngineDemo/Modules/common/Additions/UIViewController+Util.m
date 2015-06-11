//
//  UIViewController+Util.m
//  microChannel
//
//  Created by aidenluo on 4/25/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "UIViewController+Util.h"

@implementation UIViewController (Util)

- (BOOL)isViewVisiable
{
    return self.isViewLoaded && self.view.window != nil;
}

- (BOOL)isViewUnvisiable
{
    return self.isViewLoaded && self.view.window == nil;
}

@end

//
//  UIImageView+GinWebCache.m
//  microChannel
//
//  Created by ricky on 14-12-18.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "UIButton+GinWebCache.h"

@implementation UIButton (GinWebCache)

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state
{
    [self sd_setImageWithURL:url forState:state];
}
- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url forState:state placeholderImage:placeholder];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self sd_setImageWithURL:url forState:state placeholderImage:placeholder options:options];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url forState:state completed:completedBlock];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder
{
    [self sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder completed:completedBlock];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:completedBlock];
}
- (void)cancelImageLoadForState:(UIControlState)state
{
    [self sd_cancelImageLoadForState:state];
}


@end

//
//  UIImageView+GinWebCache.m
//  microChannel
//
//  Created by ricky on 14-12-18.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "UIImageView+GinWebCache.h"


@implementation UIImageView (GinWebCache)


- (void)setImageWithURL:(NSURL *)url
{
    [self sd_setImageWithURL:url];
}
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options ];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options completed:completedBlock];
}


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
}

- (void)cancelCurrentImageLoad {
    [self sd_cancelCurrentImageLoad];
}


@end

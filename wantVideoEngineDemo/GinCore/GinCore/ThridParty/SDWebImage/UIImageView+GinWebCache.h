//
//  UIImageView+GinWebCache.h
//  microChannel
//
//  Created by ricky on 14-12-18.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "UIImageView+WebCache.h"

@interface UIImageView (GinWebCache)

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;


- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;


- (void)cancelCurrentImageLoad;

@end

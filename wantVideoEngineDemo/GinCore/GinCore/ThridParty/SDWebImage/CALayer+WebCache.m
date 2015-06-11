//
//  CALayer+WebCache.m
//  microChannel
//
//  Created by randyyu on 13-9-19.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "CALayer+WebCache.h"
#import "objc/runtime.h"
static char operationKey;

@implementation CALayer (WebCache)
- (void)setImageWithURL:(NSURL *)url
{
    //randyyu
    [self setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
{
    [self cancelCurrentImageLoad];
    
    self.contents = (id)[placeholder CGImage];
    
    if (url)
    {
        __weak CALayer *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
                                             {
                                                 __strong CALayer *sself = wself;
                                                 if (!sself) return;
                                                 if (image)
                                                 {
                                                     if (![NSThread isMainThread]) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             sself.contents = (id)[image CGImage];
                                                             [sself setNeedsLayout];
                                                         });
                                                     }else{
                                                         sself.contents = (id)[image CGImage];
                                                         [sself setNeedsLayout];
                                                     }

                                                 }
                                                 if (completedBlock && finished)
                                                 {
                                                     completedBlock(image, error, cacheType,imageURL);
                                                 }
                                             }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

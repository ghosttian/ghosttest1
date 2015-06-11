//
//  MVVideoEffectRedColorFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectRedColorFilterExcutor.h"
#import "MVVideoRedColorFilter.h"

@interface MVVideoEffectRedColorFilterExcutor ()

@property(nonatomic,strong)MVVideoRedColorFilter *redColorFilter;
@property(nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MVVideoEffectRedColorFilterExcutor

- (Class)getFilterClass{
    return [MVVideoRedColorFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.redColorFilter ) {
        return self.redColorFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.redColorFilter = (MVVideoRedColorFilter *)filter;
    if (self.redColorFilter.modelImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.redColorFilter.modelImage];
        [self.picture addTarget:self.redColorFilter atTextureLocation:1];
        [self.redColorFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.redColorFilter;
}

@end

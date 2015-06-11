//
//  MVVideoEffectPortraitBeautyFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectPortraitBeautyFilterExcutor.h"
#import "MVVideoPortraitBeautyFilter.h"

@interface MVVideoEffectPortraitBeautyFilterExcutor ()

@property(nonatomic,strong)MVVideoPortraitBeautyFilter *beautyFilter;
@property(nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MVVideoEffectPortraitBeautyFilterExcutor

- (Class)getFilterClass{
    return [MVVideoPortraitBeautyFilter class];
}

- (GPUImageFilter *)getFilter{
    if (self.beautyFilter) {
        return self.beautyFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.beautyFilter = (MVVideoPortraitBeautyFilter *)filter;
    if (self.beautyFilter.beautyImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.beautyFilter.beautyImage];
        [self.picture addTarget:self.beautyFilter atTextureLocation:1];
        [self.beautyFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.beautyFilter;
}

@end

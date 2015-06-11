//
//  MVVideoEffectDarkCornerInstantFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectDarkCornerInstantFilterExcutor.h"
#import "MVVideoCurveDarkCornerFilter.h"

@interface MVVideoEffectDarkCornerInstantFilterExcutor ()

@property(nonatomic,strong)MVVideoCurveDarkCornerFilter *instantFilter;
@property(nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MVVideoEffectDarkCornerInstantFilterExcutor

- (Class)getFilterClass{
    return [MVVideoCurveDarkCornerFilter class];
}

- (GPUImageFilter *)getFilter{
    if (self.instantFilter) {
        return self.instantFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.instantFilter = (MVVideoCurveDarkCornerFilter *)filter;
    if (self.instantFilter.darkCornerImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.instantFilter.darkCornerImage];
        [self.picture addTarget:self.instantFilter atTextureLocation:1];
        [self.instantFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.instantFilter;
}

@end

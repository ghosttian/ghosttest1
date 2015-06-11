//
//  MVVideoEffectSampleFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectColorPencilFilterExcutor.h"
#import "MVVideoColorPencilFilter.h"

@interface MVVideoEffectColorPencilFilterExcutor ()

@property(nonatomic,strong) MVVideoColorPencilFilter *colorPencilFilter;
@property(nonatomic,strong) GPUImagePicture *picture;

@end

@implementation MVVideoEffectColorPencilFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoColorPencilFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.colorPencilFilter ) {
        return self.colorPencilFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.colorPencilFilter = (MVVideoColorPencilFilter *)filter;
    if (self.colorPencilFilter.modelImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.colorPencilFilter.modelImage];
        [self.picture addTarget:self.colorPencilFilter atTextureLocation:1];
        [self.colorPencilFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.colorPencilFilter;
}

@end

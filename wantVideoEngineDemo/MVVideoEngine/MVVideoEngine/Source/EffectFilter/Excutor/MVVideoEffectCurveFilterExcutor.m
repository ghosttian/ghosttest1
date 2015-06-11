//
//  MVVideoEffectCurveFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectCurveFilterExcutor.h"

@interface MVVideoEffectCurveFilterExcutor()

@property(nonatomic) GPUImagePicture *picture;

@end

@implementation MVVideoEffectCurveFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoCurveFilter class];
}

- (GPUImageFilter *)getFilter
{
	if (self.curveFilter ) {
		return self.curveFilter;
	}
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.curveFilter = (MVVideoCurveFilter *)filter;
    if (self.curveFilter.curveImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.curveFilter.curveImage];
        [self.picture addTarget:self.curveFilter atTextureLocation:1];
        [self.curveFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.curveFilter;
}

@end

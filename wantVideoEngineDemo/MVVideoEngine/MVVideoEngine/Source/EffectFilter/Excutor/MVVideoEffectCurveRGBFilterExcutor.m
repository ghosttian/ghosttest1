//
//  MVVideoEffectCurveRGBFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectCurveRGBFilterExcutor.h"
#import "MVVideoCurveRGBFilter.h"

@interface MVVideoEffectCurveRGBFilterExcutor ()

@property(nonatomic,strong) MVVideoCurveRGBFilter *curveFilter;
@property(nonatomic) GPUImagePicture *picture;

@end

@implementation MVVideoEffectCurveRGBFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoCurveRGBFilter class];
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
    self.curveFilter = (MVVideoCurveRGBFilter *)filter;
    if (self.curveFilter.curveImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.curveFilter.curveImage];
        [self.picture addTarget:self.curveFilter atTextureLocation:1];
        [self.curveFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.curveFilter;
}

@end

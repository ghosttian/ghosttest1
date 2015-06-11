//
//  MVVideoEffectCurvePartialFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectCurvePartialFilterExcutor.h"

@interface MVVideoEffectCurvePartialFilterExcutor ()

@property(nonatomic) GPUImagePicture *picture;

@end

@implementation MVVideoEffectCurvePartialFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoCurvePartialFilter class];
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
    self.curveFilter = (MVVideoCurvePartialFilter *)filter;
    if (self.curveFilter.curveImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.curveFilter.curveImage];
        [self.picture addTarget:self.curveFilter atTextureLocation:1];
        [self.picture processImage];
    }
    return self.curveFilter;
}

@end

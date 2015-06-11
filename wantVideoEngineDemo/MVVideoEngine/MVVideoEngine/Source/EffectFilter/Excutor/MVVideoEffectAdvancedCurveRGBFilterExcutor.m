//
//  MVVideoEffectAdvancedCurveRGBFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/22/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectAdvancedCurveRGBFilterExcutor.h"
#import "MVVideoAdvancedCurveRGBFilter.h"

@interface MVVideoEffectAdvancedCurveRGBFilterExcutor ()

@property(nonatomic,strong) MVVideoAdvancedCurveRGBFilter *curveFilter;
@property(nonatomic) GPUImagePicture *picture;

@end

@implementation MVVideoEffectAdvancedCurveRGBFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoAdvancedCurveRGBFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.curveFilter) {
        return self.curveFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.curveFilter = (MVVideoAdvancedCurveRGBFilter *)filter;
    if (self.curveFilter.curveImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.curveFilter.curveImage];
        [self.picture addTarget:self.curveFilter atTextureLocation:1];
        [self.curveFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.curveFilter;
}

@end

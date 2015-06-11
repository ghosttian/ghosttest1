//
//  MVVideoEffectBlurFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectBlurFilterExcutor.h"
#import "MVVideoBlurFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectBlurFilterAnimationData : MVVideoEffectFilterAnimationData

@property(nonatomic) float blurRadius;

@end

@implementation MVVideoEffectBlurFilterAnimationData

@end

@interface MVVideoEffectBlurFilterExcutor ()

@property(nonatomic,strong) MVVideoBlurFilter *blurFilter;
@property(nonatomic,strong) NSArray *formatedAnimationPath;

@end

@implementation MVVideoEffectBlurFilterExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in self.animationPath) {
            NSDictionary *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectBlurFilterAnimationData *animationData = [[MVVideoEffectBlurFilterAnimationData alloc] init];
            animationData.time = [item mvDoubleValueForKey:@"time"];
            animationData.blurRadius = [data mvFloatValueForKey:@"size" defaultValue:0];
            [array addObject:animationData];
        }
        _formatedAnimationPath = [NSArray arrayWithArray:array];
    }
    return _formatedAnimationPath;
}

- (Class)getFilterClass
{
    return [MVVideoBlurFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.blurFilter) {
        return self.blurFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.blurFilter = (MVVideoBlurFilter *)filter;
    float blurRadius = 0.0;
    if ([self.filterConfig objectForKey:@"size"]) {
        blurRadius = [self.filterConfig mvFloatValueForKey:@"size"];
    }
    self.blurFilter.blurRadiusInPixels = blurRadius;
    return self.blurFilter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectBlurFilterAnimationData *startAnimationData = nil;
        MVVideoEffectBlurFilterAnimationData *endAnimationData = nil;
        if (![self findStartAnimationData:&startAnimationData
                         endAnimationData:&endAnimationData
                                   atTime:time
                         inAnimationArray:self.formatedAnimationPath])
        {
            return;
        }
        if (endAnimationData.time <= startAnimationData.time) {
            return;
        }
        float slice = (time - startAnimationData.time) / (endAnimationData.time - startAnimationData.time);
        float blurRadius = [self.interpolation interpolateBySlice:slice start:startAnimationData.blurRadius end:endAnimationData.blurRadius];
        self.blurFilter.blurRadiusInPixels = blurRadius;
    }
}

@end

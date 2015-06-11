//
//  MVVideoEffectTransformFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/2/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectTransformFilterExcutor.h"
#import "MVVideoTransformFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectTransformFilterAnimationData : MVVideoEffectFilterAnimationData

@property(nonatomic) float scale;
@property(nonatomic) float angle;

@end

@implementation MVVideoEffectTransformFilterAnimationData

@end

@interface MVVideoEffectTransformFilterExcutor ()

@property(nonatomic,strong) MVVideoTransformFilter *transformFilter;
@property(nonatomic,strong) NSArray *formatedAnimationPath;

@end

@implementation MVVideoEffectTransformFilterExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in self.animationPath) {
            NSDictionary *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectTransformFilterAnimationData *animationData = [[MVVideoEffectTransformFilterAnimationData alloc] init];
            animationData.time = [item mvDoubleValueForKey:@"time"];
            animationData.scale = [data mvFloatValueForKey:@"scale" defaultValue:1];
            animationData.angle = [data mvFloatValueForKey:@"angle" defaultValue:0] * M_PI / 180;
            [array addObject:animationData];
        }
        _formatedAnimationPath = [NSArray arrayWithArray:array];
    }
    return _formatedAnimationPath;
}

- (Class)getFilterClass
{
    return [MVVideoTransformFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.transformFilter) {
        return self.transformFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.transformFilter = (MVVideoTransformFilter *)filter;
    float scale = 1.0;
    float angle = 0.0;
    if (self.filterConfig) {
        if ([self.filterConfig objectForKey:@"scale"]) {
            scale = [[self.filterConfig objectForKey:@"scale"] floatValue];
        }
        if ([self.filterConfig objectForKey:@"angle"]) {
            angle = [[self.filterConfig objectForKey:@"angle"] floatValue];
        }
    }
    CGAffineTransform t = CGAffineTransformIdentity;
    if (self.transformFilter.type == MVVideoTransformFilterScaleOnly) {
        t = CGAffineTransformScale(t, scale, scale);
    } else if (self.transformFilter.type == MVVideoTransformFilterRotateOnly) {
        t = CGAffineTransformRotate(t, angle);
    } else if (self.transformFilter.type == MVVideoTransformFilterScaleAndRotate) {
        t = CGAffineTransformScale(t, scale, scale);
        t = CGAffineTransformRotate(t, angle);
    }
    self.transformFilter.affineTransform = t;
    return filter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectTransformFilterAnimationData *startAnimationData = nil;
        MVVideoEffectTransformFilterAnimationData *endAnimationData = nil;
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
        float scale = [self.interpolation interpolateBySlice:slice start:startAnimationData.scale end:endAnimationData.scale];
        float angle = [self.interpolation interpolateBySlice:slice start:startAnimationData.angle end:endAnimationData.angle];
        CGAffineTransform t = CGAffineTransformIdentity;
        if (self.transformFilter.type == MVVideoTransformFilterScaleOnly) {
            t = CGAffineTransformScale(t, scale, scale);
        } else if (self.transformFilter.type == MVVideoTransformFilterRotateOnly) {
            t = CGAffineTransformRotate(t, angle);
        } else if (self.transformFilter.type == MVVideoTransformFilterScaleAndRotate) {
            t = CGAffineTransformScale(t, scale, scale);
            t = CGAffineTransformRotate(t, angle);
        }
        self.transformFilter.affineTransform = t;
    }
}

@end

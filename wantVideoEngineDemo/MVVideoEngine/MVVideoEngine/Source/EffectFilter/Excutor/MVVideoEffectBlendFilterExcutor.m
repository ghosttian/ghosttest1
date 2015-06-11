//
//  MVVideoEffectBlendFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/3/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectBlendFilterExcutor.h"
#import "MVVideoBlendFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectBlendAnimationData : MVVideoEffectFilterAnimationData

@property(nonatomic) float alpha;
@property(nonatomic) BOOL alphaFixed;
@property(nonatomic) float x;
@property(nonatomic) BOOL xFixed;
@property(nonatomic) float y;
@property(nonatomic) BOOL yFixed;
@property(nonatomic) float width;
@property(nonatomic) BOOL widthFixed;
@property(nonatomic) float height;
@property(nonatomic) BOOL heightFixed;

@end

@implementation MVVideoEffectBlendAnimationData

@end

@interface MVVideoEffectBlendFilterExcutor ()

@property(nonatomic,strong) MVVideoBlendFilter *blendFilter;
@property(nonatomic,strong) NSArray *formatedAnimationPath;

@end

@implementation MVVideoEffectBlendFilterExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in self.animationPath) {
            NSDictionary *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectBlendAnimationData *animationData = [[MVVideoEffectBlendAnimationData alloc] init];
            animationData.time = [item mvDoubleValueForKey:@"time"];
            if ([data objectForKey:@"a"]) {
                animationData.alpha = [data mvFloatValueForKey:@"a" defaultValue:0];
            } else {
                animationData.alphaFixed = YES;
            }
            if ([data objectForKey:@"x"]) {
                animationData.x = [data mvFloatValueForKey:@"x" defaultValue:0];
            } else {
                animationData.xFixed = YES;
            }
            if ([data objectForKey:@"y"]) {
                animationData.y = [data mvFloatValueForKey:@"y" defaultValue:0];
            } else {
                animationData.yFixed = YES;
            }
            if ([data objectForKey:@"w"]) {
                animationData.width = [data mvFloatValueForKey:@"w" defaultValue:1];
            } else {
                animationData.widthFixed = YES;
            }
            if ([data objectForKey:@"h"]) {
                animationData.height = [data mvFloatValueForKey:@"h" defaultValue:1];
            } else {
                animationData.heightFixed = YES;
            }
            [array addObject:animationData];
        }
        _formatedAnimationPath = [NSArray arrayWithArray:array];
    }
    return _formatedAnimationPath;
}

- (Class)getFilterClass
{
    return [MVVideoBlendFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.blendFilter) {
        return self.blendFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.blendFilter = (MVVideoBlendFilter *)filter;
    if (self.filterConfig) {
        float alpha = [self.filterConfig mvFloatValueForKey:@"a"];
        if (alpha <= 0.0) {
            alpha = 0.0;
        } else if (alpha >= 1.0) {
            alpha = 1.0;
        }
        
        float x = 0.0;
        if ([self.filterConfig objectForKey:@"x"]) {
            x = [self.filterConfig mvFloatValueForKey:@"x"];
        }
        float y = 0.0;
        if ([self.filterConfig objectForKey:@"y"]) {
            y = [self.filterConfig mvFloatValueForKey:@"y"];
        }
        float w = 1.0;
        if ([self.filterConfig objectForKey:@"w"]) {
            w = [self.filterConfig mvFloatValueForKey:@"w"];
        }
        float h = 1.0;
        if ([self.filterConfig objectForKey:@"h"]) {
            h = [self.filterConfig mvFloatValueForKey:@"h"];
        }
        int reverse = 0;
        if ([self.filterConfig objectForKey:@"r"]) {
            reverse = (int)[self.filterConfig mvIntegerValueForKey:@"r"];
        }
        [self.blendFilter setAlpha:1.0 - alpha];
        [self.blendFilter setX:x];
        [self.blendFilter setY:y];
        [self.blendFilter setWidth:w];
        [self.blendFilter setHeight:h];
        [self.blendFilter setReversed:reverse];
    }
    return filter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectBlendAnimationData *startAnimationData = nil;
        MVVideoEffectBlendAnimationData *endAnimationData = nil;
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
        if (!startAnimationData.alphaFixed) {
            float alpha = [self.interpolation interpolateBySlice:slice start:startAnimationData.alpha end:endAnimationData.alpha];
            [self.blendFilter setAlpha:1.0 - alpha];
        }
        if (!startAnimationData.xFixed) {
            float x = [self.interpolation interpolateBySlice:slice start:startAnimationData.x end:endAnimationData.x];
            [self.blendFilter setX:x];
        }
        if (!startAnimationData.yFixed) {
            float y = [self.interpolation interpolateBySlice:slice start:startAnimationData.y end:endAnimationData.y];
            [self.blendFilter setY:y];
        }
        if (!startAnimationData.widthFixed) {
            float width = [self.interpolation interpolateBySlice:slice start:startAnimationData.width end:endAnimationData.width];
            [self.blendFilter setWidth:width];
        }
        if (!startAnimationData.heightFixed) {
            float height = [self.interpolation interpolateBySlice:slice start:startAnimationData.height end:endAnimationData.height];
            [self.blendFilter setHeight:height];
        }
    }
}

@end

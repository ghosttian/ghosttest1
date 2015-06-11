//
//  MVVideoEffectRadialBlurFilterExcutor.m
//  microChannel
//
//  Created by ghosttian on 14-11-4.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "MVVideoEffectRadialBlurFilterExcutor.h"
#import "MVVideoRadialBlurFilter.h"
#import "MVVideoSCBFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectRadialBlurAnimationData : MVVideoEffectFilterAnimationData

@property(nonatomic,assign)float separation;
@property(nonatomic,assign)BOOL separationFixed;
@property(nonatomic,assign)float radius;
@property(nonatomic,assign)BOOL radiusFixed;
@property(nonatomic,assign)float x;
@property(nonatomic,assign)BOOL xFixed;
@property(nonatomic,assign)float y;
@property(nonatomic,assign)BOOL yFixed;

@end

@implementation MVVideoEffectRadialBlurAnimationData

@end

@interface MVVideoEffectRadialBlurFilterExcutor ()

@property(nonatomic,strong) MVVideoRadialBlurFilter *radialBlurFilter;
@property(nonatomic,strong) NSArray *formatedAnimationPath;

@end

@implementation MVVideoEffectRadialBlurFilterExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in self.animationPath) {
            NSDictionary *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectRadialBlurAnimationData *animationData = [[MVVideoEffectRadialBlurAnimationData alloc] init];
            animationData.time = [item mvDoubleValueForKey:@"time"];
            if ([data objectForKey:@"radius"]) {
                animationData.radius = [data mvFloatValueForKey:@"radius" defaultValue:0];
            } else {
                animationData.radiusFixed = YES;
            }
            if ([data objectForKey:@"separation"]) {
                animationData.separation = [data mvFloatValueForKey:@"separation" defaultValue:0];
            } else {
                animationData.separationFixed = YES;
            }
            if ([data objectForKey:@"x"]) {
                animationData.x = [data mvFloatValueForKey:@"x" defaultValue:0];
            } else {
                animationData.xFixed = YES;
            }
            if ([data objectForKey:@"y"]) {
                animationData.y = [data mvFloatValueForKey:@"y" defaultValue:1];
            } else {
                animationData.yFixed = YES;
            }

            [array addObject:animationData];
        }
        _formatedAnimationPath = [NSArray arrayWithArray:array];
    }
    return _formatedAnimationPath;
}

- (Class)getFilterClass
{
    return [MVVideoRadialBlurFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.radialBlurFilter) {
        return self.radialBlurFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.radialBlurFilter = (MVVideoRadialBlurFilter *)filter;
    if (self.filterConfig) {

        float x = 0.5;
        if ([self.filterConfig objectForKey:@"x"]) {
            x = [self.filterConfig mvFloatValueForKey:@"x"];
        }
        float y = 0.0;
        if ([self.filterConfig objectForKey:@"y"]) {
            y = [self.filterConfig mvFloatValueForKey:@"y"];
        }
        float separation = 0.5;
        if ([self.filterConfig objectForKey:@"separation"]) {
            separation = [self.filterConfig mvFloatValueForKey:@"separation"];
        }
        float radius = 0.5;
        if ([self.filterConfig objectForKey:@"radius"]) {
            radius = [self.filterConfig mvFloatValueForKey:@"radius"];
        }

        [self.radialBlurFilter setSeparation:separation];
        [self.radialBlurFilter setRadius:radius];
        [self.radialBlurFilter setX:x];
        [self.radialBlurFilter setY:y];
    }
    return filter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectRadialBlurAnimationData *startAnimationData = nil;
        MVVideoEffectRadialBlurAnimationData *endAnimationData = nil;
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
        if (!startAnimationData.separationFixed) {
            float separation = [self.interpolation interpolateBySlice:slice start:startAnimationData.separation end:endAnimationData.separation];
            [self.radialBlurFilter setSeparation:separation];
        }

        if (!startAnimationData.radiusFixed) {
            float radius = [self.interpolation interpolateBySlice:slice start:startAnimationData.radius end:endAnimationData.radius];
            [self.radialBlurFilter setRadius:radius];
        }

        if (!startAnimationData.xFixed) {
            float x = [self.interpolation interpolateBySlice:slice start:startAnimationData.x end:endAnimationData.x];
            [self.radialBlurFilter setX:x];
        }

        if (!startAnimationData.yFixed) {
            float y = [self.interpolation interpolateBySlice:slice start:startAnimationData.y end:endAnimationData.y];
            [self.radialBlurFilter setY:y];
        }

    }
}

@end

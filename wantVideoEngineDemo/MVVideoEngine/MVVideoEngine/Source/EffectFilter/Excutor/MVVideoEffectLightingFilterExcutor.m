//
//  MVVideoEffectLightingFilterExcutor.m
//  MVVideoEngine
//
//  Created by eson on 14-12-15.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectLightingFilterExcutor.h"

#import "MVVideoLightingFilter.h"

@interface MVVideoEffectLightingFilterAnimationData : MVVideoEffectFilterAnimationData

@property (nonatomic, assign) float exposure;
@property (nonatomic, assign) float scode;
@property (nonatomic, assign) float blurSize;
@property (nonatomic, assign) BOOL  exposureFixed;
@property (nonatomic, assign) BOOL  scodeFixed;
@property (nonatomic, assign) BOOL  blurSizeFixed;

@end

@implementation MVVideoEffectLightingFilterAnimationData

@end

@interface MVVideoEffectLightingFilterExcutor ()

@property (nonatomic, strong) NSArray               *formatedAnimationPath;
@property (nonatomic, strong) MVVideoLightingFilter *lightingFilter;

@end

@implementation MVVideoEffectLightingFilterExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];

        for (NSDictionary *item in self.animationPath) {
            NSDictionary                             *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectLightingFilterAnimationData *animationData = [[MVVideoEffectLightingFilterAnimationData alloc] init];
            animationData.time = [item mvDoubleValueForKey:@"time"];

            if ([data objectForKey:@"blursize"]) {
                animationData.blurSizeFixed = YES;
                animationData.blurSize = [data mvFloatValueForKey:@"blursize" defaultValue:0.06];
            }

            if ([data objectForKey:@"exposure"]) {
                animationData.exposureFixed = YES;
                animationData.exposure = [data mvFloatValueForKey:@"exposure" defaultValue:1];
            }

            if ([data objectForKey:@"scode"]) {
                animationData.scode = [data mvFloatValueForKey:@"scode" defaultValue:0.56];
                animationData.scodeFixed = YES;
            }

            [array addObject:animationData];
        }

        _formatedAnimationPath = [NSArray arrayWithArray:array];
    }

    return _formatedAnimationPath;
}

- (Class)getFilterClass
{
    return [MVVideoLightingFilter class];
}

- (GPUImageOutput <GPUImageInput> *)getFilter
{
    if (self.lightingFilter) {
        return self.lightingFilter;
    }

    GPUImageFilter *filter = [super getFilter];

    if (!filter) {
        return nil;
    }

    self.lightingFilter = (MVVideoLightingFilter *)filter;

    if ([self.filterConfig objectForKey:@"blursize"]) {
		float blurSize = [self.filterConfig mvFloatValueForKey:@"blursize"];
		self.lightingFilter.blurSize = blurSize;
    }
	
	if ([self.filterConfig objectForKey:@"exposure"]) {
		float exposure = [self.filterConfig mvFloatValueForKey:@"exposure"];
		self.lightingFilter.exposure = exposure;
	}
	
	if ([self.filterConfig objectForKey:@"scode"]) {
		float scode = [self.filterConfig mvFloatValueForKey:@"scode"];
		self.lightingFilter.scode = scode;
	}

    return self.lightingFilter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectLightingFilterAnimationData *startAnimationData = nil;
        MVVideoEffectLightingFilterAnimationData *endAnimationData = nil;

        if (![self findStartAnimationData:&startAnimationData
                         endAnimationData:&endAnimationData
                                   atTime:time
                         inAnimationArray:self.formatedAnimationPath]) {
            return;
        }

        if (endAnimationData.time <= startAnimationData.time) {
            return;
        }

        float slice = (time - startAnimationData.time) / (endAnimationData.time - startAnimationData.time);

        if (startAnimationData.blurSizeFixed) {
            float blurSize = [self.interpolation interpolateBySlice:slice start:startAnimationData.blurSize end:endAnimationData.blurSize];
            self.lightingFilter.blurSize = blurSize;
        }

        if (startAnimationData.exposureFixed) {
            float exposure = [self.interpolation interpolateBySlice:slice start:startAnimationData.exposure end:endAnimationData.exposure];
            self.lightingFilter.exposure = exposure;
        }

        if (startAnimationData.scodeFixed) {
            float scode = [self.interpolation interpolateBySlice:slice start:startAnimationData.scode end:endAnimationData.scode];
            self.lightingFilter.scode = scode;
        }
    }
}

@end

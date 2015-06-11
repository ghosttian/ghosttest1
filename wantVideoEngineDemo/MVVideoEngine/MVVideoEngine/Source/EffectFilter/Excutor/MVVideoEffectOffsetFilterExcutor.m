//
//  MVVideoEffectOffsetFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/2/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectOffsetFilterExcutor.h"
#import "MVVideoOffsetFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectOffsetFilterAnimationData : MVVideoEffectFilterAnimationData

@property(nonatomic) float x;
@property(nonatomic) BOOL xFixed;
@property(nonatomic) float y;
@property(nonatomic) BOOL yFixed;

@end

@implementation MVVideoEffectOffsetFilterAnimationData

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"time:%f x:%f y:%f",self.time,self.x,self.y];
}

@end

@interface MVVideoEffectOffsetFilterExcutor ()

@property(nonatomic,strong) MVVideoOffsetFilter *offsetFilter;
@property(nonatomic,strong) NSArray *formatedAnimationPath;

@end

@implementation MVVideoEffectOffsetFilterExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in self.animationPath) {
            NSDictionary *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectOffsetFilterAnimationData *animationData = [[MVVideoEffectOffsetFilterAnimationData alloc] init];
            animationData.time = [item mvDoubleValueForKey:@"time"];
            if ([data objectForKey:@"x"]) {
                animationData.x = [data mvFloatValueForKey:@"x"];
            } else {
                animationData.xFixed = YES;
            }
            if ([data objectForKey:@"y"]) {
                animationData.y = [data mvFloatValueForKey:@"y"];
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
    return [MVVideoOffsetFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.offsetFilter) {
        return self.offsetFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.offsetFilter = (MVVideoOffsetFilter *)filter;
    if (self.filterConfig) {
        float gap = [self.filterConfig mvFloatValueForKey:@"gap"];
        int type = [self.filterConfig mvIntValueForKey:@"type"];
        float x = [self.filterConfig mvFloatValueForKey:@"x"];
        float y = [self.filterConfig mvFloatValueForKey:@"y"];
        self.offsetFilter.offsetX = x;
        self.offsetFilter.offsetY = y;
        self.offsetFilter.followType = type;
        self.offsetFilter.followGap = gap;
    }
    if (self.animationPath.count > 0) {
        NSDictionary *data = [[self.animationPath objectAtIndex:0] mvDictionaryValueForKey:@"data"];
        if ([data objectForKey:@"gap"]) {
            float gap = [data mvFloatValueForKey:@"gap"];
            self.offsetFilter.followGap = gap;
        }
        if ([data objectForKey:@"type"]) {
            int type = [data mvIntValueForKey:@"type"];
            self.offsetFilter.followType = type;
        }
    }
    return filter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectOffsetFilterAnimationData *startAnimationData = nil;
        MVVideoEffectOffsetFilterAnimationData *endAnimationData = nil;
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
        if (!startAnimationData.xFixed) {
            float x = [self.interpolation interpolateBySlice:slice start:startAnimationData.x end:endAnimationData.x];
            self.offsetFilter.offsetX = x;
        }
        if (!startAnimationData.yFixed) {
            float y = [self.interpolation interpolateBySlice:slice start:startAnimationData.y end:endAnimationData.y];
            self.offsetFilter.offsetY = y;
        }
    }
}

@end

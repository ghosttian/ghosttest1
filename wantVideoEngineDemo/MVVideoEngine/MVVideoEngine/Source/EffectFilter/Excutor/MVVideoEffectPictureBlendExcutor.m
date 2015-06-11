//
//  MVVideoEffectPictureBlendExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectPictureBlendExcutor.h"
#import "MVVideoPictureBlendFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectPictureBlendAnimationData : MVVideoEffectFilterAnimationData

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

@implementation MVVideoEffectPictureBlendAnimationData

@end

@interface MVVideoEffectPictureBlendExcutor ()

@property(nonatomic,strong) MVVideoPictureBlendFilter *pictureFilter;
@property(nonatomic) GPUImagePicture *picture;
@property(nonatomic,strong) NSArray *formatedAnimationPath;

@end

@implementation MVVideoEffectPictureBlendExcutor

- (NSArray *)formatedAnimationPath
{
    if (!_formatedAnimationPath) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *item in self.animationPath) {
            NSDictionary *data = [item mvDictionaryValueForKey:@"data"];
            MVVideoEffectPictureBlendAnimationData *animationData = [[MVVideoEffectPictureBlendAnimationData alloc] init];
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
    return [MVVideoPictureBlendFilter class];
}

- (GPUImageFilter *)getFilter
{
	if (self.pictureFilter) {
		return self.pictureFilter;
	}
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.pictureFilter = (MVVideoPictureBlendFilter *)filter;
    
    UIImage *image = [UIImage new];
    id pictureObjc = [self.filterConfig objectForKey:@"picture"];
    if ([pictureObjc isKindOfClass:[UIImage class]]) {
        image = (UIImage *)pictureObjc;
    }
    self.picture = [[GPUImagePicture alloc] initWithImage:image];
    [self.picture addTarget:self.pictureFilter atTextureLocation:1];
    [self.pictureFilter disableSecondFrameCheck];
    [self.picture processImage];
    if (self.filterConfig) {
        float alpha = 0.0;
        if ([self.filterConfig objectForKey:@"a"]) {
            alpha = [self.filterConfig mvFloatValueForKey:@"a"];
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
            reverse = [self.filterConfig mvIntValueForKey:@"r"];
        }
        [self.pictureFilter setAlpha:1.0 - alpha];
        [self.pictureFilter setX:x];
        [self.pictureFilter setY:y];
        [self.pictureFilter setWidth:w];
        [self.pictureFilter setHeight:h];
        [self.pictureFilter setReversed:reverse];
    }
    return self.pictureFilter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    if (self.formatedAnimationPath.count > 0) {
        time = time - self.excutorStartTime;
        MVVideoEffectPictureBlendAnimationData *startAnimationData = nil;
        MVVideoEffectPictureBlendAnimationData *endAnimationData = nil;
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
            [self.pictureFilter setAlpha:1.0 - alpha];
        }
        if (!startAnimationData.xFixed) {
            float x = [self.interpolation interpolateBySlice:slice start:startAnimationData.x end:endAnimationData.x];
            [self.pictureFilter setX:x];
        }
        if (!startAnimationData.yFixed) {
            float y = [self.interpolation interpolateBySlice:slice start:startAnimationData.y end:endAnimationData.y];
            [self.pictureFilter setY:y];
        }
        if (!startAnimationData.widthFixed) {
            float width = [self.interpolation interpolateBySlice:slice start:startAnimationData.width end:endAnimationData.width];
            [self.pictureFilter setWidth:width];
        }
        if (!startAnimationData.heightFixed) {
            float height = [self.interpolation interpolateBySlice:slice start:startAnimationData.height end:endAnimationData.height];
            [self.pictureFilter setHeight:height];
        }
    }
}

@end

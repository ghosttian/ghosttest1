//
//  MVVideoEffectFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/2/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectFilterExcutor.h"
#import "MVVideoEffectOffsetFilterExcutor.h"
#import "MVVideoEffectTransformFilterExcutor.h"
#import "MVVideoEffectBlendFilterExcutor.h"
#import "MVVideoEffectBlurFilterExcutor.h"
#import "MVVideoEffectPictureBlendExcutor.h"
#import "MVVideoEffectCurveFilterExcutor.h"
#import "MVVideoEffectCurveRGBFilterExcutor.h"
#import "MVVideoEffectColorPencilFilterExcutor.h"
#import "MVVideoEffectOldFilmFilterExcutor.h"
#import "MVVideoEffectSkinBeautyFilterExcutor.h"
#import "MVVideoEffectSampleFilterExcutor.h"
#import "MVVideoEffectStencilFilterExcutor.h"
#import "MVVideoEffectSCBFilterExcutor.h"
#import "MVVideoEffectAdvancedCurveRGBFilterExcutor.h"
#import "MVVideoEffectRadialBlurFilterExcutor.h"
#import "MVVideoEffectAdvancedCurveRGBPartialFilterExcutor.h"
#import "MVVideoEffectCurveRGBPartialFilterExcutor.h"
#import "MVVideoEffectCurvePartialFilterExcutor.h"
#import "MVVideoEffectRadialBlurPartialFilterExcutor.h"
#import "MVVideoEffectSCBPartialFilterExcutor.h"
#import "MVVideoEffectColorPencilPartialFilterExcutor.h"
#import "MVVideoEffectCrayonPencilFilterExcutor.h"
#import "MVVideoEffectSketchFilterExcutor.h"
#import "MVVideoEffectCrayonPencilPartialFilterExcutor.h"
#import "MVVideoEffectSketchPartialFilterExcutor.h"
#import "MVVideoEffectAttractFilterExcutor.h"
#import "MVVideoEffectFantasyFilterExcutor.h"
#import "MVVideoEffectRedColorFilterExcutor.h"
#import "MVVideoEffectPortraitBeautyFilterExcutor.h"
#import "MVVideoEffectDarkCornerInstantFilterExcutor.h"
#import "MVVideoEffectColorAdjustmentFilterExcutor.h"
#import "MVVideoEffectLightingFilterExcutor.h"

@implementation MVVideoEffectFilterAnimationData

@end

@implementation MVVideoEffectFilterExcutor

+ (MVVideoEffectFilterExcutor *)createFilterExcutorWithAnimationPath:(NSArray *)animationPath
                                                        filterConfig:(NSDictionary *)filterConfig
                                                            filterId:(NSInteger)filterId
                                                    excutorStartTime:(CFTimeInterval)excutorStartTime
                                                            videoURL:(NSString *)videoURLString
{
    MVVideoEffectFilterExcutor * excutor = nil;
    switch (filterId) {
        case 10001:
        {
            excutor = [[MVVideoEffectOffsetFilterExcutor alloc] init];
            break;
        }
        case 10002:
        {
            excutor = [[MVVideoEffectBlendFilterExcutor alloc] init];
            break;
        }
        case 10003://模糊滤镜
        {
            excutor = [[MVVideoEffectBlurFilterExcutor alloc] init];
            break;
        }
        case 10004:
        {
            excutor = [[MVVideoEffectPictureBlendExcutor alloc] init];
            break;
        }
        case 10005:
        case 10006:
        case 10007:
        {
            excutor = [[MVVideoEffectTransformFilterExcutor alloc] init];
            break;
        }
        case 10008://饱和度、对比度、明度
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectSCBPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectSCBFilterExcutor alloc] init];
            }
            break;
        }
        case 10010:
        {
            excutor = [[MVVideoEffectStencilFilterExcutor alloc] init];
            break;
        }
        case 10013://径向模糊滤镜
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectRadialBlurPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectRadialBlurFilterExcutor alloc] init];
            }
            break;
        }
        case 11100://自定义调色滤镜 
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectCurveRGBPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectCurveRGBFilterExcutor alloc] init];
            }
            break;
        }
        case 11200://高级自定义调色滤镜
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectAdvancedCurveRGBPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectAdvancedCurveRGBFilterExcutor alloc] init];
            }
            break;
        }
        case 11000://MIC_1977
        case 11001://MIC_AMARO
        case 11002://MIC_WALDEN
        case 11003://MIC_BRANNAN
        case 11004://MIC_EARLYBIRD
        case 11005://MIC_HEFE
        case 11006://MIC_HUDSON
        case 11007://MIC_INKWELL
        case 11008://MIC_KELVIN
        case 11009://MIC_LOFI
        case 11010://MIC_NASHVILLE
        case 11011://MIC_RISE
        case 11012://MIC_SIERRA
        case 11013://MIC_SUTRO
        case 11014://MIC_TOASTER
        case 11015://MIC_VALENCIA
        case 11016://MIC_XPRO
        case 11017://WEICO_FILM
        case 11018://WEICO_DIANA
        case 11019://WEICO_BW
        case 11020://WEICO_VIOLET
        case 11021://WEICO_1949
        case 11022://WEICO_1949
        case 11023://WEICO_HOLGA
        case 11024://WEICO_FOREST
        case 11025://WEICO_OLDSCHOOL
        case 11026://WEICO_INSTANT
        case 11027://WEICO_SUN
        case 11028://WEICO_LONDON
        case 11029://WEICO_INDIGO
        case 11030://WEICO_SILVER
        case 11031://WEICO_MOMENT
        case 11032://QQ_TONNYBW
        case 11033://QQ_TONNYNOSTALGIC
        case 11034://QQ_TONNYCHURCH
        case 11042://淡雅
        case 11043://蓝韵
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectCurvePartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectCurveFilterExcutor alloc] init];
            }
            break;

        }
        case 11035://蜡笔
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectCrayonPencilPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectCrayonPencilFilterExcutor alloc]init];
            }
            break;
        }
        case 11036:
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectColorPencilPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectColorPencilFilterExcutor alloc] init];
            }

            break;
        }
            case 11037:
        {
            if (videoURLString) {
                excutor = [[MVVideoEffectSketchPartialFilterExcutor alloc]init];
                excutor.isLocalFilter = YES;
            }else{
                excutor = [[MVVideoEffectSketchFilterExcutor alloc]init];
            }
            break;
        }
        case 11041://老电影
        {
            excutor = [[MVVideoEffectOldFilmFilterExcutor alloc] init];
            break;
        }
        case 11038://鱼眼
        case 11039://拉伸
        case 11040://扭曲
        case 11044://重影
        {
            excutor = [[MVVideoEffectSampleFilterExcutor alloc] init];
            break;
        }
        case 11045://阿宝色
        {
            excutor = [[MVVideoEffectAttractFilterExcutor alloc]init];
            break;
        }
        case 11046://幻想
        {
            excutor = [[MVVideoEffectFantasyFilterExcutor alloc]init];
            break;
        }
        case 11047://柳绿花红
        {
            excutor = [[MVVideoEffectRedColorFilterExcutor alloc]init];
            break;
        }
        case 11048://清新丽人
        case 11049://甜美可人
        case 11050://深度美白
        case 11051://香艳红唇
        {
            excutor = [[MVVideoEffectPortraitBeautyFilterExcutor alloc]init];
            break;
        }
        case 11052://拍立得
        {
            excutor = [[MVVideoEffectDarkCornerInstantFilterExcutor alloc]init];
            break;
        }
        case 11053://补光
        {
            excutor = [[MVVideoEffectColorAdjustmentFilterExcutor alloc]init];
            break;
        }

		case 11210://光照调节(曝光)
		{
			excutor = [[MVVideoEffectLightingFilterExcutor alloc]init];
		} break;
			
        case 11301://501
        case 11302://502
        case 11303://503
        case 11304://504
        case 11305://505
        {
            excutor = [[MVVideoEffectSkinBeautyFilterExcutor alloc] init];
            break;
        }
            
        default:
            break;

    }
    excutor.animationPath = animationPath;
    excutor.filterConfig = filterConfig;
    excutor.filterId = filterId;
    excutor.excutorStartTime = excutorStartTime;
    return excutor;
}

- (MAMediaTimingFunction *)interpolation
{
    if (!_interpolation) {
        _interpolation = [MAMediaTimingFunction functionWithType:MAMediaTimingFunctionLinear];
    }
    return _interpolation;
}

- (Class)getFilterClass
{
    return [GPUImageFilter class];
}

- (GPUImageFilter *)getFilter
{
    GPUImageFilter *filter = [MVVideoEffectFilterFactory createFilterByFilterId:self.filterId filterConfig:self.filterConfig Local:self.isLocalFilter];
    if (![filter isKindOfClass:[self getFilterClass]]) {
        return nil;
    }
    return filter;
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    
}

- (BOOL)findStartAnimationData:(MVVideoEffectFilterAnimationData **)startAnimationData
              endAnimationData:(MVVideoEffectFilterAnimationData **)endAnimationData
                        atTime:(CFTimeInterval)time
              inAnimationArray:(NSArray *)array
{
    if (array.count <= 0) {
        return NO;
    }
    for (MVVideoEffectFilterAnimationData *item in array) {
        if (*startAnimationData && *endAnimationData) {
            break;
        }
        if (item.time <= time) {
            *startAnimationData = item;
        } else {
            *endAnimationData = item;
        }
    }
    if (!(*endAnimationData)) {
        *endAnimationData = [array lastObject];
    }
    if (*startAnimationData && *endAnimationData) {
        return YES;
    }
    return NO;
}

@end

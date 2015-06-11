//
//  MVVideoEffectFilterFactory.m
//  microChannel
//
//  Created by aidenluo on 9/1/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectFilterFactory.h"
#import "GPUImage.h"
#import "MVVideoOffsetFilter.h"
#import "MVVideoTransformFilter.h"
#import "MVVideoCurveFilter.h"
#import "MVVideoBlendFilter.h"
#import "MVVideoBlurFilter.h"
#import "MVVideoPictureBlendFilter.h"
#import "MVVideoCurveRGBFilter.h"
#import "MVVideoColorPencilFilter.h"
#import "MVVideoOldFilmFilter.h"
#import "MVVideoFishEyeFilter.h"
#import "MVVideoStretchFilter.h"
#import "MVVideoTwirlFilter.h"
#import "NSString+Util.h"
#import "MVVideoStencilFilter.h"
#import "MVVideoSCBFilter.h"
#import "MVVideoAdvancedCurveRGBFilter.h"
#import "MVVideoRadialBlurFilter.h"
#import "MVVideoRadialBlurPartialFilter.h"
#import "MVVideoCurvePartialFilter.h"
#import "MVVIdeoSCBPartialFilter.h"
#import "MVVideoCurveRGBPartialFilter.h"
#import "MVVideoAdvancedCurveRGBPartialFilter.h"
#import "MVVideoColorPencilPartialFilter.h"
#import "MVVideoCrayonPencilFilter.h"
#import "MVVideoSketchFilter.h"
#import "MVVideoCrayonPencilPartialFilter.h"
#import "MVVideoSketchPartialFilter.h"
#import "MVVideoAttractFilter.h"
#import "MVVideoFantasyFilter.h"
#import "MVVideoRedColorFilter.h"
#import "MVVideoPortraitBeautyFilter.h"
#import "MVVideoCurveDarkCornerFilter.h"
#import "MVVideoColorAdjustmentFilter.h"
#import "NSDictionary+Util.h"
#import "MVVideoLightingFilter.h"

static NSCache *curveImageCache = nil;

@implementation MVVideoEffectFilterFactory

+ (void)load
{
    curveImageCache = [[NSCache alloc] init];
}

+ (GPUImageFilter *)createFilterByFilterId:(NSInteger)filterId
                              filterConfig:(NSDictionary *)filterConfig
                                     Local:(BOOL)isLocalFilter
{
    GPUImageFilter *filter = [[GPUImageFilter alloc] init];
    switch (filterId) {
        case 10001://跳帧
        {
            filter = [[MVVideoOffsetFilter alloc] init];
            break;
        }
        case 10002://视频叠加
        {
            MVVideoBlendFilterMode blendMode = (MVVideoBlendFilterMode)[filterConfig mvIntegerValueForKey:@"type"];
            MVVideoBlendFilter *blendFilter = [[MVVideoBlendFilter alloc] initWithBlendMode:blendMode];
            filter = blendFilter;
            break;
        }
        case 10003://模糊
        {
            filter = [[MVVideoBlurFilter alloc] init];
            break;
        }
        case 10004://图片叠加
        {
            filter = [[MVVideoPictureBlendFilter alloc] init];
            break;
        }
        case 10005://缩放
        {
            MVVideoTransformFilter *transformFilter = [[MVVideoTransformFilter alloc] init];
            transformFilter.type = MVVideoTransformFilterScaleOnly;
            filter = transformFilter;
            break;
        }
        case 10006://旋转
        {
            MVVideoTransformFilter *transformFilter = [[MVVideoTransformFilter alloc] init];
            transformFilter.type = MVVideoTransformFilterRotateOnly;
            filter = transformFilter;
            break;
        }
        case 10007://旋转缩放
        {
            MVVideoTransformFilter *transformFilter = [[MVVideoTransformFilter alloc] init];
            transformFilter.type = MVVideoTransformFilterScaleAndRotate;
            filter = transformFilter;
            break;
        }
        case 10008://饱和度，对比度
        {
            if (isLocalFilter) {
                filter = [[MVVIdeoSCBPartialFilter alloc]init];
            }else{
                filter = [[MVVideoSCBFilter alloc] init];
            }
            break;
        }
        case 10010://蒙版
        {
            filter = [[MVVideoStencilFilter alloc] init];
            break;
        }
        case 10013://径向模糊
        {
            if (isLocalFilter) {
                filter = [[MVVideoRadialBlurPartialFilter alloc]init];
            }else{
                filter = [[MVVideoRadialBlurFilter alloc]init];
            }
            break;
        }
        case 11100://自定义调色
        {
            NSString *picturePath = [NSString getResourcePathIfExistWithURL:[filterConfig objectForKey:@"curve"]];
            UIImage *picture = [UIImage imageWithContentsOfFile:picturePath];
            if (!picture) {
                break;
            }

            BOOL cut = picture.size.width < picture.size.height * 2.0;
            if (isLocalFilter) {
                filter = [[MVVideoCurveRGBPartialFilter alloc]initWithCut:cut picture:picture];
            }else{
                filter = [[MVVideoCurveRGBFilter alloc] initWithCut:cut picture:picture];
            }
            break;
        }
        case 11200://高级调色
        {
            NSString *picturePath = [NSString getResourcePathIfExistWithURL:[filterConfig objectForKey:@"curve"]];
            UIImage *picture = [UIImage imageWithContentsOfFile:picturePath];
            if (!picture) {
                break;
            }
            if (isLocalFilter) {
                filter = [[MVVideoAdvancedCurveRGBPartialFilter alloc]initWithPicture:picture];
            }else{
                filter = [[MVVideoAdvancedCurveRGBFilter alloc] initWithPicture:picture];
            }

            break;
        }

        case 11000://MIC_1977
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"f1977.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"f1977.png"];
                [curveImageCache setObject:pic forKey:@"f1977.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11001://MIC_AMARO
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"qingyi.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"qingyi.png"];
                [curveImageCache setObject:pic forKey:@"qingyi.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11002://MIC_WALDEN
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"walden.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"walden.png"];
                [curveImageCache setObject:pic forKey:@"walden.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11003://MIC_BRANNAN
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"walden.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"walden.png"];
                [curveImageCache setObject:pic forKey:@"walden.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11004://MIC_EARLYBIRD
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"qiurisiyu.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"qiurisiyu.png"];
                [curveImageCache setObject:pic forKey:@"qiurisiyu.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11005://MIC_HEFE
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"kafei.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"kafei.png"];
                [curveImageCache setObject:pic forKey:@"kafei.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11043://蓝韵
        case 11006://MIC_HUDSON
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"hudson.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"hudson.png"];
                [curveImageCache setObject:pic forKey:@"hudson.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11007://MIC_INKWELL
        {
            GPUMatrix4x4 matrix = { 0.299f, 0.299f, 0.299f, 0, 0.587f, 0.587f, 0.587f, 0, 0.114f, 0.114f, 0.114f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"paintink.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"paintink.png"];
                [curveImageCache setObject:pic forKey:@"paintink.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11008://MIC_KELVIN
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"kelvin.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"kelvin.png"];
                [curveImageCache setObject:pic forKey:@"kelvin.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11009://MIC_LOFI
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"nongyu.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"nongyu.png"];
                [curveImageCache setObject:pic forKey:@"nongyu.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11010://MIC_NASHVILLE
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"nashville.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"nashville.png"];
                [curveImageCache setObject:pic forKey:@"nashville.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11011://MIC_RISE
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"rise.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"rise.png"];
                [curveImageCache setObject:pic forKey:@"rise.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11012://MIC_SIERRA
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"sierra.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"sierra.png"];
                [curveImageCache setObject:pic forKey:@"sierra.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11013://MIC_SUTRO
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"sutro.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"sutro.png"];
                [curveImageCache setObject:pic forKey:@"sutro.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11014://MIC_TOASTER
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"toaster.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"toaster.png"];
                [curveImageCache setObject:pic forKey:@"toaster.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11015://MIC_VALENCIA
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"valencia.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"valencia.png"];
                [curveImageCache setObject:pic forKey:@"valencia.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11016://MIC_XPRO
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"xpro2.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"xpro2.png"];
                [curveImageCache setObject:pic forKey:@"xpro2.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11042://淡雅
        case 11017://WEICO_FILM
        {
            GPUMatrix4x4 matrix = { 0.075f + 0.75f, 0.075f, 0.075f, 0, 0.147f, 0.147f + 0.75f, 0.147f, 0, 0.029f, 0.029f, 0.029f + 0.75f, 0, 0, 0, 0, 1.0f };
            UIImage *pic = [curveImageCache objectForKey:@"danya.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"danya.png"];
                [curveImageCache setObject:pic forKey:@"danya.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11018://WEICO_DIANA
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"diana+.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"diana+.png"];
                [curveImageCache setObject:pic forKey:@"diana+.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11019://WEICO_BW
        {
            GPUMatrix4x4 matrix = { 0.299f, 0.299f, 0.299f, 0, 0.587f, 0.587f, 0.587f, 0, 0.114f, 0.114f, 0.114f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"jingdianheibai.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"jingdianheibai.png"];
                [curveImageCache setObject:pic forKey:@"jingdianheibai.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11020://WEICO_VIOLET
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"ziluolan.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"ziluolan.png"];
                [curveImageCache setObject:pic forKey:@"ziluolan.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11021://WEICO_1949
        {
            GPUMatrix4x4 matrix = { 0.1495f + 0.5f, 0.1495f, 0.1495f, 0, 0.294f, 0.294f + 0.5f, 0.294f, 0, 0.057f, 0.057f, 0.057f + 0.5f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"1949.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"1949.png"];
                [curveImageCache setObject:pic forKey:@"1949.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11022://WEICO_1949
        {
            GPUMatrix4x4 matrix = { 0.075f + 0.75f, 0.075f, 0.075f, 0, 0.147f, 0.147f + 0.75f, 0.147f,  0, 0.029f,  0.029f,  0.029f + 0.75f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"loft.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"loft.png"];
                [curveImageCache setObject:pic forKey:@"loft.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11023://WEICO_HOLGA
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"holga.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"holga.png"];
                [curveImageCache setObject:pic forKey:@"holga.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11024://WEICO_FOREST
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"forest.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"forest.png"];
                [curveImageCache setObject:pic forKey:@"forest.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11025://WEICO_OLDSCHOOL
        {
            GPUMatrix4x4 matrix = { 0.075f + 0.75f, 0.075f, 0.075f, 0, 0.147f, 0.147f + 0.75f, 0.147f, 0, 0.029f, 0.029f, 0.029f + 0.75f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"oldschool.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"oldschool.png"];
                [curveImageCache setObject:pic forKey:@"oldschool.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11026://WEICO_INSTANT
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"weico_instant.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"weico_instant.png"];
                [curveImageCache setObject:pic forKey:@"weico_instant.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11027://WEICO_SUN
        {
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"mingliang.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"mingliang.png"];
                [curveImageCache setObject:pic forKey:@"mingliang.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11028://WEICO_LONDON
        {
            GPUMatrix4x4 matrix = { 0.1993f + 0.3333f, 0.1993f, 0.1993f, 0, 0.391f, 0.391f + 0.3333f, 0.391f, 0, 0.076f, 0.076f, 0.076f + 0.3333f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"london.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"london.png"];
                [curveImageCache setObject:pic forKey:@"london.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11029://WEICO_INDIGO
        {
            GPUMatrix4x4 matrix =  { 0.1993f + 0.3333f, 0.1993f, 0.1993f, 0, 0.391f, 0.391f + 0.3333f, 0.391f, 0, 0.076f, 0.076f, 0.076f + 0.3333f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"shenchen.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"shenchen.png"];
                [curveImageCache setObject:pic forKey:@"shenchen.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11030://WEICO_SILVER
        {
            GPUMatrix4x4 matrix =  { 0.299f, 0.299f, 0.299f, 0, 0.587f, 0.587f, 0.587f, 0, 0.114f, 0.114f, 0.114f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"yinzhuang.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"yinzhuang.png"];
                [curveImageCache setObject:pic forKey:@"yinzhuang.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11031://WEICO_MOMENT
        {
            GPUMatrix4x4 matrix =  { 0.1993f + 0.3333f, 0.1993f, 0.1993f, 0, 0.391f, 0.391f + 0.3333f, 0.391f, 0, 0.076f, 0.076f, 0.076f + 0.3333f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"wangshi.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"wangshi.png"];
                [curveImageCache setObject:pic forKey:@"wangshi.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11032://QQ_TONNYBW
        {
            GPUMatrix4x4 matrix =  { 0.299f, 0.299f, 0.299f, 0, 0.587f, 0.587f, 0.587f, 0, 0.114f, 0.114f, 0.114f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"qingxiheibai.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"qingxiheibai.png"];
                [curveImageCache setObject:pic forKey:@"qingxiheibai.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11033://QQ_TONNYNOSTALGIC
        {
            GPUMatrix4x4 matrix =  { 0.1993f + 0.3333f, 0.1993f, 0.1993f, 0, 0.391f, 0.391f + 0.3333f, 0.391f, 0, 0.076f, 0.076f, 0.076f + 0.3333f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"gudian.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"gudian.png"];
                [curveImageCache setObject:pic forKey:@"gudian.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11034://QQ_TONNYCHURCH
        {
            GPUMatrix4x4 matrix =  { 0.1993f + 0.3333f, 0.1993f, 0.1993f, 0, 0.391f, 0.391f + 0.3333f, 0.391f, 0, 0.076f, 0.076f, 0.076f + 0.3333f, 0, 0, 0, 0, 1 };
            UIImage *pic = [curveImageCache objectForKey:@"shishang.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"shishang.png"];
                [curveImageCache setObject:pic forKey:@"shishang.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoCurvePartialFilter alloc]initWithMatix:matrix resourceImage:pic];
            }else{
                filter = [[MVVideoCurveFilter alloc] initWithMatix:matrix resourceImage:pic];
            }
            break;
        }
        case 11035://蜡笔
        {
            if (isLocalFilter) {
                filter = [[MVVideoCrayonPencilPartialFilter alloc]init];
            }else{
                filter = [[MVVideoCrayonPencilFilter alloc]init];
            }
            break;
        }
        case 11036:/**彩铅**/
        {
            UIImage *pic = [curveImageCache objectForKey:@"colorPencil.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"colorPencil.png"];
                [curveImageCache setObject:pic forKey:@"colorPencil.png"];
            }
            if (isLocalFilter) {
                filter = [[MVVideoColorPencilPartialFilter alloc]initWithResourceImage:pic];
            }else{
                filter = [[MVVideoColorPencilFilter alloc] initWithResourceImage:pic];
            }
            break;
        }
        case 11037://素描
        {
            UIImage *pic = [curveImageCache objectForKey:@"sketch.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"sketch.png"];
                [curveImageCache setObject:pic forKey:@"sketch.png"];
            }

            if (isLocalFilter) {
                filter = [[MVVideoSketchPartialFilter alloc]initWithResourceImage:pic];
            }else{
                filter = [[MVVideoSketchFilter alloc]initWithResourceImage:pic];
            }
            break;
        }
        case 11038://鱼眼
        {
            filter = [[MVVideoFishEyeFilter alloc] init];
            break;
        }
        case 11039://拉伸
        {
            filter = [[MVVideoStretchFilter alloc] init];
            break;
        }
        case 11040://扭曲
        {
            filter = [[MVVideoTwirlFilter alloc] init];
            break;
        }
        case 11041:
        {
            UIImage *pic = [curveImageCache objectForKey:@"share_film.jpg"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"share_film.jpg"];
                [curveImageCache setObject:pic forKey:@"share_film.jpg"];
            }
            filter = [[MVVideoOldFilmFilter alloc] initWithResourceImage:pic];
            break;
        }

        case 11045://阿宝色
        {
            UIImage *pic = [curveImageCache objectForKey:@"abaofilter.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"abaofilter.png"];
                [curveImageCache setObject:pic forKey:@"abaofilter.png"];
            }

            filter = [[MVVideoAttractFilter alloc]initWithResourceImage:pic];
            break;
        }
        case 11046://幻想
        {
            UIImage *pic = [curveImageCache objectForKey:@"huanxiang.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"huanxiang.png"];
                [curveImageCache setObject:pic forKey:@"huanxiang.png"];
            }
            filter = [[MVVideoFantasyFilter alloc]initWithResourceImage:pic];
            break;
        }
        case 11047://柳绿花红
        {
            UIImage *pic = [curveImageCache objectForKey:@"NewAbao.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"NewAbao.png"];
                [curveImageCache setObject:pic forKey:@"NewAbao.png"];
            }
            filter = [[MVVideoRedColorFilter alloc]initWithResourceImage:pic];
            break;
        }
        case 11048://清新丽人
        {
            UIImage *pic = [curveImageCache objectForKey:@"portraitbeauty.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"];
                [curveImageCache setObject:pic forKey:@"portraitbeauty.png"];
            }
            filter = [[MVVideoPortraitBeautyFilter alloc]initWithPicture:pic Type:BeautyType_QingXinLiRen];
            break;
        }
        case 11049://甜美可人
        {
            UIImage *pic = [curveImageCache objectForKey:@"portraitbeauty.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"];
                [curveImageCache setObject:pic forKey:@"portraitbeauty.png"];
            }
            filter = [[MVVideoPortraitBeautyFilter alloc]initWithPicture:pic Type:BeautyType_TianMeiKeRen];
            break;
        }
        case 11050://深度美白
        {
            UIImage *pic = [curveImageCache objectForKey:@"portraitbeauty.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"];
                [curveImageCache setObject:pic forKey:@"portraitbeauty.png"];
            }
            filter = [[MVVideoPortraitBeautyFilter alloc]initWithPicture:pic Type:BeautyType_ShenDuMeiBai];
            break;
        }
        case 11051://香艳红唇
        {
            UIImage *pic = [curveImageCache objectForKey:@"portraitbeauty.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"portraitbeauty.png"];
                [curveImageCache setObject:pic forKey:@"portraitbeauty.png"];
            }
            filter = [[MVVideoPortraitBeautyFilter alloc]initWithPicture:pic Type:BeautyType_XiangYanHongChun];
            break;
        }
        case 11052://拍立得
        {
            UIImage *pic = [curveImageCache objectForKey:@"instant.png"];
            if (!pic) {
                pic = [MVVideoCurveFilter decodeImageByName:@"instant.png"];
                [curveImageCache setObject:pic forKey:@"instant.png"];
            }
            GPUMatrix4x4 matrix = { 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1.0f, 0, 0, 0, 0, 1 };
            filter = [[MVVideoCurveDarkCornerFilter alloc]initWithPicture:pic
                                                                    Matix:matrix
                                                            gradientStart:0.35
                                                            gradientEnd:1.721429];
            break;
        }
        case 11053://补光
        {
            GPUMatrix4x4 matrix = { 1.38f, 0, 0, 0, 0, 1.38f, 0, 0, 0, 0, 1.38f, 0, 0, 0, 0, 1 };
            filter = [[MVVideoColorAdjustmentFilter alloc]initWithMatix:matrix];
            break;
        }
		case 11210://光照调节(曝光)
		{
			filter = (GPUImageFilter *)[[MVVideoLightingFilter alloc]init];
		}break;
    }
    return filter;
}

@end

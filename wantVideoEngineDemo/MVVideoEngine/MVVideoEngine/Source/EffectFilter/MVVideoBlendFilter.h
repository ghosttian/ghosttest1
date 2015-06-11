//
//  MVVideoBlendFilter.h
//  microChannel
//
//  Created by aidenluo on 9/3/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

typedef NS_ENUM(NSInteger, MVVideoBlendFilterMode)
{
    MVVideoBlendFilterModeScreen = 0,
    MVVideoBlendFilterModeMax = 1,
    MVVideoBlendFilterModeMin = 2,
    MVVideoBlendFilterModeMultipy = 3,
    MVVideoBlendFilterModeOverlay = 4,
    MVVideoBlendFilterModeHardLight = 5,
    MVVideoBlendFilterModeSoftLight = 6,
    MVVideoBlendFilterModeVividLight = 7,
    MVVideoBlendFilterModeMinus = 8,
    MVVideoBlendFilterModeLiner = 9,
    MVVideoBlendFilterModeFill = 10,
    MVVideoBlendFilterModeBrightness = 11,
    MVVideoBlendFilterModeLuminance = 12,
    MVVideoBlendFilterModeLighten = 13,
    MVVideoBlendFilterModeDarken = 14,
    MVVideoBlendFilterModeOnlyWhite = 15,
    MVVideoBlendFilterModeOnlyBlack = 16,
    MVVideoBlendFilterModeMix = 100000,
};

@interface MVVideoBlendFilter : GPUImageTwoInputFilter

- (instancetype)initWithBlendMode:(MVVideoBlendFilterMode)mode;

@property(nonatomic) float alpha;
@property(nonatomic) float x;
@property(nonatomic) float y;
@property(nonatomic) float width;
@property(nonatomic) float height;
@property(nonatomic) int reversed;

@end

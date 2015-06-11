//
//  MVVideoLightingFilter.h
//  MVVideoEngine
//
//  Created by eson on 14-12-12.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "GPUImageFilter.h"
#import "GPUImageFilterGroup.h"

//光源调节滤镜
@interface MVVideoLightingFilter : GPUImageFilterGroup

// exposure ranges from 1.0 ~ 2, with 1.0 as the normal level
@property(readwrite, nonatomic) CGFloat exposure;

// blurSize ranges from 0 ~ 1 ,with 0.06 as defalt
@property(readwrite, nonatomic) CGFloat blurSize;

// scode ranges from 0.0 ~ 1.0, with 0.56 as default
@property(readwrite, nonatomic) CGFloat scode;

- (void)replaceCurrentCombineWithSource:(GPUImageOutput *)source; //需要剔除原始视频叠加，这时候可能以另外一个输入作为光晕叠加的输入

@end
